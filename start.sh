#!/bin/bash
set -e
mkdir -p /data

# Write SOUL.md if not present (first boot)
if [ ! -f /data/SOUL.md ]; then
  cp /opt/carely/soul.md /data/SOUL.md
  echo "[Hermes] SOUL.md written to /data"
fi

# Always write config.yaml (picks up model changes on redeploy)
cp /opt/carely/config.yaml /data/config.yaml
echo "[Hermes] config.yaml written"

# Write .env from Railway env vars
cat > /data/.env << EOF
OPENROUTER_API_KEY=${OPENROUTER_API_KEY}
TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
TELEGRAM_ALLOWED_USERS=${TELEGRAM_ALLOWED_USERS:-6941650038,8757842275}
TELEGRAM_HOME_CHANNEL=${TELEGRAM_HOME_CHANNEL:-6941650038}
TELEGRAM_HOME_CHANNEL_NAME=${TELEGRAM_HOME_CHANNEL_NAME:-TJ}
GITHUB_TOKEN=${GITHUB_TOKEN}
WEB_TOOLS_DEBUG=false
EOF
echo "[Hermes] .env written"

export HERMES_HOME=/data
exec hermes gateway run --replace
