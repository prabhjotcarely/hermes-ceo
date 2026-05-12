#!/bin/bash
set -e
mkdir -p /data

# Write SOUL.md with credentials injected (same as SKILL.md injection)
SUPABASE_KEY="${SUPABASE_SERVICE_KEY}"
AMMY_TOKEN="${AMMY_BOT_TOKEN}"
HERMES_TOKEN="${TELEGRAM_TJ_HermesBOT_TOKEN}"
SENDGRID_KEY="${SENDGRID_API_KEY}"
sed \
  -e "s|\${SUPABASE_SERVICE_KEY}|${SUPABASE_KEY}|g" \
  -e "s|\${AMMY_BOT_TOKEN}|${AMMY_TOKEN}|g" \
  -e "s|\${TELEGRAM_TJ_HermesBOT_TOKEN}|${HERMES_TOKEN}|g" \
  -e "s|\${SENDGRID_API_KEY}|${SENDGRID_KEY}|g" \
  /opt/carely/soul.md > /data/SOUL.md
echo "[Hermes] SOUL.md written with credentials injected"

# Write config.yaml (always update)
cp /opt/carely/config.yaml /data/config.yaml
echo "[Hermes] config.yaml written"

# Install carely-ceo skill with real credentials injected
mkdir -p /data/skills/carely-ceo
SUPABASE_KEY="${SUPABASE_SERVICE_KEY}"
AMMY_TOKEN="${AMMY_BOT_TOKEN:-${AMMY_BOT_TOKEN}}"
GITHUB_TOK="${GITHUB_TOKEN}"
STRIPE_KEY="${STRIPE_SECRET_KEY}"
SENDGRID_KEY="${SENDGRID_API_KEY}"

sed \
  -e "s|\${SUPABASE_SERVICE_KEY}|${SUPABASE_KEY}|g" \
  -e "s|\${AMMY_BOT_TOKEN}|${AMMY_TOKEN}|g" \
  -e "s|\${GITHUB_TOKEN}|${GITHUB_TOK}|g" \
  -e "s|\${STRIPE_SECRET_KEY}|${STRIPE_KEY}|g" \
  -e "s|\${SENDGRID_API_KEY}|${SENDGRID_KEY}|g" \
  /opt/carely/skills/carely-ceo/SKILL.md > /data/skills/carely-ceo/SKILL.md
echo "[Hermes] carely-ceo skill installed with credentials"

# Install cron jobs with real bot token injected
mkdir -p /data/cron
HERMES_TOKEN="${TELEGRAM_TJ_HermesBOT_TOKEN}"
sed \
  -e "s|HERMES_BOT_TOKEN_PLACEHOLDER|${HERMES_TOKEN}|g" \
  /opt/carely/cron/jobs.json > /data/cron/jobs.json
echo "[Hermes] cron jobs installed"

# Write .env from Railway env vars
cat > /data/.env << EOF
OPENROUTER_API_KEY=${OPENROUTER_API_KEY}
TELEGRAM_TJ_HermesBOT_TOKEN=${TELEGRAM_TJ_HermesBOT_TOKEN}
TELEGRAM_ALLOWED_USERS=${TELEGRAM_ALLOWED_USERS:-6941650038,8757842275}
TELEGRAM_HOME_CHANNEL=${TELEGRAM_HOME_CHANNEL:-6941650038}
TELEGRAM_HOME_CHANNEL_NAME=${TELEGRAM_HOME_CHANNEL_NAME:-TJ}
TELEGRAM_TJ_CHAT_ID=6941650038
TELEGRAM_PRABH_CHAT_ID=8757842275
CARELY_BACKEND_URL=https://carely-backend-production.up.railway.app
CARELY_ADMIN_SECRET=${CARELY_ADMIN_SECRET:-carely-admin-6add43330d2313d8}
SUPABASE_URL=https://iaxcdasluigpwiydcxle.supabase.co
SUPABASE_SERVICE_KEY=${SUPABASE_SERVICE_KEY}
GITHUB_TOKEN=${GITHUB_TOKEN}
STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY}
SENDGRID_API_KEY=${SENDGRID_API_KEY}
OPENAI_API_KEY=${OPENAI_API_KEY}
WEB_TOOLS_DEBUG=false
EOF
echo "[Hermes] .env written"

export HERMES_HOME=/data
exec hermes gateway run --replace
