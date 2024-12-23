#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Snapshot URLs for Mandragora Full Snapshot
MAND_FULL_DB_SNAPSHOT_URL="https://snapshots2.mandragora.io/namada-full/db.lz4"
MAND_FULL_DATA_SNAPSHOT_URL="https://snapshots2.mandragora.io/namada-full/data.lz4"
MAND_FULL_API_URL="https://snapshots2.mandragora.io/namada-full/info.json"

# Snapshot URLs for Mandragora Light Snapshot
MAND_LIGHT_DB_SNAPSHOT_URL="https://snapshots2.mandragora.io/namada-light/db.lz4"
MAND_LIGHT_DATA_SNAPSHOT_URL="https://snapshots2.mandragora.io/namada-light/data.lz4"
MAND_LIGHT_API_URL="https://snapshots2.mandragora.io/namada-light/info.json"

# Snapshot URL for ITRocket
ITR_API_URL="https://server-5.itrocket.net/mainnet/namada/.current_state.json"

# Snapshot URL for CroutonDigital
CRD_API_URL="https://storage.crouton.digital/mainnet/namada/snapshots/block_status.json"
CRD_SNAPSHOT_URL="https://storage.crouton.digital/mainnet/namada/snapshots/namada_latest.tar.lz4"

# Function to display the menu
show_menu() {
    echo -e "${GREEN}Choose a snapshot provider:${NC}"
    echo "1. Mandragora"
    echo "2. ITRocket"
    echo "3. CroutonDigital"
    echo "4. Exit"
}

