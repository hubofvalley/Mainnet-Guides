#!/bin/bash

# Function to install cosmovisor
install_cosmovisor() {
    echo "Installing cosmovisor..."
    if ! go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@latest; then
        echo "Failed to install cosmovisor. Exiting."
        exit 1
    fi
}

# Function to initialize cosmovisor
init_cosmovisor() {
    echo "Initializing cosmovisor..."

    # Initialize cosmovisor with the current Namada binary
    if ! cosmovisor init /usr/local/bin/namadan; then
        echo "Failed to initialize cosmovisor. Exiting."
        exit 1
    fi

    mkdir -p $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/cosmovisor/upgrades
    mkdir -p $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/cosmovisor/backup
    mkdir -p $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/data
}

# Install and initialize cosmovisor
install_cosmovisor
init_cosmovisor

# Define variables
input1=$(which cosmovisor)
input2=$(find $HOME -type d -name "namada-dryrun.abaaeaf7b78cb3ac")
input3=$(find $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/cosmovisor -type d -name "backup")

# Check if cosmovisor is installed
if [ -z "$input1" ]; then
    echo "cosmovisor is not installed. Please install it first."
    exit 1
fi

# Check if Namada directory exists
if [ -z "$input2" ]; then
    echo "Namada directory not found. Please ensure it exists."
    exit 1
fi

# Check if backup directory exists
if [ -z "$input3" ]; then
    echo "Backup directory not found. Please ensure it exists."
    exit 1
fi

# Export environment variables
echo "export DAEMON_NAME=namadan" >> $HOME/.bash_profile
echo "export DAEMON_HOME=$input2" >> $HOME/.bash_profile
echo "export DAEMON_DATA_BACKUP_DIR=$(find $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/cosmovisor -type d -name "backup")" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Create or update the systemd service file
cat <<EOF | sudo tee /etc/systemd/system/namadad.service
[Unit]
Description=Cosmovisor Namada Mainnet Node
After=network.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$HOME/.local/share/namada
ExecStart=$input1 run ledger run
StandardOutput=journal
StandardError=journal
Restart=on-failure
RestartSec=5
LimitNOFILE=65536
LimitNPROC=65536
Environment=CMT_LOG_LEVEL=p2p:debug,pex:info
Environment=NAMADA_CMT_STDOUT=true
Environment="DAEMON_NAME=namadan"
Environment="DAEMON_HOME=$input2"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=true"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="DAEMON_DATA_BACKUP_DIR=$input3"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF

# Reload and Restart systemd to apply changes
sudo systemctl daemon-reload
sudo systemctl restart namadad

echo "Cosmovisor migration completed successfully."
