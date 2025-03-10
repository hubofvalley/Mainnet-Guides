#!/bin/bash
set -e

###############################################################################
# Function to ensure input is not empty
###############################################################################
validate_non_empty() {
    local input="$1"
    local prompt="$2"
    while [[ -z "$input" ]]; do
        read -p "$prompt" input
    done
    echo "$input"
}

###############################################################################
# Interactive Input Section
###############################################################################
# Prompt for Tendermint RPC URL; if left empty, use Grand Valley's default
read -p "Please input RPC you want to use (leave empty for Grand Valley's RPC): " input_tendermint_url
TENDERMINT_URL_INPUT="${input_tendermint_url:-https://lightnode-rpc-mainnet-namada.grandvalleys.com}"

# Capture PostgreSQL credentials from the user
POSTGRES_USER=$(validate_non_empty "" "Enter postgres username (can't be empty): ")
POSTGRES_PASSWORD=$(validate_non_empty "" "Enter postgres password (can't be empty): ")

###############################################################################
# Export Environment Variables (Non-interactive defaults + user inputs)
###############################################################################
export WIPE_DB=${WIPE_DB:-false}
export POSTGRES_PORT="5433"
export DATABASE_URL="postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:$POSTGRES_PORT/namada-indexer"
export TENDERMINT_URL="$TENDERMINT_URL_INPUT"
export CHAIN_ID="namada.5f5de2dd1b88cba30586420"
export CACHE_URL="redis://dragonfly:6379"
export WEBSERVER_PORT="6000"
export PORT="$WEBSERVER_PORT"

echo -e "\nProceeding with:
CHAIN_ID: $CHAIN_ID
TENDERMINT_URL: $TENDERMINT_URL
POSTGRES_USER: $POSTGRES_USER
POSTGRES_PASSWORD: *******"

read -p "Confirm to proceed? (y/n) " -n 1 -r
echo
[[ $REPLY =~ ^[Yy]$ ]] || exit 1

###############################################################################
# Clone and Prepare the Namada Indexer Repository
###############################################################################
cd "$HOME" || exit 1
rm -rf namada-indexer
git clone https://github.com/anoma/namada-indexer.git
cd namada-indexer || exit 1

LATEST_TAG="v2.3.0"
git fetch --all
git checkout "$LATEST_TAG"
git reset --hard "$LATEST_TAG"

###############################################################################
# Generate docker-compose-db.yml using the exported environment variables
###############################################################################
cat > docker-compose-db.yml << EOF
services:
  postgres:
    image: postgres:16-alpine
    command: ["postgres", "-c", "listen_addresses=0.0.0.0", "-c", "max_connections=200", "-p", "$POSTGRES_PORT"]
    expose:
      - "$POSTGRES_PORT"
    ports:
      - "$POSTGRES_PORT:$POSTGRES_PORT"
    environment:
      POSTGRES_PASSWORD: $POSTGRES_PASSWORD
      POSTGRES_USER: $POSTGRES_USER
      PGUSER: $POSTGRES_USER
      POSTGRES_DB: namada-indexer
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $POSTGRES_USER -d namada-indexer -h localhost -p $POSTGRES_PORT"]
      interval: 5s
      timeout: 5s
      retries: 5
    restart: unless-stopped
    volumes:
      - type: volume
        source: postgres-data
        target: /var/lib/postgresql/data

  dragonfly:
    image: docker.dragonflydb.io/dragonflydb/dragonfly
    command: --logtostderr --cache_mode=true --port 6379 -dbnum 1
    ulimits:
      memlock: -1
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD-SHELL", "redis-cli ping | grep PONG"]
      interval: 5s
      timeout: 5s
      retries: 5
    restart: unless-stopped

volumes:
  postgres-data:
EOF

# Clean up unused Docker objects
docker system prune -f

###############################################################################
# Create .env file using the exported environment variables
###############################################################################
cat > .env << EOF
DATABASE_URL="$DATABASE_URL"
TENDERMINT_URL="$TENDERMINT_URL"
CHAIN_ID="$CHAIN_ID"
CACHE_URL="$CACHE_URL"
WEBSERVER_PORT="$WEBSERVER_PORT"
PORT="$PORT"
WIPE_DB="$WIPE_DB"
POSTGRES_PORT="$POSTGRES_PORT"
EOF

INDEXER_DIR="$HOME/namada-indexer"
ENV_FILE="${INDEXER_DIR}/.env"

# Optionally download snapshot checksums (warn if fails)
wget -q https://indexer-snapshot-mainnet-namada.grandvalleys.com/checksums.json || echo "Warning: Failed to download checksums"

# Stop and remove any existing containers/images related to namada-indexer
docker stop $(docker container ls --all | grep 'namada-indexer' | awk '{print $1}') || true
docker container rm --force $(docker container ls --all | grep 'namada-indexer' | awk '{print $1}') || true
docker image rm --force $(docker image ls --all | grep -E '^namada/.*-indexer.*$' | awk '{print $3}') || true
docker image rm --force $(docker image ls --all | grep '<none>' | awk '{print $3}') || true

# Bring up the services using docker-compose with the generated .env file.
docker compose -f docker-compose.yml --env-file $ENV_FILE up -d --pull always --force-recreate

echo -e "\nInstallation complete. Services are running with the custom database configuration."
