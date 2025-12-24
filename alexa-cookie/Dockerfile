FROM node:18-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates curl sed awk \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/alexa-cookie

RUN git clone https://github.com/adn77/alexa-cookie-cli.git . \
 && npm install --no-audit --no-fund

EXPOSE 8080

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Optional vaiables:
# - ALEXA_SCRIPT: path to alexa_remote_control.sh inside container (by default: /data/alexa_remote_control.sh)

CMD ["/entrypoint.sh"]