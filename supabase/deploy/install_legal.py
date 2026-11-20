"""Install static legal files and their Caddy route (run as root on production)."""
from datetime import datetime, timezone
from pathlib import Path
import os
import shutil
import subprocess


def install(root):
    if os.geteuid() != 0:
        raise RuntimeError('Run as root')
    caddy = Path('/etc/caddy/Caddyfile')
    snippet = Path('/etc/caddy/autocare-legal.caddy')
    content = caddy.read_text()
    anchor = 'autocare.mymember.ltd {\n'
    include = '\timport /etc/caddy/autocare-legal.caddy\n'
    if content.count(anchor) != 1:
        raise RuntimeError('Inspect Caddy configuration before installing')
    if include not in content:
        content = content.replace(anchor, anchor + include, 1)
    source = root / 'supabase/static/legal'
    files = [(caddy, content.encode()),
             (snippet, (root / 'supabase/deploy/legal.caddy').read_bytes())]
    for name in ['privacy.html', 'terms.html']:
        files.append((Path('/srv/autocare/legal') / name, (source / name).read_bytes()))
    stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
    backup = Path('/var/lib/autocare-deploy') / ('static-legal-' + stamp)
    backup.mkdir(parents=True, mode=0o700)
    previous = []
    for i, (target, _) in enumerate(files):
        saved = backup / str(i)
        if target.exists():
            shutil.copy2(target, saved)
        previous.append((target, saved))
    print('Backup directory: ' + str(backup), flush=True)
    try:
        for directory in [Path('/srv/autocare'), Path('/srv/autocare/legal')]:
            directory.mkdir(parents=True, exist_ok=True)
            directory.chmod(0o755)
        for target, data in files:
            target.write_bytes(data.replace(b'\r\n', b'\n'))
            target.chmod(0o644)
        subprocess.run(['caddy', 'validate', '--config', str(caddy), '--adapter', 'caddyfile'], check=True)
        subprocess.run(['systemctl', 'reload', 'caddy'], check=True)
    except Exception:
        for target, saved in previous:
            if saved.exists():
                shutil.copy2(saved, target)
            else:
                target.unlink(missing_ok=True)
        subprocess.run(['systemctl', 'reload', 'caddy'], check=False)
        raise
    print('Static legal files installed and Caddy reloaded', flush=True)


if __name__ == '__main__':
    install(Path(__file__).resolve().parents[2])
