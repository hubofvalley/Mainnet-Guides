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

# -------------------------------
# Docker + Compose Plugin Setup
# -------------------------------
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker and Compose plugin from Docker’s official APT repo..."

    install_if_missing "ca-certificates" "update-ca-certificates"
    install_if_missing "curl" "curl"
    install_if_missing "gnupg" "gpg"
    install_if_missing "lsb-release" "lsb_release"

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    if ! grep -q "download.docker.com" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
          https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
          | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    fi

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
                            docker-buildx-plugin docker-compose-plugin
else
    echo "Docker is already installed."
fi

if ! docker compose version &>/dev/null; then
    echo "Trying to manually link docker compose plugin..."
    if [ -f /usr/libexec/docker/cli-plugins/docker-compose ]; then
        sudo ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose || true
    fi
fi

if ! docker --version &>/dev/null || ! docker compose version &>/dev/null; then
    echo "❌ Docker or docker compose is still missing. Please install manually and retry."
    exit 1
else
    echo "✅ Docker and docker compose are available."
fi

if ! pgrep -f dockerd > /dev/null; then
    echo "Docker is not running. Attempting to start it..."
    sudo systemctl start docker || sudo service docker start || echo "Please start Docker manually."
fi

if ! groups "$USER" | grep -q '\bdocker\b'; then
    echo "Adding $USER to docker group..."
    sudo usermod -aG docker "$USER"
    echo "Please log out and back in for group changes to take effect."
fi

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
read -p "Please input RPC you want to use (leave empty for Grand Valley's RPC): " input_tendermint_url
TENDERMINT_URL_INPUT="${input_tendermint_url:-https://lightnode-rpc-mainnet-namada.grandvalleys.com}"

POSTGRES_PASSWORD=$(validate_non_empty "" "Enter postgres password (can't be empty): ")

###############################################################################
# Export Environment Variables
###############################################################################
export POSTGRES_PASSWORD
export WIPE_DB=${WIPE_DB:-false}
export POSTGRES_PORT="5432"
export DATABASE_URL="postgres://postgres:${POSTGRES_PASSWORD}@postgres:$POSTGRES_PORT/namada-indexer"
export TENDERMINT_URL="$TENDERMINT_URL_INPUT"
export CHAIN_ID="namada.5f5de2dd1b88cba30586420"
export CACHE_URL="redis://dragonfly:6379"
export WEBSERVER_PORT="6000"
export PORT="$WEBSERVER_PORT"

echo -e "\nProceeding with:
CHAIN_ID: $CHAIN_ID
TENDERMINT_URL: $TENDERMINT_URL
POSTGRES_USER: postgres
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

LATEST_TAG="v3.1.0"
git fetch --all
git checkout "$LATEST_TAG"
git reset --hard "$LATEST_TAG"

###############################################################################
# Fix the postgres-data to postgres_data in the docker-compose.yml file
###############################################################################
sed -i 's/postgres-data/postgres_data/g' $HOME/namada-indexer/docker-compose.yml

docker system prune -f

###############################################################################
# Create .env file
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
POSTGRES_PASSWORD="$POSTGRES_PASSWORD"
EOF

INDEXER_DIR="$HOME/namada-indexer"
ENV_FILE="${INDEXER_DIR}/.env"

wget -q https://indexer-snapshot-mainnet-namada.grandvalleys.com/checksums.json || echo "Warning: Failed to download checksums"

###############################################################################
# Delete existing Namada Indexer stack ONLY
###############################################################################

# Bring down the Namada Indexer docker-compose project (with associated volumes and images)
docker compose -p namada-indexer down --volumes --remove-orphans --rmi all 2>/dev/null

# Stop and remove all containers whose names start with "namada-indexer-"
docker stop $(docker ps -a --filter "name=^/namada-indexer-" --format "{{.ID}}") 2>/dev/null || true
docker rm -f $(docker ps -a --filter "name=^/namada-indexer-" --format "{{.ID}}") 2>/dev/null || true

# Remove all images matching "namada/*-indexer"
docker rmi -f $(docker images "namada/*-indexer" --format "{{.ID}}") 2>/dev/null || true

# Remove any <none> (dangling) images
docker rmi -f $(docker images -f "dangling=true" -q) 2>/dev/null || true

# Prune volumes associated with this compose project
docker volume prune -f --filter "label=com.docker.compose.project=namada-indexer" 2>/dev/null

###############################################################################
# Start Docker Compose in Steps to Save RAM
###############################################################################
echo -e "🚀 Starting services step-by-step to avoid memory overload..."

docker compose -f $HOME/namada-indexer/docker-compose.yml --env-file "$ENV_FILE" build postgres
sleep 10

docker compose -f $HOME/namada-indexer/docker-compose.yml --env-file "$ENV_FILE" build dragonfly
sleep 5

docker compose -f $HOME/namada-indexer/docker-compose.yml --env-file "$ENV_FILE" build chain governance pos
sleep 5

docker compose -f $HOME/namada-indexer/docker-compose.yml --env-file "$ENV_FILE" build rewards parameters transactions
sleep 5

docker compose -f $HOME/namada-indexer/docker-compose.yml --env-file "$ENV_FILE" build webserver
sleep 5

docker compose -f $HOME/namada-indexer/docker-compose.yml --env-file "$ENV_FILE" up -d

echo -e "✅ Installation complete. Services are running with the custom database configuration."
