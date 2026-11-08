"""Atomically bridge the hosted dev database's two published legacy migrations.

The originals were removed by an earlier merge (PR #9 / commit 7c789ec).
They are archived byte-for-byte, not reintroduced into production's immutable
migration sequence. This tool never deletes or rewrites migration history.
"""
import hashlib
import json
import os
from pathlib import Path
import subprocess
from urllib.parse import unquote, urlparse

ROOT = Path(__file__).resolve().parents[2]
ARCHIVE = Path(__file__).with_name('legacy_inventory')
LEGACY = {
    '202611050001': ('inventory_catalog', '29402a7eedcc217dc6828e89a1b4ebea0cfcdc59d37ba981547c59ac0be7b64c'),
    '202611050002': ('inventory_counts_scan', '7a6aa1d0b7adc49cb0fcaeda7a7c2c4eb905031a67e8cb8716e0023be5f37381'),
}
TARGET = '202611080003'
PROJECT = 'wghsytekrmpcofpugyua'


def literal(value):
    return "'" + value.replace("'", "''") + "'"


def legacy_files():
    result = []
    for version, (name, digest) in LEGACY.items():
        path = ARCHIVE / f'{version}_{name}.sql'
        if hashlib.sha256(path.read_bytes()).hexdigest() != digest:
            raise ValueError('Archived legacy migration changed: ' + version)
        result.append(path)
    return result


def plan(migrations, history):
    local = {p.name.split('_', 1)[0]: p for p in sorted(migrations.glob('*.sql'))}
    remote = {row['version']: row.get('name') for row in history}
    extra = remote.keys() - local.keys()
    if not extra:
        return None
    if extra != LEGACY.keys() or any(remote[v] != LEGACY[v][0] for v in LEGACY):
        raise ValueError('Unrecognized remote migration history; refusing automatic changes')
    legacy_files()
    if TARGET in remote:
        return ''  # Already bridged: just restore CLI history files for this checkout.
    pending = sorted(local.keys() - remote.keys())
    if TARGET not in pending or any(v < '202611060001' for v in pending):
        raise ValueError('Unexpected legacy migration baseline; refusing automatic changes')
    baseline = (migrations / '202611030004_inventory_documents.sql').read_text(encoding='utf-8')
    start = baseline.index('create function public.inventory_document_save(')
    end = baseline.index('end $$;', start) + len('end $$;')
    canonical_save = baseline[start:end].replace('create function', 'create or replace function', 1)
    statements = ["BEGIN; SELECT pg_advisory_xact_lock(hashtextextended('autocare-dev-inventory-bridge',0));"]
    for version in pending:
        path = local[version]
        source = path.read_text(encoding='utf-8').lstrip('\ufeff')
        if version == TARGET:
            statements.extend([ARCHIVE.joinpath('before.sql').read_text(), canonical_save])
        statements.append(source)
        if version == TARGET:
            statements.append(ARCHIVE.joinpath('after.sql').read_text())
        statements.append('INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES (' +
                          ','.join([literal(version), literal(path.stem.split('_', 1)[1]), 'ARRAY[' + literal(source) + ']']) + ');')
    statements.append('COMMIT;')
    return '\n'.join(statements)


def main():
    url = os.environ.get('SUPABASE_DB_URL', '')
    connection = urlparse(url)
    if (os.environ.get('SUPABASE_PROJECT_REF') != PROJECT
            or connection.username != 'postgres.' + PROJECT
            or connection.hostname != 'aws-0-ap-northeast-2.pooler.supabase.com'):
        raise ValueError('This bridge is restricted to the existing hosted development project')
    # Keep passwords out of process arguments and exception messages.
    environment = {**os.environ, 'PGPASSWORD': unquote(connection.password or ''),
                   'PGSSLMODE': 'require', 'PGCONNECT_TIMEOUT': '15'}
    args = ['psql', '--host', connection.hostname, '--port', str(connection.port or 5432),
            '--username', connection.username, '--dbname', unquote(connection.path.lstrip('/')),
            '-X', '-v', 'ON_ERROR_STOP=1', '-Atq']
    def execute(sql, capture=False):
        result = subprocess.run(args, input=sql, text=True, env=environment, capture_output=capture)
        if result.returncode:
            raise RuntimeError('Development inventory bridge SQL failed; no history repair was performed')
        return result.stdout
    # Metadata only: never read merchant/customer records into CI logs or artifacts.
    if execute("SELECT to_regclass('supabase_migrations.schema_migrations') IS NOT NULL;", True).strip() != 't':
        print('No existing migration history; normal deployment will initialize it')
        return
    query = "SELECT coalesce(jsonb_agg(jsonb_build_object('version',version,'name',name)),'[]') FROM supabase_migrations.schema_migrations;"
    history = json.loads(execute(query, True))
    source = plan(ROOT / 'supabase/migrations', history)
    if source is None:
        print('No legacy inventory bridge required')
        return
    if source:
        print('Bridging legacy inventory schema atomically; retaining data and history', flush=True)
        execute(source)
    # These exact historical files exist only in the CI checkout. Supabase CLI
    # sees their already-applied versions and never tries to replay them.
    for path in legacy_files():
        (ROOT / 'supabase/migrations' / path.name).write_bytes(path.read_bytes())
    print('Legacy inventory history reconciled; canonical migrations are applied')


if __name__ == '__main__':
    main()
