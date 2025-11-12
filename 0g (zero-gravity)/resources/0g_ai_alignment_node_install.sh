#!/bin/bash

# Valley of 0G AI Alignment Node installer v1.0.0
# Quick installer following Valley of 0G style and the user's guide steps.
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

APP_DIR="$HOME/0g-alignment-node"
BIN_NAME="0g-alignment-node"
NODE_BINARY_URL="https://github.com/0gfoundation/alignment-node-release/releases/download/v1.0.0/alignment-node.tar.gz"
SERVICE_NAME="0g-alignment-node"

function info() { echo -e "${GREEN}[INFO]${RESET} $*"; }
function warn() { echo -e "${YELLOW}[WARN]${RESET} $*"; }
function fail() { echo -e "${RED}[ERROR]${RESET} $*"; exit 1; }

# Collect all user inputs up-front
function collect_inputs() {
  echo -e "${YELLOW}Please provide the following values before the installer proceeds:${RESET}"
  read -p "0) Is this a migration of an already registered/delegated/approved operator? (yes/no, default no): " MIGRATION_MODE
  MIGRATION_MODE=${MIGRATION_MODE:-no}

  read -p "1) Choose your port (default 8080, e.g. 34567): " NODE_PORT
  NODE_PORT=${NODE_PORT:-8080}

  read -p "2) Enter wallet private key (no 0x prefix): " PRIVATE_KEY
  if [ -z "$PRIVATE_KEY" ]; then
    fail "Private key required to configure node"
  fi

  if [[ "${MIGRATION_MODE,,}" != "yes" ]]; then
    read -p "3) Enter NFT token IDs (comma-separated) for registration/approval: (e.g: ID1,ID2,ID3,....)" NFT_TOKEN_IDS
    if [ -z "$NFT_TOKEN_IDS" ]; then
      fail "At least one NFT token id is required for fresh setup"
    fi

    read -p "4) Enter RPC endpoint for registration (press Enter to use default https://arb1.arbitrum.io/rpc): " RPC
    RPC=${RPC:-https://arb1.arbitrum.io/rpc}
  else
    # Still allow custom RPC override if desired (press Enter to keep default)
    read -p "(Optional) RPC endpoint (press Enter to use default https://arb1.arbitrum.io/rpc): " RPC
    RPC=${RPC:-https://arb1.arbitrum.io/rpc}
  fi

  # Fixed defaults (not prompted)
  CHAIN_ID=42161
  COMMISSION=10

  read -p "5) Create/enable UFW rules for chosen port? (yes/no, default yes): " ENABLE_UFW
  ENABLE_UFW=${ENABLE_UFW:-yes}

  read -p "6) Create systemd service after install? (yes/no, default yes): " CREATE_SERVICE
  CREATE_SERVICE=${CREATE_SERVICE:-yes}

  echo ""
  echo -e "${GREEN}Summary of inputs:${RESET}"
  echo "  Mode: $([[ \"${MIGRATION_MODE,,}\" == \"yes\" ]] && echo migration || echo fresh install)"
  echo "  Port: $NODE_PORT"
  echo "  RPC: $RPC"
  if [[ "${MIGRATION_MODE,,}" != "yes" ]]; then
    echo "  NFT Token IDs: $NFT_TOKEN_IDS"
  fi
  echo "  UFW config: $ENABLE_UFW"
  echo "  Create service: $CREATE_SERVICE"
  echo "  (chain-id will be $CHAIN_ID, commission will be $COMMISSION)"
  echo ""
  read -p "Proceed with the installation using the above values? (yes/no): " CONFIRM_INSTALL
  if [[ "${CONFIRM_INSTALL,,}" != "yes" ]]; then
    info "Installation aborted by user."
    exit 0
  fi
}

# Preflight: ensure minimal tools available
function preflight_checks() {
  if ! command -v wget >/dev/null 2>&1; then
    info "Installing wget..."
    sudo apt-get update -y
    sudo apt-get install -y wget
  fi
  if ! command -v tar >/dev/null 2>&1; then
    sudo apt-get install -y tar
  fi
  if ! command -v ufw >/dev/null 2>&1; then
    warn "ufw not found. Firewall steps will be skipped if ufw is missing."
  fi
}

# Step 1: Setup Directory
function setup_directory() {
  info "Creating directory $APP_DIR"
  mkdir -p "$APP_DIR"
  cd "$APP_DIR" || fail "Cannot cd to $APP_DIR"
}

# Step 2: Download and Extract Node
function download_and_extract() {
  info "Downloading node tarball from $NODE_BINARY_URL"
  wget -q "$NODE_BINARY_URL" -O alignment-node.tar.gz || fail "Download failed"
  info "Extracting..."
  tar -xzf alignment-node.tar.gz || fail "Extraction failed"
  if [ -d "alignment-node" ]; then
    if [ -f "alignment-node/$BIN_NAME" ]; then
      mv -f "alignment-node/$BIN_NAME" ./
    fi
    rm -rf alignment-node
  fi
  sudo chmod +x "./$BIN_NAME" || fail "chmod failed"
  rm -f alignment-node.tar.gz
  info "Binary ready at: $APP_DIR/$BIN_NAME"
}

# Step 3: Configure Node (.env and config.toml)
# Uses variables collected by collect_inputs()
function configure_env() {
  if [ -z "${NODE_PORT:-}" ] || [ -z "${PRIVATE_KEY:-}" ]; then
    fail "Required inputs not provided. Run collect_inputs first."
  fi

  cat > .env <<EOF
ZG_ALIGNMENT_NODE_LOG_LEVEL=info
ZG_ALIGNMENT_NODE_SERVICE_IP=http://0.0.0.0:${NODE_PORT}
ZG_ALIGNMENT_NODE_SERVICE_PRIVATEKEY=${PRIVATE_KEY}
EOF

  cat > config.toml <<EOF
ZG_ALIGNMENT_NODE_LOG_LEVEL="info"
ZG_ALIGNMENT_NODE_SERVICE_IP="http://0.0.0.0:${NODE_PORT}"
ZG_ALIGNMENT_NODE_SERVICE_PRIVATEKEY="${PRIVATE_KEY}"
EOF

  info ".env and config.toml created in $APP_DIR"
}

# Step 4: Open Your Port (ufw)
function open_port() {
  if command -v ufw >/dev/null 2>&1; then
    info "Allowing port $NODE_PORT/tcp and 22/tcp via ufw"
    sudo ufw allow "$NODE_PORT"/tcp
    sudo ufw allow 22/tcp
    sudo ufw --force enable
  else
    warn "ufw not installed. Skipping firewall configuration steps."
  fi
}

# Step 5: Register Operator (can run per-NFT)
# Uses variables collected by collect_inputs(): CHAIN_ID, RPC, COMMISSION, NFT_TOKEN_IDS
function register_operator_single() {
  local single_token_id="$1"
  info "Registering operator for NFT token-id: ${single_token_id}"

  # Load env variables
  if [ -f .env ]; then
    # shellcheck disable=SC1091
    source .env
  else
    fail ".env not found, please run configure step first"
  fi

  info "Running registerOperator (this will use provided private key and single NFT token id)"
  ./"$BIN_NAME" registerOperator \
    --key "$ZG_ALIGNMENT_NODE_SERVICE_PRIVATEKEY" \
    --token-id "$single_token_id" \
    --commission "$COMMISSION" \
    --chain-id "$CHAIN_ID" \
    --rpc "$RPC" \
    --contract 0xdD158B8A76566bC0c342893568e8fd3F08A9dAac \
    --mainnet
}

# Ask if operator is already registered; if not, register per NFT iteratively
function maybe_register_operator() {
  echo -e "${YELLOW}Is your address already registered as an Operator? (yes/no)${RESET}"
  read -p "Answer: " ALREADY_REGISTERED
  ALREADY_REGISTERED=$(echo "$ALREADY_REGISTERED" | tr '[:upper:]' '[:lower:]')
  if [[ "$ALREADY_REGISTERED" == "yes" ]]; then
    info "Skipping operator registration as requested."
    return 0
  fi

  # Iterate through comma-separated token IDs, registering one by one
  IFS=',' read -ra TOKENS <<< "$NFT_TOKEN_IDS"
  for t in "${TOKENS[@]}"; do
    t_trimmed=$(echo "$t" | xargs)
    if [[ -n "$t_trimmed" ]]; then
      register_operator_single "$t_trimmed"
      echo -e "${GREEN}Submitted registration for token-id ${t_trimmed}.${RESET}"
      read -p "Wait for confirmation on-chain, then press Enter to continue to the next token..." _
    fi
  done
}

# Step: Instruct delegation and then run approval for all tokens
function delegate_then_approve() {
  echo -e "${GREEN}Before approval:${RESET} Please delegate your Alignment Node NFT(s) at: ${BLUE}https://claim.0gfoundation.ai/delegation${RESET}"
  echo -e "Use your Node Operator Address when delegating."
  read -p "Press Enter after you finish delegating to continue to approval..." _

  # Load env
  if [ -f .env ]; then
    # shellcheck disable=SC1091
    source .env
  else
    fail ".env not found, please run configure step first"
  fi

  info "Running approval (registerOperator with multiple token-ids)"
  ./"$BIN_NAME" registerOperator \
    --key "$ZG_ALIGNMENT_NODE_SERVICE_PRIVATEKEY" \
    --token-id "$NFT_TOKEN_IDS" \
    --commission "$COMMISSION" \
    --chain-id "$CHAIN_ID" \
    --rpc "$RPC" \
    --contract 0xdD158B8A76566bC0c342893568e8fd3F08A9dAac \
    --mainnet
}

# Step 6: Create systemd Service
function create_service() {
  info "Creating systemd service /etc/systemd/system/$SERVICE_NAME.service"
  sudo tee /etc/systemd/system/"$SERVICE_NAME".service > /dev/null <<EOF
[Unit]
Description=0G AI Alignment Node
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$APP_DIR
EnvironmentFile=$APP_DIR/.env
ExecStart=$APP_DIR/$BIN_NAME start --mainnet
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
  sudo systemctl daemon-reload
  sudo systemctl enable "$SERVICE_NAME"
  info "Systemd service created and enabled"
}

# Step 7: Start Node
function start_node() {
  info "Starting $SERVICE_NAME"
  sudo systemctl start "$SERVICE_NAME"
  sleep 2
  sudo systemctl status "$SERVICE_NAME" --no-pager || true
}

# Step 8: Check Status / Logs
function show_logs() {
  info "Showing journal logs (follow)"
  sudo journalctl -u "$SERVICE_NAME" -f
}

# Update binary function (update when new release)
function update_binary() {
  info "Updating binary (backup current and download fresh)"
  cd "$APP_DIR" || fail "Cannot cd to $APP_DIR"
  sudo systemctl stop "$SERVICE_NAME" || true
  if [ -f "$BIN_NAME" ]; then
    sudo mv "$BIN_NAME" "$BIN_NAME".backup.$(date +%s)
  fi
  wget -q "$NODE_BINARY_URL" -O alignment-node.tar.gz || fail "Download failed"
  tar -xzf alignment-node.tar.gz || fail "Extraction failed"
  if [ -f alignment-node/"$BIN_NAME" ]; then
    mv -f alignment-node/"$BIN_NAME" ./
  fi
  chmod +x "$BIN_NAME"
  rm -rf alignment-node alignment-node.tar.gz
  sudo systemctl start "$SERVICE_NAME"
  info "Update complete"
  sudo systemctl status "$SERVICE_NAME" --no-pager || true
}

# Run full interactive install flow (collect inputs first, then run steps)
function run_install_flow() {
  collect_inputs
  preflight_checks
  setup_directory
  download_and_extract
  configure_env

  if [[ "${ENABLE_UFW,,}" == "yes" && "$(command -v ufw >/dev/null 2>&1; echo $?)" == "0" ]]; then
    info "Applying firewall rules"
    sudo ufw allow "${NODE_PORT}"/tcp
    sudo ufw allow 22/tcp
    sudo ufw --force enable
  else
    warn "Skipping ufw configuration"
  fi

  if [[ "${MIGRATION_MODE,,}" == "yes" ]]; then
    info "Migration mode: skipping operator registration, delegation, and approval."
  else
    maybe_register_operator
    # Prompt delegation and approval
    delegate_then_approve
  fi

  if [[ "${CREATE_SERVICE,,}" == "yes" ]]; then
    create_service
    start_node
  else
    info "Service creation skipped as requested. To start manually: $APP_DIR/$BIN_NAME start --mainnet"
  fi

  info "Installation complete"
}

# If script is executed directly, run install flow
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  run_install_flow
fi

