FROM ubuntu:22.04

WORKDIR /app

RUN apt-get update && \
    apt-get install -y git curl build-essential && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Clone repo and build
RUN git clone https://github.com/mattermost-community/matrix-as-mm.git .
RUN npm ci
RUN npm run build

COPY MatrixClient.js.backup /app/build/matrix/MatrixClient.js
COPY AppService.js.backup /app/build/matrix/AppService.js
COPY MattermostUserStore.js.backup /app/build/mattermost/MattermostUserStore.js
COPY MattermostHandler.js.backup /app/build/mattermost/MattermostHandler.js
COPY MatrixUserStore.js.backup /app/build/matrix/MatrixUserStore.js
COPY MatrixHandler.js.backup /app/build/matrix/MatrixHandler.js


# Copy your completed config.yaml only
COPY matrix-as-mm-config/config.yaml.correct /config/config.yaml

EXPOSE 9995

VOLUME /config /logs /db

# Entrypoint
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
