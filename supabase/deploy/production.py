"""Installed root-owned on the server; receives a backend tar archive on stdin.

The dedicated Actions SSH key is forced to this entrypoint, with forwarding,
PTY, and arbitrary shell commands disabled. Database credentials stay on-server.
"""
import fcntl
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
import time
import urllib.error
import urllib.request

PROJECT = Path('/opt/supabase')
STATE = Path('/var/lib/autocare-deploy')
MAX_ARCHIVE = 20 * 1024 * 1024
MAX_EXPANDED = 64 * 1024 * 1024


def validate_members(members):
    total = 0
    names = set()
    for member in members:
        path = PurePosixPath(member.name)
        if path.is_absolute() or '..' in path.parts or not member.isfile():
            raise ValueError('Only regular files with relative paths are accepted')
        name = path.as_posix()
        if name in names:
            raise ValueError('Duplicate archive member')
        names.add(name)
        allowed = name == 'release.json'
        allowed |= bool(re.fullmatch(r'supabase/migrations/\d+_[A-Za-z0-9_]+\.sql', name))
        allowed |= name.startswith('supabase/functions/merchant-v1/') and path.suffix in {'.ts', '.json', '.jsonc', '.lock'}
        if not allowed:
            raise ValueError('Unexpected archive member: ' + name)
        total += member.size
        if total > MAX_EXPANDED or len(names) > 1000:
            raise ValueError('Archive exceeds deployment limits')
    if 'release.json' not in names or 'supabase/functions/merchant-v1/index.ts' not in names:
        raise ValueError('Incomplete backend archive')


def run(args, **kwargs):
    return subprocess.run(args, cwd=PROJECT, check=True, **kwargs)


def compose(*args, **kwargs):
    return run(['docker', 'compose', *args], **kwargs)


def sql(statement, *, transaction=False):
    command = ['exec', '-T', 'db', 'psql', '-X', '-U', 'postgres', '-d', 'postgres', '-v', 'ON_ERROR_STOP=1', '-Atq']
    if transaction:
        command.append('--single-transaction')
    return compose(*command, input=statement.encode(), stdout=subprocess.PIPE).stdout.decode().strip()


def literal(value):
    return "'" + value.replace("'", "''") + "'"


