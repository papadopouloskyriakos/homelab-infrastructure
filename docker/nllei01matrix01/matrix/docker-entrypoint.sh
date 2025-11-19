#!/bin/bash
set -e

CONFIG_FILE="${CONFIG_FILE:-config.yaml}"
REGISTRATION_FILE="${REGISTRATION_FILE:-registration.yaml}"
SETUP_MARKER="/config/.setup_done"

cd /app

echo "=== Matrix-Mattermost Bridge Startup ==="
echo "Config: /config/$CONFIG_FILE"
echo "Registration: /config/$REGISTRATION_FILE"

# Check if this is first run (database needs initialization)
if [ ! -f "$SETUP_MARKER" ]; then
  echo ""
  echo "=== FIRST RUN: Initializing database schema ==="
  node build/index.js -c "/config/$CONFIG_FILE" -f "/config/$REGISTRATION_FILE" -s
  
  if [ $? -eq 0 ]; then
    echo "✓ Database initialized successfully"
    touch "$SETUP_MARKER"
  else
    echo "✗ Database initialization failed!"
    exit 1
  fi
else
  echo "✓ Database already initialized"
fi

echo ""
echo "=== Starting bridge ==="
exec node build/index.js -c "/config/$CONFIG_FILE" -f "/config/$REGISTRATION_FILE"
