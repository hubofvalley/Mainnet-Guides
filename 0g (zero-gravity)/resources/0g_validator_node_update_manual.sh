#!/bin/bash

function update_version {
    VERSION=$1
    RELEASE_URL="$2/aristotle-${VERSION}.tar.gz"
    BACKUP_DIR="$HOME/backups"
 
    echo "Updating to version $VERSION..."
    
    # Stop services
    sudo systemctl stop 0g-geth.service || { echo "Failed to stop 0g-geth"; exit 1; }
    sudo systemctl stop 0gchaind.service || { echo "Failed to stop 0gchaind"; exit 1; }
 
    # Backup old binaries
    TIMESTAMP=$(date +%Y%m%d%H%M%S)
    mkdir -p $BACKUP_DIR
    [ -f $HOME/go/bin/0g-geth ] && cp $HOME/go/bin/0g-geth $BACKUP_DIR/0g-geth.$TIMESTAMP
    [ -f $HOME/go/bin/0gchaind ] && cp $HOME/go/bin/0gchaind $BACKUP_DIR/0gchaind.$TIMESTAMP
 
    # Download and install new version
    cd $HOME
    wget $RELEASE_URL || { echo "Download failed"; exit 1; }
    tar -xzf aristotle-${VERSION}.tar.gz || { echo "Extraction failed"; exit 1; }
    rm aristotle-${VERSION}.tar.gz
 
    cp aristotle-${VERSION}/bin/geth $HOME/go/bin/0g-geth
    cp aristotle-${VERSION}/bin/0gchaind $HOME/go/bin/0gchaind
    sudo chmod +x $HOME/go/bin/0g-geth
    sudo chmod +x $HOME/go/bin/0gchaind

    # Rollback
    0gchaind rollback --home $HOME/.0gchaind/0g-home/0gchaind-home/

    # Restart services
    sudo systemctl daemon-reload
    sudo systemctl start 0g-geth.service || { echo "Failed to start 0g-geth"; exit 1; }
    sudo systemctl start 0gchaind.service || { echo "Failed to start 0gchaind"; exit 1; }

    echo "Update to $VERSION completed!"
}

BASE_URL="https://github.com/0gfoundation/0gchain-Aristotle/releases/download"

# Display menu
echo "Select version to update:"
echo "a) v1.0.2"
echo "b) v1.0.3"

read -p "Enter the letter corresponding to the version: " choice

read -p "Are you sure you want to proceed with the update? (yes/no): " confirm
confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]')
if [[ "$confirm" != "yes" ]]; then
    echo "Update cancelled."
    exit 0
fi

case $choice in
    a)
        update_version "v1.0.2" "$BASE_URL/1.0.2"
        ;;
    b)
        update_version "v1.0.3" "$BASE_URL/1.0.3"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo "Let's Buidl 0G Together!"

