#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Snapshot URLs
MAND_PRUNED_GETH_SNAPSHOT_URL="https://snapshots2.mandragora.io/story/geth_snapshot.lz4"
MAND_PRUNED_STORY_SNAPSHOT_URL="https://snapshots2.mandragora.io/story/story_snapshot.lz4"
MAND_ARCHIVE_GETH_SNAPSHOT_URL="https://snapshots.mandragora.io/geth_snapshot.lz4"
MAND_ARCHIVE_STORY_SNAPSHOT_URL="https://snapshots.mandragora.io/story_snapshot.lz4"

TTT_GETH_SNAPSHOT_URL="https://snapshots.tienthuattoan.com/mainnet/story/story_geth_latest.tar.lz4"
TTT_STORY_SNAPSHOT_URL="https://snapshots.tienthuattoan.com/mainnet/story/story_latest.tar.lz4"
TTT_API_URL="https://snapshots.tienthuattoan.com/mainnet/story/info.json"

DTEAM_PRUNED_GETH_SNAPSHOT_URL="https://download.dteam.tech/story/mainnet/pruned/latest-geth-snapshot"
DTEAM_PRUNED_STORY_SNAPSHOT_URL="https://download.dteam.tech/story/mainnet/pruned/latest-snapshot"
DTEAM_PRUNED_API_URL="https://data.dteam.tech/story/mainnet/snapshot"

MAND_PRUNED_API_URL="https://snapshots2.mandragora.io/story/info.json"
MAND_ARCHIVE_API_URL="https://snapshots.mandragora.io/info.json"

#ITR_PRUNED_API_URL_1="https://server-1.itrocket.net/mainnet/story/.current_state.json"
#ITR_ARCHIVE_API_URL_1="https://server-5.itrocket.net/mainnet/story/.current_state.json"
#ITR_PRUNED_API_URL_2="https://server-3.itrocket.net/mainnet/story/.current_state.json"
#ITR_ARCHIVE_API_URL_2="https://server-8.itrocket.net/mainnet/story/.current_state.json"

#CROUTON_SNAPSHOT_URL="https://storage.crouton.digital/mainnet/story/snapshots/story_latest.tar.lz4"
#CROUTON_API_URL="https://storage.crouton.digital/mainnet/story/snapshots/block_status.json"

JOSEPHTRAN_PRUNED_GETH_SNAPSHOT_URL="https://story.j-node.net/mainnet/Geth_snapshot.lz4"
JOSEPHTRAN_PRUNED_STORY_SNAPSHOT_URL="https://story.j-node.net/mainnet/Story_snapshot.lz4"
JOSEPHTRAN_ARCHIVE_GETH_SNAPSHOT_URL="https://story.j-node.net/mainnet/archive_Geth_snapshot.lz4"
JOSEPHTRAN_ARCHIVE_STORY_SNAPSHOT_URL="https://story.j-node.net/mainnet/archive_Story_snapshot.lz4"

JOSEPHTRAN_PRUNED_API_URL="https://story.j-node.net/mainnet/prune_snapshot_info.json"
JOSEPHTRAN_ARCHIVE_API_URL="https://story.j-node.net/mainnet/archive_snapshot_info.json"

#ORIGINSTAKE_PRUNED_API_URL="https://snapshot.originstake.com/story_snapshot_metadata.json"
#ORIGINSTAKE_ARCHIVE_API_URL="https://snapshot.originstake.com/full/story_full_snapshot_metadata.json"

