#!/bin/bash
set -euo pipefail

###############################################################################
# Install Required Dependencies
###############################################################################
install_dependencies() {
    echo "=== Checking and installing required dependencies ==="
    install_if_missing() {
        local pkg="$1"; local check="$2"
        if ! command -v "$check" &>/dev/null; then
            echo "Installing $pkg..."
            sudo apt-get update
            sudo apt-get install -y "$pkg"
        fi
    }
    install_if_missing "git" "git"
    install_if_missing "curl" "curl"
    install_if_missing "jq" "jq"
    install_if_missing "wget" "wget"
    install_if_missing "lsb-release" "lsb_release"
    install_if_missing "ca-certificates" "update-ca-certificates"
    install_if_missing "gnupg" "gpg"

    if ! command -v docker &>/dev/null; then
        echo "Installing Docker and Compose plugin..."
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
          | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    fi

    if ! docker compose version &>/dev/null && [ -f /usr/libexec/docker/cli-plugins/docker-compose ]; then
        sudo ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose || true
    fi
}

###############################################################################
# Config
###############################################################################
INDEXER_DIR="$HOME/namada-masp-indexer"
COMPOSE_FILE="${INDEXER_DIR}/docker-compose.yml"
ENV_FILE="${INDEXER_DIR}/.env"
WEBSERVER_PORT="8000"
PROJECT_NAME="namada-masp"

stop_and_clean() {
    echo "=== Cleaning existing deployment ==="
    docker compose -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" down --volumes --remove-orphans --timeout 30 || true
    docker rm -f $(docker ps -aq --filter "name=${PROJECT_NAME}-*") 2>/dev/null || true
    docker rmi -f $(docker images -q "namada-masp-*") 2>/dev/null || true
    docker volume rm -f $(docker volume ls -q --filter "name=${PROJECT_NAME}-*") 2>/dev/null || true
}

deploy() {
    echo "=== Deploying MASP Indexer ==="
    rm -rf "$INDEXER_DIR"
    git clone https://github.com/anoma/namada-masp-indexer.git "$INDEXER_DIR"
    cd "$INDEXER_DIR"
    git checkout tags/v1.2.0

    read -p "Please input RPC you want to use (leave empty for Grand Valley's RPC): " input_rpc
    TENDERMINT_URL="${input_rpc:-https://lightnode-rpc-mainnet-namada.grandvalleys.com}"

    cat > "${ENV_FILE}" <<EOF
COMETBFT_URL="${TENDERMINT_URL}"
PORT="${WEBSERVER_PORT}"
EOF

    docker compose -f "${COMPOSE_FILE}" --env-file "${ENV_FILE}" up -d --pull always --build --force-recreate
}

verify_deployment() {
    echo "=== Verifying Deployment ==="
    local web_status=$(docker compose -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" ps -q webserver)
    [[ -n "$web_status" ]] || { echo "? Webserver container not running!"; exit 1; }

    echo "? Services Running:"
    docker compose -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" ps
    echo -e "\nWebserver: http://localhost:${WEBSERVER_PORT}"
    echo "PostgreSQL: localhost:5432"
}

main() {
    install_dependencies
    docker info >/dev/null 2>&1 || { echo "? Docker daemon not running."; exit 1; }
    stop_and_clean
    deploy
    verify_deployment
    echo -e "\n? MASP Indexer deployed successfully."
}

main