# Function to display the Mandragora snapshot type menu
show_mandragora_menu() {
    echo -e "${GREEN}Choose a Mandragora snapshot type:${NC}"
    echo "1. Full Snapshot"
    echo "2. Light Snapshot"
    echo "3. Back to Snapshot main menu"
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
        snapshot_height=$(echo "$snapshot_info" | grep -oP '"snapshot_height":\s*"\K\d+')
    elif [[ $api_url == *"crouton"* ]]; then
        snapshot_height=$(echo "$snapshot_info" | jq -r '.latest_block_height')
    else
        snapshot_height=$(echo "$snapshot_info" | jq -r '.snapshot_height')
    fi

    echo -e "${GREEN}Snapshot Height:${NC} $snapshot_height"

    # Get the real-time block height
    realtime_block_height=$(curl -s https://lightnode-rpc-mainnet-namada.grandvalleys.com/status | jq -r '.result.sync_info.latest_block_height')

    # Calculate the difference
    block_difference=$((realtime_block_height - snapshot_height))

    echo -e "${GREEN}Real-time Block Height:${NC} $realtime_block_height"
    echo -e "${GREEN}Block Difference:${NC} $block_difference"
}

# Function to choose snapshot type for Mandragora Full
choose_mandragora_full_snapshot() {
    echo -e "${GREEN}Checking availability of Mandragora Full snapshots:${NC}"
    echo -n "DB Snapshot: "
    check_url $MAND_FULL_DB_SNAPSHOT_URL
    echo -n "Data Snapshot: "
    check_url $MAND_FULL_DATA_SNAPSHOT_URL

    prompt_back_or_continue

    display_snapshot_details $MAND_FULL_API_URL

    DB_SNAPSHOT_FILE="db.lz4"
    DATA_SNAPSHOT_FILE="data.lz4"
}

# Function to choose snapshot type for Mandragora Light
choose_mandragora_light_snapshot() {
    echo -e "${GREEN}Checking availability of Mandragora Light snapshots:${NC}"
    echo -n "DB Snapshot: "
    check_url $MAND_LIGHT_DB_SNAPSHOT_URL
    echo -n "Data Snapshot: "
    check_url $MAND_LIGHT_DATA_SNAPSHOT_URL

    prompt_back_or_continue

    display_snapshot_details $MAND_LIGHT_API_URL

    DB_SNAPSHOT_FILE="db.lz4"
    DATA_SNAPSHOT_FILE="data.lz4"
}

# Function to choose snapshot type for ITRocket
choose_itrocket_snapshot() {
    echo -e "${GREEN}Checking availability of ITRocket snapshot:${NC}"
    echo -n "Snapshot: "
    check_url $ITR_API_URL

    display_snapshot_details $ITR_API_URL

    prompt_back_or_continue

    FILE_NAME=$(curl -s $ITR_API_URL | jq -r '.snapshot_name')
    SNAPSHOT_URL="https://server-5.itrocket.net/mainnet/namada/$FILE_NAME"
}

# Function to choose snapshot type for CroutonDigital
choose_croutondigital_snapshot() {
    echo -e "${GREEN}Checking availability of CroutonDigital snapshot:${NC}"
    echo -n "Snapshot: "
    check_url $CRD_SNAPSHOT_URL

    display_snapshot_details $CRD_API_URL

    prompt_back_or_continue

    SNAPSHOT_FILE="namada_latest.tar.lz4"
}

# Function to decompress Mandragora snapshots
decompress_mandragora_snapshots() {
    lz4 -c -d $DB_SNAPSHOT_FILE | tar -xv -C $HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420
    lz4 -c -d $DATA_SNAPSHOT_FILE | tar -xv -C $HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420/cometbft
}

# Function to decompress ITRocket snapshot
decompress_itrocket_snapshot() {
    lz4 -c -d $SNAPSHOT_FILE | tar -xv -C $HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420
}

# Function to decompress CroutonDigital snapshot
decompress_croutondigital_snapshot() {
    lz4 -c -d $SNAPSHOT_FILE | tar -xv -C $HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420
}

# Function to prompt user to back or continue
prompt_back_or_continue() {
    read -p "Press Enter to continue or type 'back' to go back to the menu: " user_choice
    if [[ $user_choice == "back" ]]; then
        main_script
    fi
}

# Function to prompt user to delete snapshot files
prompt_delete_snapshots() {
    read -p "Do you want to delete the downloaded snapshot files after the process? (y/n): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        delete_snapshots=true
        echo -e "${GREEN}Downloaded snapshot files will be deleted after the process.${NC}"
    else
        delete_snapshots=false
        echo -e "${GREEN}Downloaded snapshot files will be kept.${NC}"
    fi
}

# Function to delete snapshot files
delete_snapshot_files() {
    if [[ $delete_snapshots == true ]]; then
        if [[ $provider_choice -eq 1 ]]; then
            sudo rm -v $DB_SNAPSHOT_FILE $DATA_SNAPSHOT_FILE
        elif [[ $provider_choice -eq 2 ]]; then
            sudo rm -v $SNAPSHOT_FILE
        elif [[ $provider_choice -eq 3 ]]; then
            sudo rm -v $SNAPSHOT_FILE
        fi
        echo -e "${GREEN}Downloaded snapshot files have been deleted.${NC}"
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

            show_mandragora_menu
            read -p "Enter your choice: " mandragora_choice

            case $mandragora_choice in
                1)
                    choose_mandragora_full_snapshot
                    ;;
                2)
                    choose_mandragora_light_snapshot
                    ;;
                3)
                    main_script
                    ;;
                *)
                    echo -e "${RED}Invalid choice. Exiting.${NC}"
                    exit 1
                    ;;
            esac
            ;;
        2)
            provider_name="ITRocket"
            echo -e "Grand Valley extends its gratitude to ${YELLOW}$provider_name${NC} for providing snapshot support."

            choose_itrocket_snapshot
            ;;
        3)
            provider_name="CroutonDigital"
            echo -e "Grand Valley extends its gratitude to ${YELLOW}$provider_name${NC} for providing snapshot support."

            choose_croutondigital_snapshot
            ;;
        4)
            echo -e "${GREEN}Exiting.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac

    prompt_delete_snapshots

    prompt_back_or_continue

    cd $HOME

    # Install required dependencies
    sudo apt-get install wget lz4 jq -y

    # Stop your namada node
    sudo systemctl stop namadad

    # Back up your validator state
    cp $HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420/cometbft/data/priv_validator_state.json $HOME/.local/share/namada/priv_validator_state.json.backup

    # Delete previous namada data folders
    if [[ $provider_choice -eq 1 ]]; then
        sudo rm -rf $HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420/db
        sudo rm -rf $HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420/cometbft/data
    elif [[ $provider_choice -eq 2 ]]; then
        sudo rm -rf $HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420/cometbft/data
        sudo rm -rf $HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420/{db,wasm}
    elif [[ $provider_choice -eq 3 ]]; then
        sudo rm -rf $HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420/cometbft/data
        sudo rm -rf $HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420/{db,wasm}
    fi

    # Download and decompress snapshots based on the provider
    if [[ $mandragora_choice -eq 1 ]]; then
        wget -O $DB_SNAPSHOT_FILE $MAND_FULL_DB_SNAPSHOT_URL
        wget -O $DATA_SNAPSHOT_FILE $MAND_FULL_DATA_SNAPSHOT_URL
        decompress_mandragora_snapshots
    elif [[ $mandragora_choice -eq 2 ]]; then
        wget -O $DB_SNAPSHOT_FILE $MAND_LIGHT_DB_SNAPSHOT_URL
        wget -O $DATA_SNAPSHOT_FILE $MAND_LIGHT_DATA_SNAPSHOT_URL
        decompress_mandragora_snapshots
    elif [[ $provider_choice -eq 2 ]]; then
        SNAPSHOT_FILE=$FILE_NAME
        wget -O $SNAPSHOT_FILE $SNAPSHOT_URL
        decompress_itrocket_snapshot
    elif [[ $provider_choice -eq 3 ]]; then
        wget -O $SNAPSHOT_FILE $CRD_SNAPSHOT_URL
        decompress_croutondigital_snapshot
    fi

    # Change ownership of the .local/share/namada directory
    sudo chown -R $USER:$USER $HOME/.local/share/namada

    # Restore your validator state
    cp $HOME/.local/share/namada/priv_validator_state.json.backup $HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420/cometbft/data/priv_validator_state.json

    # Start your namada node
    sudo systemctl restart namadad

    # Delete snapshot files if chosen
    delete_snapshot_files

    echo -e "${GREEN}Snapshot setup completed successfully.${NC}"
    exit 0
}

main_script