# Function to display the menu
show_menu() {
    echo -e "${GREEN}Choose a snapshot provider:${NC}"
    echo "1. Josephtran (J•Node)"
    echo "2. Mandragora"
    echo "3. TTT VN"
    echo "4. DTEAM"
    #echo "5. ITRocket"
    #echo "6. CroutonDigital"
    #echo "7. OriginStake"
    echo "5. Exit"
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

    if [[ $api_url == *"dteam"* ]]; then
        snapshot_height=$(echo "$snapshot_info" | jq -r '.latest.height')
    elif [[ $api_url == *"mandragora"* ]]; then
        snapshot_height=$(echo "$snapshot_info" | grep -oP '"snapshot_height":\s*"\K\d+')
    elif [[ $api_url == *"originstake"* ]]; then
        snapshot_height=$(echo "$snapshot_info" | jq -r '.height')
    elif [[ $api_url == *"j-node"* ]]; then
        snapshot_height=$(echo "$snapshot_info" | grep -oP '"block_height":\s*\K\d+')
    elif [[ $api_url == *"crouton"* ]] || [[ $api_url == *"tienthuattoan"* ]]; then
        snapshot_height=$(echo "$snapshot_info" | grep -oP '"latest_block_height":\s*"\K\d+')
    else
        snapshot_height=$(echo "$snapshot_info" | jq -r '.snapshot_height')
    fi

    echo -e "${GREEN}Snapshot Height:${NC} $snapshot_height"

    # Get the real-time block height
    realtime_block_height=$(curl -s -X POST "https://mainnet.storyrpc.io" -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq -r '.result' | xargs printf "%d\n")

    # Calculate the difference
    block_difference=$((realtime_block_height - snapshot_height))

    echo -e "${GREEN}Real-time Block Height:${NC} $realtime_block_height"
    echo -e "${GREEN}Block Difference:${NC} $block_difference"
}

# Function to choose snapshot type for Mandragora
choose_mandragora_snapshot() {
    echo -e "${GREEN}Choose the type of snapshot for Mandragora:${NC}"
    echo "1. Pruned"
    echo "2. Archive"
    read -p "Enter your choice: " snapshot_type_choice

    case $snapshot_type_choice in
        1)
            SNAPSHOT_API_URL=$MAND_PRUNED_API_URL
            GETH_SNAPSHOT_URL=$MAND_PRUNED_GETH_SNAPSHOT_URL
            STORY_SNAPSHOT_URL=$MAND_PRUNED_STORY_SNAPSHOT_URL
            ;;
        2)
            SNAPSHOT_API_URL=$MAND_ARCHIVE_API_URL
            GETH_SNAPSHOT_URL=$MAND_ARCHIVE_GETH_SNAPSHOT_URL
            STORY_SNAPSHOT_URL=$MAND_ARCHIVE_STORY_SNAPSHOT_URL
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac

    display_snapshot_details $SNAPSHOT_API_URL

    prompt_back_or_continue
}

