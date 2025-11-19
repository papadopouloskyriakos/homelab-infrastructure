cd /srv/matrix

# Update Dockerfile to copy from correct paths
cat > Dockerfile << 'EOF'
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

# Copy patched files from correct locations
COPY matrix-as-mm-src/MatrixClient.js.backup /app/build/matrix/MatrixClient.js
COPY matrix-as-mm-src/MattermostUserStore.js.backup /app/build/mattermost/MattermostUserStore.js
COPY matrix-as-mm-src/MattermostHandler.js.backup /app/build/mattermost/MattermostHandler.js
COPY matrix-as-mm-src/MatrixUserStore.js.backup /app/build/matrix/MatrixUserStore.js
COPY matrix-as-mm-src/MatrixHandler.js.backup /app/build/matrix/MatrixHandler.js

EXPOSE 9995

# Entrypoint
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
EOF