#!/bin/bash
set -e
mkdir -p /data

# Write SOUL.md with credentials injected
sed \
  -e "s|\${SUPABASE_SERVICE_KEY}|${SUPABASE_SERVICE_KEY}|g" \
  -e "s|\${AMMY_BOT_TOKEN}|${AMMY_BOT_TOKEN}|g" \
  -e "s|\${TELEGRAM_TJ_HermesBOT_TOKEN}|${TELEGRAM_TJ_HermesBOT_TOKEN}|g" \
  -e "s|\${SENDGRID_API_KEY}|${SENDGRID_API_KEY}|g" \
  /opt/carely/soul.md > /data/SOUL.md
echo "[Hermes] SOUL.md written with credentials injected"

# Generate config.yaml dynamically -- HERMES_DEFAULT_MODEL overrides without Docker rebuild
ACTIVE_MODEL="${HERMES_DEFAULT_MODEL:-deepseek/deepseek-chat-v3-0324}"
echo "[Hermes] Using model: $ACTIVE_MODEL"

cat > /data/config.yaml << YAML
model:
  default: $ACTIVE_MODEL
  provider: openrouter
  api_mode: chat_completions
  max_tokens: 4096
  api_max_retries: 1
terminal:
  backend: local
  cwd: /data
  timeout: 120
  lifetime_seconds: 300
compression:
  enabled: true
  threshold: 0.7
  target_ratio: 0.3
  protect_last_n: 10
  summary_model: $ACTIVE_MODEL
  summary_provider: openrouter
memory:
  memory_enabled: true
  user_profile_enabled: true
  memory_char_limit: 2200
  user_char_limit: 1375
  nudge_interval: 50
  flush_min_turns: 30
session_reset:
  mode: both
  idle_minutes: 1440
  at_hour: 4
streaming:
  enabled: false
agent:
  max_turns: 20
delegation:
  model: anthropic/claude-sonnet-4-6
  provider: openrouter
  max_iterations: 10
  verbose: false
skills:
  creation_nudge_interval: 15
platform_toolsets:
  telegram:
  - hermes-telegram
display:
  compact: false
  tool_progress: none
  interim_assistant_messages: false
  show_reasoning: false
  streaming: false
YAML
echo "[Hermes] config.yaml written (model: $ACTIVE_MODEL)"

# Install carely-ceo skill with real credentials injected
mkdir -p /data/skills/carely-ceo
sed \
  -e "s|\${SUPABASE_SERVICE_KEY}|${SUPABASE_SERVICE_KEY}|g" \
  -e "s|\${AMMY_BOT_TOKEN}|${AMMY_BOT_TOKEN}|g" \
  -e "s|\${GITHUB_TOKEN}|${GITHUB_TOKEN}|g" \
  -e "s|\${STRIPE_SECRET_KEY}|${STRIPE_SECRET_KEY}|g" \
  -e "s|\${SENDGRID_API_KEY}|${SENDGRID_API_KEY}|g" \
  /opt/carely/skills/carely-ceo/SKILL.md > /data/skills/carely-ceo/SKILL.md
echo "[Hermes] carely-ceo skill installed with credentials"

# Install cron jobs with real bot token injected
mkdir -p /data/cron
sed \
  -e "s|HERMES_BOT_TOKEN_PLACEHOLDER|${TELEGRAM_TJ_HermesBOT_TOKEN}|g" \
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