# Function to choose snapshot type for ITRocket
choose_itrocket_snapshot() {
    echo -e "${GREEN}Choose the type of snapshot for ITRocket:${NC}"
    echo "1. Pruned"
    echo "2. Archive"
    read -p "Enter your choice: " snapshot_type_choice

    case $snapshot_type_choice in
        1)
            echo -e "${GREEN}Checking availability and details of Pruned snapshots:${NC}"
            echo -n "Pruned Snapshot (Server 1): "
            check_url $ITR_PRUNED_API_URL_1
            if [[ $? -eq 0 ]]; then
                display_snapshot_details $ITR_PRUNED_API_URL_1
            fi
            echo -n "Pruned Snapshot (Server 3): "
            check_url $ITR_PRUNED_API_URL_2
            if [[ $? -eq 0 ]]; then
                display_snapshot_details $ITR_PRUNED_API_URL_2
            fi

            echo -e "${GREEN}Choose the server for Pruned snapshot:${NC}"
            echo "1. Server 1"
            echo "2. Server 3"
            read -p "Enter your choice: " server_choice

            case $server_choice in
                1)
                    SNAPSHOT_API_URL=$ITR_PRUNED_API_URL_1
                    SERVER_BASE_URL="https://server-1.itrocket.net/mainnet/story/"
                    ;;
                2)
                    SNAPSHOT_API_URL=$ITR_PRUNED_API_URL_2
                    SERVER_BASE_URL="https://server-3.itrocket.net/mainnet/story/"
                    ;;
                *)
                    echo -e "${RED}Invalid choice. Exiting.${NC}"
                    exit 1
                    ;;
            esac
            ;;
        2)
            echo -e "${GREEN}Checking availability and details of Archive snapshots:${NC}"
            echo -n "Archive Snapshot (Server 5): "
            check_url $ITR_ARCHIVE_API_URL_1
            if [[ $? -eq 0 ]]; then
                display_snapshot_details $ITR_ARCHIVE_API_URL_1
            fi
            echo -n "Archive Snapshot (Server 8): "
            check_url $ITR_ARCHIVE_API_URL_2
            if [[ $? -eq 0 ]]; then
                display_snapshot_details $ITR_ARCHIVE_API_URL_2
            fi

            echo -e "${GREEN}Choose the server for Archive snapshot:${NC}"
            echo "1. Server 5"
            echo "2. Server 8"
            read -p "Enter your choice: " server_choice

            case $server_choice in
                1)
                    SNAPSHOT_API_URL=$ITR_ARCHIVE_API_URL_1
                    SERVER_BASE_URL="https://server-5.itrocket.net/mainnet/story/"
                    ;;
                2)
                    SNAPSHOT_API_URL=$ITR_ARCHIVE_API_URL_2
                    SERVER_BASE_URL="https://server-8.itrocket.net/mainnet/story/"
                    ;;
                *)
                    echo -e "${RED}Invalid choice. Exiting.${NC}"
                    exit 1
                    ;;
            esac
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac

    prompt_back_or_continue

    FILE_NAME=$(curl -s $SNAPSHOT_API_URL | jq -r '.snapshot_name')
    GETH_FILE_NAME=$(curl -s $SNAPSHOT_API_URL | jq -r '.snapshot_geth_name')
    GETH_SNAPSHOT_URL="$SERVER_BASE_URL$GETH_FILE_NAME"
    STORY_SNAPSHOT_URL="$SERVER_BASE_URL$FILE_NAME"
}

# Function to choose snapshot type for Josephtran
choose_josephtran_snapshot() {
    echo -e "${GREEN}Choose the type of snapshot for Josephtran:${NC}"
    echo "1. Pruned"
    echo "2. Archive"
    read -p "Enter your choice: " snapshot_type_choice

    case $snapshot_type_choice in
        1)
            SNAPSHOT_API_URL=$JOSEPHTRAN_PRUNED_API_URL
            GETH_SNAPSHOT_URL=$JOSEPHTRAN_PRUNED_GETH_SNAPSHOT_URL
            STORY_SNAPSHOT_URL=$JOSEPHTRAN_PRUNED_STORY_SNAPSHOT_URL
            ;;
        2)
            SNAPSHOT_API_URL=$JOSEPHTRAN_ARCHIVE_API_URL
            GETH_SNAPSHOT_URL=$JOSEPHTRAN_ARCHIVE_GETH_SNAPSHOT_URL
            STORY_SNAPSHOT_URL=$JOSEPHTRAN_ARCHIVE_STORY_SNAPSHOT_URL
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac

    display_snapshot_details $SNAPSHOT_API_URL

    prompt_back_or_continue
}

# Function to choose snapshot for DTEAM
choose_DTEAM_snapshot() {
    GETH_SNAPSHOT_FILE="latest-geth-snapshot"
    STORY_SNAPSHOT_FILE="latest-snapshot"
    GETH_SNAPSHOT_URL=$DTEAM_PRUNED_GETH_SNAPSHOT_URL
    STORY_SNAPSHOT_URL=$DTEAM_PRUNED_STORY_SNAPSHOT_URL

    # Display DTEAM snapshot details
    display_snapshot_details $DTEAM_PRUNED_API_URL

    prompt_back_or_continue
}

