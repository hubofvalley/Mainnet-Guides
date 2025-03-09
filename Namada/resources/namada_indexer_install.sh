#!/bin/bash
set -e

validate_non_empty() {
    local input="$1"
    local prompt="$2"
    while [[ -z "$input" ]]; do
        read -p "$prompt" input
    done
    echo "$input"
}

read -p "Please input RPC you want to use (leave empty for Grand Valley's RPC): " TENDERMINT_URL
TENDERMINT_URL=${TENDERMINT_URL:-"https://lightnode-rpc-mainnet-namada.grandvalleys.com"}

POSTGRES_USER=$(validate_non_empty "" "Enter postgres username (can't be empty): ")
POSTGRES_PASSWORD=$(validate_non_empty "" "Enter postgres password (can't be empty): ")
CHAIN_ID="namada.5f5de2dd1b88cba30586420"

echo -e "\nProceeding with:
CHAIN_ID: $CHAIN_ID
TENDERMINT_URL: $TENDERMINT_URL
POSTGRES_USER: $POSTGRES_USER
POSTGRES_PASSWORD: *******"

read -p "Confirm to proceed? (y/n) " -n 1 -r
echo
[[ $REPLY =~ ^[Yy]$ ]] || exit 1

cd "$HOME" || exit 1
rm -rf namada-indexer
git clone https://github.com/anoma/namada-indexer.git
cd namada-indexer || exit 1

LATEST_TAG="v2.3.0"
git fetch --all
git checkout "$LATEST_TAG"
git reset --hard "$LATEST_TAG"

# Create custom docker-compose-db.yml
cat > docker-compose-db.yml << EOF
services:
  postgres:
    image: postgres:16-alpine
    command: ["postgres", "-c", "listen_addresses=0.0.0.0", "-c", "max_connections=200", "-p", "5433"]
    expose:
      - "5433"
    ports:
      - "5433:5433"
    environment:
      POSTGRES_PASSWORD: \$POSTGRES_PASSWORD
      POSTGRES_USER: \$POSTGRES_USER
      PGUSER: \$POSTGRES_USER
      POSTGRES_DB: namada-indexer
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U \$POSTGRES_USER -d namada-indexer -h localhost -p 5433"]
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

docker system prune -f

cat > .env << EOF
DATABASE_URL="postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@postgres:5433/namada-indexer"
TENDERMINT_URL="$TENDERMINT_URL"
CHAIN_ID="$CHAIN_ID"
CACHE_URL="redis://dragonfly:6379"
WEBSERVER_PORT="6000"
PORT="6000"
WIPE_DB=false
POSTGRES_PORT=5433
EOF

wget -q https://indexer-snapshot-mainnet-namada.grandvalleys.com/checksums.json || echo "Warning: Failed to download checksums"

docker compose -f docker-compose.yml -f docker-compose-db.yml down --volumes --rmi all
docker compose -f docker-compose.yml -f docker-compose-db.yml up -d --pull always --force-recreate

echo -e "\nInstallation complete. Services running with custom database configuration."