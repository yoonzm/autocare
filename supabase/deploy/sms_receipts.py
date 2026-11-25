"""Production host timer. Reuses server .env credentials; never prints them."""
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
        data=b'{"action":"sms_receipts_run"}',
        headers={'Content-Type': 'application/json', 'apikey': key, 'Authorization': 'Bearer ' + key})
    with urllib.request.urlopen(req, timeout=45) as response:
        result = json.load(response)
        if result.get('ok') is not True:
            raise RuntimeError('SMS receipt worker did not succeed')
        item = result.get('item', {})
        print('SMS receipts pulled:', item.get('pulled', 0), 'updated:', item.get('updated', 0))

def install():
    target = Path('/usr/local/lib/autocare/sms_receipts.py')
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(__file__, target)
    target.chmod(0o700)
    Path('/etc/systemd/system/autocare-sms-receipts.service').write_text('''[Unit]
Description=AutoCare SMS delivery receipt puller
After=network-online.target docker.service
[Service]
Type=oneshot
ExecStart=/usr/bin/python3 /usr/local/lib/autocare/sms_receipts.py
TimeoutStartSec=55
User=root
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
''')
    Path('/etc/systemd/system/autocare-sms-receipts.timer').write_text('''[Unit]
Description=Pull AutoCare SMS delivery receipts every minute
[Timer]
OnCalendar=*-*-* *:*:00
AccuracySec=1s
Persistent=true
[Install]
WantedBy=timers.target
''')
    subprocess.run(['systemctl', 'daemon-reload'], check=True)
    subprocess.run(['systemctl', 'enable', '--now', 'autocare-sms-receipts.timer'], check=True)

if __name__ == '__main__':
    if sys.argv[1:] == ['--install']:
        install()
    elif not sys.argv[1:]:
        try:
            run()
        except Exception:
            # HTTP exception details can contain operational data; journal only the failure class.
            print('SMS receipt invocation failed', file=sys.stderr)
            sys.exit(1)
    else:
        sys.exit('Usage: sms_receipts.py [--install]')