# Function to choose snapshot type for OriginStake
choose_originstake_snapshot() {
    echo -e "${GREEN}Choose the type of snapshot for OriginStake:${NC}"
    echo "1. Pruned"
    echo "2. Archive"
    read -p "Enter your choice: " snapshot_type_choice

    case $snapshot_type_choice in
        1)
            SNAPSHOT_API_URL=$ORIGINSTAKE_PRUNED_API_URL
            ;;
        2)
            SNAPSHOT_API_URL=$ORIGINSTAKE_ARCHIVE_API_URL
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac

    display_snapshot_details $SNAPSHOT_API_URL

    prompt_back_or_continue

    FILE_NAME=$(curl -s $SNAPSHOT_API_URL | jq -r '.name')
    SNAPSHOT_URL="https://snapshot.originstake.com/$FILE_NAME"
}

# Function to decompress snapshots for Mandragora, ITRocket, and Josephtran
decompress_snapshots() {
    lz4 -c -d $GETH_SNAPSHOT_FILE | tar -xv -C $HOME/.story/geth/story/geth
    lz4 -c -d $STORY_SNAPSHOT_FILE | tar -xv -C $HOME/.story/story
}

# Function to decompress snapshot for CroutonDigital and OriginStake
decompress_crouton_originstake_snapshot() {
    lz4 -c -d $SNAPSHOT_FILE | tar -xv -C $HOME/.story
}

# Function to prompt user to back or continue
prompt_back_or_continue() {
    read -p "Press Enter to continue or type 'back' to go back to the menu: " user_choice
    if [[ $user_choice == "back" ]]; then
        main_script
    fi
}

# Function to check if cosmovisor is installed
check_cosmovisor() {
    if command -v cosmovisor &> /dev/null; then
        echo -e "${GREEN}Cosmovisor is installed.${NC}"
        return 0
    else
        echo -e "${RED}Cosmovisor is not installed.${NC}"
        return 1
    fi
}

# Function to suggest update based on snapshot block height
suggest_update() {
    local snapshot_height=$1
    current_version=$(cosmovisor version 2>&1 | awk '/^Version/ {print $2}')

    echo -e "${YELLOW}Current consensus client version: $current_version${NC}"

    if [[ $snapshot_height -ge 0 && $snapshot_height -le 640000 ]]; then
        required_version="v1.1.0-stable"
    elif [[ $snapshot_height -ge 640001 && $snapshot_height -le 3999999 ]]; then
        required_version="v1.1.1-stable"
    elif [[ $snapshot_height -ge 4000000 && $snapshot_height -le 5232999 ]]; then
        required_version="v1.2.0-stable"
    elif [[ $snapshot_height -ge 0 ]]; then
        required_version="v1.3.1-stable"
    #elif [[ $snapshot_height -ge 2065886 ]]; then
        #required_version="v0.13.2-stable"
    fi

    echo -e "${YELLOW}Required version for snapshot block height $snapshot_height: $required_version${NC}"

    if [[ $required_version == "v1.1.1-stable" ]]; then
        echo -e "${YELLOW}If an update is required, choose option 'b' at the consensus client update prompt.${NC}"
    elif [[ $required_version == "v1.2.0-stable" ]]; then
        echo -e "${YELLOW}If an update is required, choose option 'c' at the consensus client update prompt.${NC}"
    elif [[ $required_version == "v1.2.1-stable" ]]; then
        echo -e "${YELLOW}If an update is required, choose option 'd' at the consensus client update prompt.${NC}"
    elif [[ $required_version == "v1.3.1-stable" ]]; then
        echo -e "${YELLOW}If an update is required, choose option 'e' at the consensus client update prompt.${NC}"
    fi

    read -p "Do you want to update the consensus client version? (y/n): " update_choice
}

