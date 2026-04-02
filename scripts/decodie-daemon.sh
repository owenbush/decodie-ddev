#!/bin/bash
# Starts the Decodie UI server as a DDEV daemon

# Load env vars (e.g. CLAUDE_API_KEY) if .env exists
# Check .decodie/.env first (shared with decodie-ui and decodie-vscode),
# then .ddev/decodie/.env as a DDEV-specific override
if [ -f /var/www/html/.decodie/.env ]; then
  set -a
  source /var/www/html/.decodie/.env
  set +a
fi
if [ -f /var/www/html/.ddev/decodie/.env ]; then
  set -a
  source /var/www/html/.ddev/decodie/.env
  set +a
fi

cd /var/www/html/.ddev/decodie
exec npx @owenbush/decodie-ui serve --port 8081 --dir /var/www/html --no-open
