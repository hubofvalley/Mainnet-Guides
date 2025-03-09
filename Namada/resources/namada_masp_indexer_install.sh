#!/bin/bash
set -euo pipefail

# Fixed Configuration
WEBSERVER_PORT="8000"
POSTGRES_HOST_PORT="5435"
POSTGRES_DB="masp-indexer"

# Configuration
INDEXER_DIR="$HOME/namada-masp-indexer"
COMPOSE_FILE="$INDEXER_DIR/docker-compose.yml"
ENV_FILE="$INDEXER_DIR/.env"

echo "=== Namada MASP Indexer Deployment ==="

# User Prompts
read -p "Please input RPC URL (leave empty for default): " TENDERMINT_URL
TENDERMINT_URL=${TENDERMINT_URL:-"https://lightnode-rpc-mainnet-namada.grandvalleys.com"}

read -p "Enter your preferred postgres username [masp-user]: " POSTGRES_USER
POSTGRES_USER=${POSTGRES_USER:-masp-user}

POSTGRES_PASSWORD=""
while [[ -z "$POSTGRES_PASSWORD" ]]; do
    read -p "Enter your preferred postgres password (can't be empty): " POSTGRES_PASSWORD
done

# Confirmation
echo -e "\nProceeding with:"
echo "RPC URL: $TENDERMINT_URL"
echo "Webserver Port: $WEBSERVER_PORT"
echo "PostgreSQL:"
echo "  Host Port: $POSTGRES_HOST_PORT"
echo "  Database: $POSTGRES_DB"
echo "  Username: $POSTGRES_USER"
echo "  Password: *********"

read -p "Are you sure you want to proceed? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation cancelled"
    exit 1
fi

# Cleanup existing
echo "Removing previous installation..."
rm -rf "$INDEXER_DIR"
docker compose -f "$COMPOSE_FILE" down --volumes --remove-orphans 2> /dev/null || true

# Clone repository
echo "Cloning namada-masp-indexer..."
git clone https://github.com/anoma/namada-masp-indexer.git "$INDEXER_DIR"
cd "$INDEXER_DIR"

# Create docker-compose.yml
cat > docker-compose.yml <<EOF
services:
  postgres:
    image: postgres:16-alpine
    command: -c 'max_connections=200'
    ports:
      - $POSTGRES_HOST_PORT:5432
    environment:
      POSTGRES_PASSWORD: $POSTGRES_PASSWORD
      POSTGRES_USER: $POSTGRES_USER
      PGUSER: $POSTGRES_USER
      POSTGRES_DB: masp_indexer_local
    healthcheck:
      test: ["CMD-SHELL", "pg_isready", "-d", "masp_indexer_local"]
      interval: 5s
      timeout: 10s
      retries: 5
      start_period: 80s

  block-index:
    image: namada-masp-block-index
    build:
      context: .
      dockerfile: block-index/Dockerfile
    environment:
      COMETBFT_URL: ${COMETBFT_URL}
      DATABASE_URL: postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@postgres:5432/masp_indexer_local
    depends_on:
      postgres:
        condition: service_healthy
    extra_hosts:
      - "host.docker.internal:host-gateway"

  webserver:
    image: namada-masp-webserver
    build:
      context: .
      dockerfile: webserver/Dockerfile
    ports:
      - 5000:5000
    environment:
      PORT: 5000
      DATABASE_URL: postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@postgres:5432/masp_indexer_local
    depends_on:
      - crawler
  
  crawler:
    build:
      context: .
      dockerfile: chain/Dockerfile
    environment:
      COMETBFT_URL: ${COMETBFT_URL}
      DATABASE_URL: postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@postgres:5432/masp_indexer_local
    depends_on:
      postgres:
        condition: service_healthy
    extra_hosts:
      - "host.docker.internal:host-gateway"
EOF

# Create docker-compose-dev.yml
cat > docker-compose-dev.yml <<EOF
version: '3.9'

services:
  postgres:
    image: postgres:16-alpine
    command: -c 'max_connections=200'
    ports:
      - "$POSTGRES_HOST_PORT:5432"
    environment:
      POSTGRES_PASSWORD: "$POSTGRES_PASSWORD"
      POSTGRES_USER: "$POSTGRES_USER"
      PGUSER: "$POSTGRES_USER"
      POSTGRES_DB: "$POSTGRES_DB"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $POSTGRES_USER -d $POSTGRES_DB"]
      interval: 5s
      timeout: 10s
      retries: 5
      start_period: 80s
EOF

# Create environment file
cat > "$ENV_FILE" <<EOF
COMETBFT_URL="$TENDERMINT_URL"
PORT="$WEBSERVER_PORT"
EOF

# Start services with explicit file paths
echo "Starting services..."
docker compose -f "$COMPOSE_FILE" -f "$INDEXER_DIR/docker-compose-dev.yml" --env-file "$ENV_FILE" up -d --pull always

# Final output
echo -e "\nDeployment completed successfully!"
echo "Services:"
echo "- Webserver: http://localhost:$WEBSERVER_PORT"
echo "- PostgreSQL:"
echo "  Host: localhost:$POSTGRES_HOST_PORT"
echo "  Database: $POSTGRES_DB"
echo "  Username: $POSTGRES_USER"
echo "  Password: $POSTGRES_PASSWORD"

echo -e "\nMonitor logs with: docker compose -f $COMPOSE_FILE logs -f"