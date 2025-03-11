#!/bin/bash
set -euo pipefail

# Configuration
INDEXER_DIR="$HOME/namada-masp-indexer"
COMPOSE_FILE="${INDEXER_DIR}/docker-compose.yml"
ENV_FILE="${INDEXER_DIR}/.env"
WEBSERVER_PORT="8000"
PROJECT_NAME="namada-masp"

# Error handling and cleanup
trap 'echo "Error occurred at line $LINENO. Aborting."; exit 1' ERR

stop_and_clean() {
    echo "=== Cleaning existing deployment ==="
    
    # Stop and remove compose-managed resources
    if docker compose ls | grep -q "${PROJECT_NAME}"; then
        echo "Stopping compose project..."
        docker compose -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" down --volumes --remove-orphans --timeout 30
    fi

    # Clean any lingering containers
    local containers=$(docker ps -aq --filter "name=${PROJECT_NAME}-*")
    if [[ -n "$containers" ]]; then
        echo "Removing orphaned containers..."
        docker rm -f "$containers" || true
    fi

    # Clean existing images
    local images=$(docker images -q "namada-masp-*")
    if [[ -n "$images" ]]; then
        echo "Removing existing images..."
        docker rmi -f "$images" || true
    fi

    # Clean volumes
    local volumes=$(docker volume ls -q --filter "name=${PROJECT_NAME}-*")
    if [[ -n "$volumes" ]]; then
        echo "Removing volumes..."
        docker volume rm -f "$volumes" || true
    fi
}

deploy() {
    echo "=== Deploying new instance ==="
    
    # Clean previous installation
    rm -rf "${INDEXER_DIR}" || true
    
    # Clone fresh repository
    git clone https://github.com/anoma/namada-masp-indexer.git "${INDEXER_DIR}"
    git fetch --all
    LATEST_TAG="v1.2.0"
    git checkout $LATEST_TAG
    git reset --hard $LATEST_TAG
    git pull
    
    # Create environment file
    read -p "Enter RPC URL [https://lightnode-rpc-mainnet-namada.grandvalleys.com]: " TENDERMINT_URL
    TENDERMINT_URL=${TENDERMINT_URL:-"https://lightnode-rpc-mainnet-namada.grandvalleys.com"}
    
    cat > "${ENV_FILE}" <<EOF
COMETBFT_URL="${TENDERMINT_URL}"
PORT="${WEBSERVER_PORT}"
EOF

    # Start new deployment
    docker compose -f "${COMPOSE_FILE}" --env-file $ENV_FILE up -d --pull always --build --force-recreate
}

verify_deployment() {
    echo "=== Verifying deployment ==="
    
    # Check container status
    local web_status=$(docker compose -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" ps -q webserver)
    if [[ -z "$web_status" ]]; then
        echo "Error: Webserver container not running!"
        exit 1
    fi
    
    echo "Services running successfully:"
    docker compose -p "${PROJECT_NAME}" -f "${COMPOSE_FILE}" ps
    
    echo -e "\nAccess points:"
    echo "Webserver: http://localhost:${WEBSERVER_PORT}"
    echo "PostgreSQL: localhost:${POSTGRES_PORT}"
}

main() {
    # Verify Docker is running
    if ! docker info >/dev/null 2>&1; then
        echo "Docker daemon not running. Please start Docker first."
        exit 1
    fi

    stop_and_clean
    deploy
    verify_deployment
    
    echo -e "\n=== Deployment complete ==="
    echo "To view logs: docker logs --tail 50 -f namada-masp-indexer-crawler-1"
}

main