def request(environment, body, key=None):
    req = urllib.request.Request(
        environment['SUPABASE_PUBLIC_URL'] + '/functions/v1/merchant-v1',
        data=json.dumps(body).encode(),
        headers={'apikey': key or environment['SUPABASE_PUBLISHABLE_KEY'], 'Content-Type': 'application/json'},
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            return response.status, json.load(response)
    except urllib.error.HTTPError as error:
        return error.code, json.load(error)


def smoke(environment):
    for attempt in range(8):
        try:
            status, body = request(environment, {'action': 'login_password', 'phone': 'invalid'})
            if status == 400 and 'error' in body:
                break
        except (OSError, ValueError):
            pass
        time.sleep(5)
    else:
        raise RuntimeError('merchant-v1 did not become ready')
    for body, expected in [
        ({'action': 'send_mock_code', 'phone': '13900000000'}, 501),
        ({'action': 'register', 'phone': '13900000000'}, 501),
        ({'action': 'list', 'kind': 'services'}, 401),
    ]:
        status, result = request(environment, body)
        if status != expected or 'error' not in result:
            raise RuntimeError('Production auth/mock guard check failed: ' + body['action'])
    print('PASS production function readiness, public login, auth guards, and disabled mocks', flush=True)


def deploy(staging):
    revision = json.loads((staging / 'release.json').read_text())['revision']
    if not re.fullmatch(r'[0-9a-f]{40}', revision):
        raise ValueError('Invalid release revision')
    migrations = sorted((staging / 'supabase/migrations').glob('*.sql'))
    if not migrations:
        raise ValueError('No database migrations')
    versions = [p.name.split('_', 1)[0] for p in migrations]
    if len(versions) != len(set(versions)):
        raise ValueError('Duplicate migration versions')
    environment = dict(line.split('=', 1) for line in (PROJECT / '.env').read_text().splitlines()
                       if line and not line.startswith('#') and '=' in line)
    # Validate history before any migration is applied.
    exists = sql("SELECT to_regclass('autocare_deploy.migrations') IS NOT NULL;") == 't'
    history = {}
    if exists:
        for row in sql('SELECT version,checksum FROM autocare_deploy.migrations ORDER BY version;').splitlines():
            version, checksum = row.split('|')
            history[version] = checksum
    if set(history) - set(versions):
        raise RuntimeError('Release omits previously applied migrations; refusing downgrade')
    for path in migrations:
        version = path.name.split('_', 1)[0]
        checksum = hashlib.sha256(path.read_bytes()).hexdigest()
        if version in history and history[version] != checksum:
            raise RuntimeError('Previously applied migration changed: ' + path.name)
        if version not in history and history and version < max(history):
            raise RuntimeError('New migrations must be newer than existing history')
    if not exists and sql("SELECT to_regclass('supabase_migrations.schema_migrations') IS NOT NULL;") == 't':
        if sql('SELECT count(*) FROM supabase_migrations.schema_migrations;') != '0':
            raise RuntimeError('Existing migration history needs a reviewed checksum baseline')

    print('Backing up before deployment ' + revision, flush=True)
    run(['/usr/local/sbin/supabase-backup'])
    sql('''CREATE SCHEMA IF NOT EXISTS autocare_deploy;
REVOKE ALL ON SCHEMA autocare_deploy FROM PUBLIC,anon,authenticated;
CREATE TABLE IF NOT EXISTS autocare_deploy.migrations(
 version text PRIMARY KEY,checksum text NOT NULL,revision text NOT NULL,applied_at timestamptz NOT NULL DEFAULT now());
CREATE SCHEMA IF NOT EXISTS supabase_migrations;
CREATE TABLE IF NOT EXISTS supabase_migrations.schema_migrations(version text PRIMARY KEY,statements text[],name text);''', transaction=True)
    for path in migrations:
        version, name = path.stem.split('_', 1)
        if version in history:
            continue
        print('Applying ' + path.name, flush=True)
        source = path.read_text(encoding='utf-8')
        checksum = hashlib.sha256(path.read_bytes()).hexdigest()
        sql(source + '\n' +
            'INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES (' +
            ','.join([literal(version), literal(name), 'ARRAY[' + literal(source) + ']']) + ');\n' +
            'INSERT INTO autocare_deploy.migrations(version,checksum,revision) VALUES (' +
            ','.join(map(literal, [version, checksum, revision])) + ');', transaction=True)
    sql("NOTIFY pgrst,'reload schema';")

    # Production settings are explicit and independent from Cloud development.
    override = PROJECT / 'docker-compose.autocare.yml'
    override.write_text('''services:
  functions:
    environment:
      ALLOW_MOCK_SMS: "false"
      ALLOW_MOCK_RECOGNITION: "false"
''')
    files = environment.get('COMPOSE_FILE', 'docker-compose.yml').split(':')
    if override.name not in files:
        files.append(override.name)
    text = (PROJECT / '.env').read_text()
    text = re.sub(r'^COMPOSE_FILE=.*$', 'COMPOSE_FILE=' + ':'.join(files), text, flags=re.M)
    (PROJECT / '.env').write_text(text)
    os.chmod(PROJECT / '.env', 0o600)
    compose('config', '--quiet')

    release = STATE / 'releases' / (revision + '-' + str(time.time_ns()))
    release.mkdir(parents=True, mode=0o700)
    target = PROJECT / 'volumes/functions/merchant-v1'
    next_target = PROJECT / 'volumes/functions/merchant-v1.next'
    if next_target.exists():
        shutil.rmtree(next_target)
    shutil.copytree(staging / 'supabase/functions/merchant-v1', next_target)
    next_target.chmod(0o755)
    for path in next_target.rglob('*'):
        path.chmod(0o755 if path.is_dir() else 0o644)
    previous = release / 'previous-function'
    if target.exists():
        target.rename(previous)
    next_target.rename(target)
    try:
        compose('up', '-d', '--force-recreate', '--wait', '--wait-timeout', '120', 'functions')
        smoke(environment)
    except Exception:
        shutil.rmtree(target)
        if previous.exists():
            previous.rename(target)
        compose('up', '-d', '--force-recreate', '--wait', '--wait-timeout', '120', 'functions')
        print('Function code restored. Applied database migrations were retained; review the pre-deployment backup.', flush=True)
        raise
    metadata = {'revision': revision, 'migrations': len(migrations), 'deployed_at': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())}
    (PROJECT / '.autocare-release.json').write_text(json.dumps(metadata, indent=2) + '\n')
    (release / 'release.json').write_text(json.dumps(metadata) + '\n')
    print('Deployment successful: ' + json.dumps(metadata), flush=True)


def main():
    if os.geteuid() != 0:
        raise RuntimeError('Run through the root-owned deployment entrypoint')
    os.umask(0o077)
    STATE.mkdir(parents=True, exist_ok=True, mode=0o700)
    with (STATE / 'deploy.lock').open('w') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        with tempfile.TemporaryDirectory(prefix='incoming-', dir=STATE) as directory:
            staging = Path(directory)
            archive_path = staging / 'backend.tar.gz'
            total = 0
            with archive_path.open('wb') as destination:
                while chunk := sys.stdin.buffer.read(1024 * 1024):
                    total += len(chunk)
                    if total > MAX_ARCHIVE:
                        raise ValueError('Compressed archive exceeds deployment limit')
                    destination.write(chunk)
            with tarfile.open(archive_path, 'r:gz') as archive:
                validate_members(archive.getmembers())
                for member in archive.getmembers():
                    destination = staging / member.name
                    destination.parent.mkdir(parents=True, exist_ok=True)
                    with archive.extractfile(member) as source, destination.open('wb') as output:
                        shutil.copyfileobj(source, output)
            deploy(staging)


if __name__ == '__main__':
    main()
