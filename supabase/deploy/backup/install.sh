#!/bin/bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo 'Run this installer with sudo bash supabase/deploy/backup/install.sh.' >&2
  exit 1
fi

source_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ ! -f /opt/supabase/docker-compose.yml || ! -f /opt/supabase/.env || ! -d /opt/supabase/volumes/storage ]]; then
  echo 'Initialize Supabase in /opt/supabase, including its .env and local Storage directory, before installing backups.' >&2
  exit 1
fi
docker volume inspect supabase_db-config >/dev/null
bash -n "$source_dir/supabase-backup"

install -d -o root -g root -m 700 /var/backups/supabase
install -o root -g root -m 700 "$source_dir/supabase-backup" /usr/local/sbin/supabase-backup
install -o root -g root -m 644 "$source_dir/supabase-backup.service" /etc/systemd/system/supabase-backup.service
install -o root -g root -m 644 "$source_dir/supabase-backup.timer" /etc/systemd/system/supabase-backup.timer
systemctl daemon-reload
systemctl enable --now supabase-backup.timer
echo 'Backup script installed; the timer runs daily at 03:30 in the server time zone.'
