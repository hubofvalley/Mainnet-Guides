#!/bin/bash
set -e

###############################################################################
# Install Required Dependencies
###############################################################################
echo "Checking and installing required dependencies..."

install_if_missing() {
    local pkg_name="$1"
    local cmd_check="$2"
    if ! command -v "$cmd_check" &> /dev/null; then
        echo "Installing $pkg_name..."
        if [ -f /etc/debian_version ]; then
            sudo apt-get update
            sudo apt-get install -y "$pkg_name"
        elif [ -f /etc/redhat-release ]; then
            sudo yum install -y "$pkg_name"
        else
            echo "Unsupported OS. Please install $pkg_name manually."
            exit 1
        fi
    else
        echo "$pkg_name is already installed."
    fi
}

install_if_missing "git" "git"
install_if_missing "jq" "jq"
install_if_missing "wget" "wget"
install_if_missing "curl" "curl"
install_if_missing "lsb-release" "lsb_release"
install_if_missing "ca-certificates" "update-ca-certificates"
install_if_missing "gnupg" "gpg"

if ! command -v docker &> /dev/null; then
    echo "Installing Docker and Compose plugin from Docker’s official APT repo..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
      | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

if ! docker compose version &>/dev/null && [ -f /usr/libexec/docker/cli-plugins/docker-compose ]; then
    sudo ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose || true
fi

if ! docker --version &>/dev/null || ! docker compose version &>/dev/null; then
    echo "? Docker or docker compose is still missing. Please install manually and retry."
    exit 1
fi

if ! groups "$USER" | grep -q '\bdocker\b'; then
    echo "Adding $USER to docker group..."
    sudo usermod -aG docker "$USER"
    echo "Please log out and back in for group changes to take effect."
fi

###############################################################################
# Interactive Input
###############################################################################
read -p "Please input RPC you want to use (leave empty for Grand Valley's RPC): " input_tendermint_url
TENDERMINT_URL_INPUT="${input_tendermint_url:-https://lightnode-rpc-mainnet-namada.grandvalleys.com}"

POSTGRES_USER=$(read -p "Enter postgres username (can't be empty): " var; echo $var)
while [[ -z "$POSTGRES_USER" ]]; do
    read -p "Enter postgres username (can't be empty): " POSTGRES_USER
done

POSTGRES_PASSWORD=$(read -p "Enter postgres password (can't be empty): " var; echo $var)
while [[ -z "$POSTGRES_PASSWORD" ]]; do
    read -p "Enter postgres password (can't be empty): " POSTGRES_PASSWORD
done

###############################################################################
# Env Vars
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
# Clone & Setup
###############################################################################
cd "$HOME" || exit 1
rm -rf namada-indexer
git clone https://github.com/anoma/namada-indexer.git
cd namada-indexer
git checkout tags/v2.3.0

###############################################################################
# Docker Compose Files
###############################################################################
cat > docker-compose-db.yml << EOF
services:
  postgres:
    image: postgres:16-alpine
    command: ["postgres", "-c", "listen_addresses=0.0.0.0", "-c", "max_connections=200", "-p", "$POSTGRES_PORT"]
    ports:
      - "$POSTGRES_PORT:$POSTGRES_PORT"
    environment:
      POSTGRES_PASSWORD: $POSTGRES_PASSWORD
      POSTGRES_USER: $POSTGRES_USER
      PGUSER: $POSTGRES_USER
      POSTGRES_DB: namada-indexer
    restart: unless-stopped
    volumes:
      - type: volume
        source: postgres-data
        target: /var/lib/postgresql/data
  dragonfly:
    image: docker.dragonflydb.io/dragonflydb/dragonfly
    command: --logtostderr --cache_mode=true --port 6379 -dbnum 1
    ports:
      - "6379:6379"
    restart: unless-stopped
volumes:
  postgres-data:
EOF

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

###############################################################################
# Clean Previous Resources
###############################################################################
docker rm -f $(docker ps -aq --filter "name=namada-indexer") 2>/dev/null || true
docker rmi -f $(docker images -q --filter=reference='namada/*-indexer*') 2>/dev/null || true
docker rmi -f $(docker images -q --filter "dangling=true") 2>/dev/null || true

###############################################################################
# Launch
###############################################################################
docker compose -f docker-compose.yml --env-file .env up -d --pull always --force-recreate
echo -e "\n? Namada Indexer is running."
