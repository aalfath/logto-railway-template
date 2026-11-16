#!/bin/sh
# Start Logto on Railway: seed the database on first boot, apply schema
# alterations after an upgrade, then start the core (PORT, 3001) and the
# admin console (ADMIN_PORT, 3002).
set -e
cd /etc/logto

: "${DB_URL:?DB_URL is not set (expected a reference to the Postgres service)}"
export PORT="${PORT:-3001}"
export ADMIN_PORT="${ADMIN_PORT:-3002}"
export TRUST_PROXY_HEADER="${TRUST_PROXY_HEADER:-1}"

# Wait for Postgres (it may still be starting on the first deploy).
i=0
until node -e "const u=new URL(process.env.DB_URL);const s=require('net').connect(Number(u.port||5432),u.hostname.replace(/^\\[|\\]$/g,''));s.setTimeout(3000);s.on('connect',()=>process.exit(0));s.on('error',()=>process.exit(1));s.on('timeout',()=>process.exit(1))" 2>/dev/null; do
  i=$((i+1))
  if [ "$i" -ge 60 ]; then echo "Postgres is not reachable after 120 s" >&2; exit 1; fi
  echo "Waiting for Postgres... ($i)"
  sleep 2
done

# --swe: skip when the database is already seeded.
npm run cli db seed -- --swe
# Apply database alterations for this Logto version (no-op when up to date).
npm run alteration deploy latest

exec npm start
