#!/bin/sh
set -e
export NOTMUCH_PATH="${NOTMUCH_PATH:-/app/mail}"
export NOTMUCH_CONFIG="${NOTMUCH_CONFIG:-/app/notmuch-config}"
mkdir -p "/app/mail"
if [ -n "$(ls -A /mail 2>/dev/null)" ]; then
  rsync -a /mail/ /app/mail/
fi
# Build or update notmuch index (creates /app/mail/.notmuch when missing)
notmuch new
# Re-sync and re-index in the background every hour (see original article)
{
  while true; do
    sleep 3600
    if [ -n "$(ls -A /mail 2>/dev/null)" ]; then
      rsync -a --delete /mail/ /app/mail/ || true
    fi
    notmuch new || true
  done
} &
exec gunicorn -b 0.0.0.0:5000 -w 2 --threads 2 netviel.wsgi:app
