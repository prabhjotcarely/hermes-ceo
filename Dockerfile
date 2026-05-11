FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1
ENV HERMES_HOME=/data
ENV PATH="/data/.local/bin:$PATH"

RUN apt-get update && apt-get install -y --no-install-recommends \
    git ripgrep curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install hermes-agent with Telegram support
RUN pip install --no-cache-dir \
    "hermes-agent[messaging] @ git+https://github.com/NousResearch/hermes-agent.git"

# Carely config and assets
RUN mkdir -p /opt/carely/skills/carely-ceo /opt/carely/cron
COPY soul.md /opt/carely/soul.md
COPY config.yaml /opt/carely/config.yaml
COPY skills/carely-ceo/SKILL.md /opt/carely/skills/carely-ceo/SKILL.md
COPY cron/jobs.json /opt/carely/cron/jobs.json
COPY start.sh /start.sh
RUN chmod +x /start.sh

VOLUME ["/data"]
CMD ["/start.sh"]
