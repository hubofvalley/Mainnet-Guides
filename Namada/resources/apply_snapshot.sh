#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Snapshot URLs
MAND_DB_SNAPSHOT_URL="https://snapshots2.mandragora.io/namada/db.lz4"
MAND_DATA_SNAPSHOT_URL="https://snapshots2.mandragora.io/namada/data.lz4"
MAND_API_URL="https://snapshots2.mandragora.io/namada/info.json"

ITR_API_URL="https://server-5.itrocket.net/mainnet/namada/.current_state.json"

# Function to display the menu
show_menu() {
    echo -e "${GREEN}Choose a snapshot provider:${NC}"
    echo "1. Mandragora"
    echo "2. ITRocket"
    echo "3. Exit"
}

# Function to check if a URL is available
check_url() {
    local url=$1
    if curl --output /dev/null --silent --head --fail "$url"; then
        echo -e "${GREEN}Available${NC}"
    else
        echo -e "${RED}Not available at the moment${NC}"
        return 1
    fi
}

# Function to display snapshot details
display_snapshot_details() {
    local api_url=$1
    local snapshot_info=$(curl -s $api_url)
    local snapshot_height

    if [[ $api_url == *"mandragora"* ]]; then
        snapshot_height=$(echo "$snapshot_info" | grep -oP '"snapshot_height":\s*\K\d+')
    else
        snapshot_height=$(echo "$snapshot_info" | jq -r '.snapshot_height')
    fi

    echo -e "${GREEN}Snapshot Height:${NC} $snapshot_height"

    # Get the real-time block height
    realtime_block_height=$(curl -s -X POST "https://lightnode-json-rpc-mainnet-namada.grandvalleys.com" -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq -r '.result' | xargs printf "%d\n")

    # Calculate the difference
    block_difference=$((realtime_block_height - snapshot_height))

    echo -e "${GREEN}Real-time Block Height:${NC} $realtime_block_height"
    echo -e "${GREEN}Block Difference:${NC} $block_difference"
}

# Function to choose snapshot type for Mandragora
choose_mandragora_snapshot() {
    echo -e "${GREEN}Checking availability of Mandragora snapshots:${NC}"
    echo -n "DB Snapshot: "
    check_url $MAND_DB_SNAPSHOT_URL
    echo -n "Data Snapshot: "
    check_url $MAND_DATA_SNAPSHOT_URL

    prompt_back_or_continue

    display_snapshot_details $MAND_API_URL

    DB_SNAPSHOT_FILE="db.lz4"
    DATA_SNAPSHOT_FILE="data.lz4"
}

# Function to choose snapshot type for ITRocket
choose_itrocket_snapshot() {
    echo -e "${GREEN}Checking availability of ITRocket snapshot:${NC}"
    echo -n "Snapshot: "
    check_url $ITR_API_URL

    prompt_back_or_continue

    display_snapshot_details $ITR_API_URL

    FILE_NAME=$(curl -s $ITR_API_URL | jq -r '.snapshot_name')
    SNAPSHOT_URL="https://server-5.itrocket.net/mainnet/namada/$FILE_NAME"
}

# Function to decompress Mandragora snapshots
decompress_mandragora_snapshots() {
    lz4 -c -d $DB_SNAPSHOT_FILE | tar -xv -C $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac
    lz4 -c -d $DATA_SNAPSHOT_FILE | tar -xv -C $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/cometbft
}

# Function to decompress ITRocket snapshot
decompress_itrocket_snapshot() {
    lz4 -c -d $SNAPSHOT_FILE | tar -xv -C $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac
}

# Function to prompt user to back or continue
prompt_back_or_continue() {
    read -p "Press Enter to continue or type 'back' to go back to the menu: " user_choice
    if [[ $user_choice == "back" ]]; then
        main_script
    fi
}

# Main script
main_script() {
    show_menu
    read -p "Enter your choice: " provider_choice

    provider_name=""

    case $provider_choice in
        1)
            provider_name="Mandragora"
            echo -e "Grand Valley extends its gratitude to ${YELLOW}$provider_name${NC} for providing snapshot support."

            choose_mandragora_snapshot
            ;;
        2)
            provider_name="ITRocket"
            echo -e "Grand Valley extends its gratitude to ${YELLOW}$provider_name${NC} for providing snapshot support."

            choose_itrocket_snapshot
            ;;
        3)
            echo -e "${GREEN}Exiting.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac

    # Remove upgrade-info.json
    sudo rm -f $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/data/upgrade-info.json

    cd $HOME

    # Install required dependencies
    sudo apt-get install wget lz4 jq -y

    # Stop your namada node
    sudo systemctl stop namadad

    # Back up your validator state
    sudo cp $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/cometbft/data/priv_validator_state.json $HOME/.local/share/namada/priv_validator_state.json.backup

    # Delete previous namada data folders
    if [[ $provider_choice -eq 1 ]]; then
        sudo rm -rf $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/db
        sudo rm -rf $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/cometbft/data
    elif [[ $provider_choice -eq 2 ]]; then
        sudo rm -rf $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/cometbft/data
        sudo rm -rf $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/db
    fi

    # Download and decompress snapshots based on the provider
    if [[ $provider_choice -eq 1 ]]; then
        wget -O $DB_SNAPSHOT_FILE $MAND_DB_SNAPSHOT_URL
        wget -O $DATA_SNAPSHOT_FILE $MAND_DATA_SNAPSHOT_URL
        decompress_mandragora_snapshots
    elif [[ $provider_choice -eq 2 ]]; then
        SNAPSHOT_FILE=$FILE_NAME
        wget -O $SNAPSHOT_FILE $SNAPSHOT_URL
        decompress_itrocket_snapshot
    fi

    # Change ownership of the .local/share/namada directory
    sudo chown -R $USER:$USER $HOME/.local/share/namada

    # Ask the user if they want to delete the downloaded snapshot files
    read -p "Do you want to delete the downloaded snapshot files? (y/n): " delete_choice

    if [[ $delete_choice == "y" || $delete_choice == "Y" ]]; then
        # Delete downloaded snapshot files
        if [[ $provider_choice -eq 1 ]]; then
            sudo rm -v $DB_SNAPSHOT_FILE $DATA_SNAPSHOT_FILE
        elif [[ $provider_choice -eq 2 ]]; then
            sudo rm -v $SNAPSHOT_FILE
        fi
        echo -e "${GREEN}Downloaded snapshot files have been deleted.${NC}"
    else
        echo -e "${GREEN}Downloaded snapshot files have been kept.${NC}"
    fi

    # Restore your validator state
    sudo cp $HOME/.local/share/namada/priv_validator_state.json.backup $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/cometbft/data/priv_validator_state.json

    # Start your namada node
    sudo systemctl restart namadad

    echo -e "${GREEN}Snapshot setup completed successfully.${NC}"
}

main_script