# Main script
main_script() {
    show_menu
    read -p "Enter your choice: " provider_choice

    provider_name=""

    case $provider_choice in
        2)
            provider_name="Mandragora"
            echo -e "${GREEN}Mandragora snapshot selected.${NC}"
            echo -e "Grand Valley extends its gratitude to ${YELLOW}$provider_name${NC} for providing snapshot support."

            echo -e "${GREEN}Checking availability of Mandragora snapshots:${NC}"
            echo -n "Pruned GETH Snapshot: "
            check_url $MAND_PRUNED_GETH_SNAPSHOT_URL
            echo -n "Pruned STORY Snapshot: "
            check_url $MAND_PRUNED_STORY_SNAPSHOT_URL
            echo -n "Archive GETH Snapshot: "
            check_url $MAND_ARCHIVE_GETH_SNAPSHOT_URL
            echo -n "Archive STORY Snapshot: "
            check_url $MAND_ARCHIVE_STORY_SNAPSHOT_URL

            prompt_back_or_continue

            choose_mandragora_snapshot
            GETH_SNAPSHOT_FILE="geth_snapshot.lz4"
            STORY_SNAPSHOT_FILE="story_snapshot.lz4"

            # Suggest update based on snapshot block height
            snapshot_height=$(curl -s $SNAPSHOT_API_URL | grep -oP '"snapshot_height":\s*\K\d+')
            suggest_update $snapshot_height

            # Ask the user if they want to delete the downloaded snapshot files
            read -p "When the snapshot has been applied (decompressed), do you want to delete the uncompressed files? (y/n): " delete_choice
            ;;
        #6)
            #provider_name="ITRocket"
            #echo -e "${GREEN}ITRocket snapshot selected.${NC}"
            #echo -e "Grand Valley extends its gratitude to ${YELLOW}$provider_name${NC} for providing snapshot support."

            #echo -e "${GREEN}Checking availability of ITRocket snapshots:${NC}"
            #echo -n "Pruned Snapshot (Server 1): "
            #check_url $ITR_PRUNED_API_URL_1
            #echo -n "Pruned Snapshot (Server 3): "
            #check_url $ITR_PRUNED_API_URL_2
            #echo -n "Archive Snapshot (Server 5): "
            #check_url $ITR_ARCHIVE_API_URL_1
            #echo -n "Archive Snapshot (Server 8): "
            #check_url $ITR_ARCHIVE_API_URL_2

            #prompt_back_or_continue

            #choose_itrocket_snapshot
            #GETH_SNAPSHOT_FILE=$GETH_FILE_NAME
            #STORY_SNAPSHOT_FILE=$FILE_NAME

            # Suggest update based on snapshot block height
            #snapshot_height=$(curl -s $SNAPSHOT_API_URL | jq -r '.snapshot_height')
            #suggest_update $snapshot_height

            # Ask the user if they want to delete the downloaded snapshot files
            #read -p "When the snapshot has been applied (decompressed), do you want to delete the uncompressed files? (y/n): " delete_choice
            #;;
        #4)
            #provider_name="CroutonDigital"
            #echo -e "Grand Valley extends its gratitude to ${YELLOW}$provider_name${NC} for providing snapshot support."

            #echo -e "${GREEN}Checking availability of CroutonDigital snapshot:${NC}"
            #echo -n "Archive Snapshot: "
            #check_url $CROUTON_SNAPSHOT_URL

            #prompt_back_or_continue

            #SNAPSHOT_FILE="story_latest.tar.lz4"
            #SNAPSHOT_URL=$CROUTON_SNAPSHOT_URL

            # Display snapshot details
            #display_snapshot_details $CROUTON_API_URL

            # Suggest update based on snapshot block height
            #snapshot_height=$(curl -s $CROUTON_API_URL | grep -oP '"latest_block_height":\s*"\K\d+')
            #suggest_update $snapshot_height

            # Ask the user if they want to delete the downloaded snapshot files
            #read -p "When the snapshot has been applied (decompressed), do you want to delete the uncompressed files? (y/n): " delete_choice
            #;;
        1)
            provider_name="Josephtran"
            echo -e "${GREEN}Josephtran snapshot selected.${NC}"
            echo -e "Grand Valley extends its gratitude to ${YELLOW}$provider_name${NC} for providing snapshot support."

            echo -e "${GREEN}Checking availability of Josephtran snapshots:${NC}"
            echo -n "Pruned GETH Snapshot: "
            check_url $JOSEPHTRAN_PRUNED_GETH_SNAPSHOT_URL
            echo -n "Pruned STORY Snapshot: "
            check_url $JOSEPHTRAN_PRUNED_STORY_SNAPSHOT_URL
            echo -n "Archive GETH Snapshot: "
            check_url $JOSEPHTRAN_ARCHIVE_GETH_SNAPSHOT_URL
            echo -n "Archive STORY Snapshot: "
            check_url $JOSEPHTRAN_ARCHIVE_STORY_SNAPSHOT_URL

            prompt_back_or_continue

            choose_josephtran_snapshot
            GETH_SNAPSHOT_FILE="Geth_snapshot.lz4"
            STORY_SNAPSHOT_FILE="Story_snapshot.lz4"

            # Suggest update based on snapshot block height
            snapshot_height=$(curl -s $SNAPSHOT_API_URL | grep -oP '"block_height":\s*\K\d+')
            suggest_update $snapshot_height

            # Ask the user if they want to delete the downloaded snapshot files
            read -p "When the snapshot has been applied (decompressed), do you want to delete the uncompressed files? (y/n): " delete_choice
            ;;
        #5)
            #provider_name="OriginStake"
            #echo -e "Grand Valley extends its gratitude to ${YELLOW}$provider_name${NC} for providing snapshot support."

            #echo -e "${GREEN}Checking availability of OriginStake snapshots:${NC}"
            #echo -n "Pruned Snapshot: "
            #check_url $ORIGINSTAKE_PRUNED_API_URL
            #echo -n "Archive Snapshot: "
            #check_url $ORIGINSTAKE_ARCHIVE_API_URL

            #prompt_back_or_continue

            #choose_originstake_snapshot
            #SNAPSHOT_FILE=$FILE_NAME
            #SNAPSHOT_URL=$SNAPSHOT_URL

            # Suggest update based on snapshot block height
            #snapshot_height=$(curl -s $SNAPSHOT_API_URL | jq -r '.height')
            #suggest_update $snapshot_height

            # Ask the user if they want to delete the downloaded snapshot files
            #read -p "When the snapshot has been applied (decompressed), do you want to delete the uncompressed files? (y/n): " delete_choice
            #;;
        3)
           provider_name="TTT VN"
           echo -e "${GREEN}TTT VN snapshot selected.${NC}"
           echo -e "Grand Valley extends its gratitude to ${YELLOW}$provider_name${NC} for providing snapshot support."

           echo -e "${GREEN}Checking availability of TTT VN snapshots:${NC}"
           echo -n "GETH Snapshot: "
           check_url $TTT_GETH_SNAPSHOT_URL
           echo -n "STORY Snapshot: "
           check_url $TTT_STORY_SNAPSHOT_URL

           prompt_back_or_continue

           # Display snapshot details
           display_snapshot_details $TTT_API_URL

           GETH_SNAPSHOT_URL=$TTT_GETH_SNAPSHOT_URL
           STORY_SNAPSHOT_URL=$TTT_STORY_SNAPSHOT_URL
           GETH_SNAPSHOT_FILE="story_geth_latest.tar.lz4"
           STORY_SNAPSHOT_FILE="story_latest.tar.lz4"

           prompt_back_or_continue

           # Suggest update based on snapshot block height
           snapshot_height=$(curl -s $TTT_API_URL | grep -oP '"latest_block_height":\s*"\K\d+')
           suggest_update $snapshot_height

           # Ask the user if they want to delete the downloaded snapshot files
           read -p "When the snapshot has been applied (decompressed), do you want to delete the uncompressed files? (y/n): " delete_choice
           ;;
        4)
           provider_name="DTEAM"
           echo -e "${GREEN}DTEAM snapshot selected.${NC}"
           echo -e "Grand Valley extends its gratitude to ${YELLOW}$provider_name${NC} for providing snapshot support."

           echo -e "${GREEN}Checking availability of DTEAM snapshots:${NC}"
           echo -n "GETH Snapshot: "
           check_url $DTEAM_PRUNED_GETH_SNAPSHOT_URL
           echo -n "STORY Snapshot: "
           check_url $DTEAM_PRUNED_STORY_SNAPSHOT_URL

           prompt_back_or_continue

           choose_DTEAM_snapshot

           # Suggest update based on snapshot block height
           snapshot_height=$(curl -s $DTEAM_PRUNED_API_URL | jq -r '.latest.height')
           suggest_update $snapshot_height

           # Ask the user if they want to delete the downloaded snapshot files
           read -p "When the snapshot has been applied (decompressed), do you want to delete the uncompressed files? (y/n): " delete_choice
           ;;
        5)
           echo -e "${GREEN}Exiting.${NC}"
           exit 0
           ;;
       *)
           echo -e "${RED}Invalid choice. Exiting.${NC}"
           exit 1
           ;;
    esac

    # Prompt the user for the download location
    read -p "Enter the directory where you want to download the snapshots (default is $HOME): " download_location
    download_location=${download_location:-$HOME}

    # Create the download directory if it doesn't exist
    mkdir -p $download_location

    # Change to the download directory
    cd $download_location

    # Install required dependencies
    sudo apt-get install wget lz4 jq -y

    # Stop your story-geth and story nodes
    sudo systemctl stop story-geth story
    sudo systemctl disable story-geth story

    # Back up your validator state
    cp $HOME/.story/story/data/priv_validator_state.json $HOME/.story/priv_validator_state.json.backup

    # Delete previous geth chaindata and story data folders
    sudo rm -rf $HOME/.story/geth/story/geth/chaindata $HOME/.story/story/data

    # Download and decompress snapshots
    cd $download_location
    if [[ $provider_choice -eq 1 || $provider_choice -eq 2 || $provider_choice -eq 3 || $provider_choice -eq 4 ]]; then
        wget -O $GETH_SNAPSHOT_FILE $GETH_SNAPSHOT_URL
        wget -O $STORY_SNAPSHOT_FILE $STORY_SNAPSHOT_URL
        decompress_snapshots
    elif [[ $provider_choice -eq 5 ]]; then
        wget -O $SNAPSHOT_FILE $SNAPSHOT_URL
        decompress_crouton_originstake_snapshot
    fi


    # Change ownership of the .story directory
    sudo chown -R $USER:$USER $HOME/.story

    # Delete downloaded snapshot files if the user chose to do so
    if [[ $delete_choice == "y" || $delete_choice == "Y" ]]; then
        if [[ $provider_choice -eq 1 || $provider_choice -eq 2 || $provider_choice -eq 3 || $provider_choice -eq 4 ]]; then
            sudo rm -v $GETH_SNAPSHOT_FILE $STORY_SNAPSHOT_FILE
        elif [[ $provider_choice -eq 5 ]]; then
            sudo rm -v $SNAPSHOT_FILE
        fi
        echo -e "${GREEN}Downloaded snapshot files have been deleted.${NC}"
    else
        echo -e "${GREEN}Downloaded snapshot files have been kept.${NC}"
    fi

    # Restore your validator state
    cp $HOME/.story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json

    # Execute the update script if the user chose to update
    if [[ $update_choice == "y" || $update_choice == "Y" ]]; then
        bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Mainnet-Guides/main/Story/resources/story_update.sh)
    fi

    # Start your story-geth and story nodes
    sudo systemctl enable story-geth story
    sudo systemctl restart story-geth story

    echo -e "${GREEN}Snapshot setup completed successfully.${NC}"
}

main_script

echo "Let's Buidl Story Together"
