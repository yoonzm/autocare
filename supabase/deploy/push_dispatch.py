"""Production push worker timer. Credentials stay on the host."""
import json
from pathlib import Path
import shutil
import subprocess
import sys
import urllib.request

PROJECT = Path('/opt/supabase')


def run():
    env = dict(line.split('=', 1) for line in (PROJECT / '.env').read_text().splitlines()
               if '=' in line and not line.lstrip().startswith('#'))
    key = env['SERVICE_ROLE_KEY'].strip().strip('\"\'')
    url = env['SUPABASE_PUBLIC_URL'].strip().strip('\"\'').rstrip('/')
    req = urllib.request.Request(url + '/functions/v1/merchant-v1',
        data=b'{"action":"push_dispatch_run"}',
        headers={'Content-Type': 'application/json', 'apikey': key, 'Authorization': 'Bearer ' + key})
    with urllib.request.urlopen(req, timeout=50) as response:
        result = json.load(response)
        item = result.get('item', {})
        if result.get('ok') is not True or item.get('reason') or item.get('failed', 0):
            raise RuntimeError('Push dispatch did not succeed')
        print('Push dispatch claimed:', item.get('claimed', 0),
              'sent:', item.get('sent', 0), 'skipped:', item.get('skipped', 0))


def install():
    target = Path('/usr/local/lib/autocare/push_dispatch.py')
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(__file__, target)
    target.chmod(0o700)
    Path('/etc/systemd/system/autocare-push-dispatch.service').write_text('''[Unit]
Description=AutoCare iOS push outbox dispatcher
After=network-online.target docker.service
[Service]
Type=oneshot
ExecStart=/usr/bin/python3 /usr/local/lib/autocare/push_dispatch.py
TimeoutStartSec=55
User=root
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
''')
    Path('/etc/systemd/system/autocare-push-dispatch.timer').write_text('''[Unit]
Description=Dispatch AutoCare push notifications every minute
[Timer]
OnCalendar=*-*-* *:*:00
AccuracySec=1s
Persistent=true
[Install]
WantedBy=timers.target
''')
    subprocess.run(['systemctl', 'daemon-reload'], check=True)
    subprocess.run(['systemctl', 'enable', '--now', 'autocare-push-dispatch.timer'], check=True)


if __name__ == '__main__':
    if sys.argv[1:] == ['--install']:
        install()
    elif not sys.argv[1:]:
        try:
            run()
        except Exception:
            print('Push dispatch invocation failed', file=sys.stderr)
            sys.exit(1)
    else:
        sys.exit('Usage: push_dispatch.py [--install]')
