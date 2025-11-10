#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Snapshot API URLs
# Grand Valley (0G) — assumes same API schema/rotation as 0G's service
# If your endpoint differs, update these two lines only.
GV_PRUNED_API_URL="https://pruned-snapshot-mainnet-0g.grandvalleys.com/pruned_snapshot_state.json"
GV_PRUNED_BASE_URL="https://pruned-snapshot-mainnet-0g.grandvalleys.com"

# ITRocket (fallback)
ITR_API_URL="https://server-3.itrocket.net/mainnet/og/.current_state.json"

# Function to display snapshot details
display_snapshot_details() {
    local api_url=$1
    local snapshot_info=$(curl -s $api_url)
    local snapshot_height=$(echo "$snapshot_info" | jq -r '.snapshot_height')

    echo -e "${GREEN}Snapshot Height:${NC} $snapshot_height"

    realtime_block_height=$(curl -s -X POST "https://evmrpc.0g.ai" -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq -r '.result' | xargs printf "%d\n")
    block_difference=$((realtime_block_height - snapshot_height))
    echo -e "${GREEN}Real-time Block Height:${NC} $realtime_block_height"
    echo -e "${GREEN}Block Difference:${NC} $block_difference"
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

# Function to prompt user to back or continue
prompt_back_or_continue() {
    read -p "Press Enter to continue or type 'back' to go back to the menu: " user_choice
    if [[ $user_choice == "back" ]]; then
        main_script
    fi
}

# Function to choose snapshot type for Grand Valley (0G)
choose_grandvalley_snapshot() {
    echo -e "${GREEN}Grand Valley snapshot selected.${NC}"
    echo -e "HEYLO MY 0G FAM... LETS SYNC FASTOOOOOOR!"

    # Fetch metadata and resolve file names robustly (support multiple schemas)
    local snapshot_info
    if ! snapshot_info="$(curl -fsS "$GV_PRUNED_API_URL")"; then
        echo -e "${RED}Failed to fetch snapshot info from Grand Valley.${NC}"
        return 1
    fi

    local cons_file geth_file
    cons_file=$(jq -r '(. ["0gchaind_snapshot_file_name"] // .["0g_snapshot_file_name"] // .ogchaind_snapshot_file_name // .consensus_snapshot_file_name // .snapshot_name // empty)' <<<"$snapshot_info")
    geth_file=$(jq -r '(. ["0g_geth_snapshot_file_name"] // .og_geth_snapshot_file_name // .geth_snapshot_file_name // .snapshot_geth_name // .geth_file_name // empty)' <<<"$snapshot_info")
    # Fallback detection by pattern
    if [[ -z "$geth_file" ]]; then
        geth_file=$(jq -r '.. | strings? | select(test("geth.*\\.(tar\\.lz4|lz4)$"; "i"))' <<<"$snapshot_info" | head -n1)
    fi
    if [[ -z "$cons_file" ]]; then
        # Prefer obvious consensus hints, else pick first archive not equal to geth file
        cons_file=$(jq -r '.. | strings? | select(test("(0g|chain|cons|chaind).*\\.(tar\\.lz4|lz4)$"; "i"))' <<<"$snapshot_info" | head -n1)
        if [[ -z "$cons_file" ]]; then
            # generic: any lz4 not equal to geth file
            while IFS= read -r f; do
                if [[ -n "$f" && "$f" != "$geth_file" ]]; then cons_file="$f"; break; fi
            done < <(jq -r '.. | strings? | select(test("\\.(tar\\.lz4|lz4)$"; "i"))' <<<"$snapshot_info")
        fi
    fi

    if [[ -z "$cons_file" || -z "$geth_file" ]]; then
        echo -e "${RED}Could not resolve snapshot filenames from API. Please verify API fields.${NC}"
        return 1
    fi

    GETH_URL="${GV_PRUNED_BASE_URL}/${geth_file}"
    CONS_URL="${GV_PRUNED_BASE_URL}/${cons_file}"

    echo -e "${GREEN}Checking availability of Grand Valley snapshots:${NC}"
    echo -n "Execution Client (0g-geth): "
    check_url "$GETH_URL" || return 1
    echo -n "Consensus Client (0gchaind): "
    check_url "$CONS_URL" || return 1

    prompt_back_or_continue

    # Display details (height/sha256/sizes) + realtime diff
    display_snapshot_details "$GV_PRUNED_API_URL"
    sha256_cons=$(jq -r '. ["sha256_0g"] // empty' <<<"$snapshot_info")
    sha256_geth=$(jq -r '. ["sha256_geth"] // empty' <<<"$snapshot_info")
    size_cons=$(jq -r '. ["0gchaind_snapshot_size"] // empty' <<<"$snapshot_info")
    size_geth=$(jq -r '. ["0g_geth_snapshot_size"] // empty' <<<"$snapshot_info")
    rot_period=$(jq -r '.rotation_period // empty' <<<"$snapshot_info")
    if [[ -n "$sha256_cons" ]]; then
        echo -e "${YELLOW}SHA256 (consensus):${NC} $sha256_cons"
    fi
    if [[ -n "$sha256_geth" ]]; then
        echo -e "${YELLOW}SHA256 (geth):${NC} $sha256_geth"
    fi
    if [[ -n "$size_cons" || -n "$size_geth" ]]; then
        echo -e "${GREEN}Sizes:${NC} consensus=$size_cons, geth=$size_geth"
    fi
    if [[ -n "$rot_period" ]]; then
        echo -e "${GREEN}Rotation:${NC} $rot_period"
    fi

    # Destination directories (execution + consensus home/data)
    EXEC_DIR="$HOME/.0gchaind/0g-home/geth-home/geth"
    CONS_HOME="$HOME/.0gchaind/0g-home/0gchaind-home"
    CONS_DATA="$CONS_HOME/data"

    read -p "When the snapshot has been applied (decompressed), do you want to delete the uncompressed files? (y/n): " delete_choice

    # Install helpers if needed
    sudo apt install wget lz4 jq -y

    # Stop services
    sudo systemctl stop 0gchaind 0g-geth || sudo systemctl stop 0gchaind 0ggeth
    sudo systemctl disable 0gchaind 0g-geth || sudo systemctl disable 0gchaind 0ggeth

    # Backup priv_validator_state.json if present
    if [ -f "$CONS_DATA/priv_validator_state.json" ]; then
        cp "$CONS_DATA/priv_validator_state.json" "$HOME/.0gchaind/priv_validator_state.json.backup"
    else
        echo -e "${YELLOW}priv_validator_state.json not found. Skipping backup.${NC}"
    fi

    # Clean old data
    mkdir -p "$EXEC_DIR"
    mkdir -p "$CONS_HOME"
    rm -rf "$EXEC_DIR/chaindata" "$CONS_DATA"

    echo -e "${GREEN}Decompressing Execution Snapshot to $EXEC_DIR ...${NC}"
    if ! curl -L "$GETH_URL" | lz4 -dc - | tar -xf - -C "$EXEC_DIR"; then
        echo -e "${RED}Failed to extract execution snapshot. Please check the archive structure or disk space.${NC}"
        exit 1
    fi

    echo -e "${GREEN}Decompressing Consensus Snapshot to $CONS_HOME ...${NC}"
    if ! curl -L "$CONS_URL" | lz4 -dc - | tar -xf - -C "$CONS_HOME"; then
        echo -e "${RED}Failed to extract consensus snapshot. Please check the archive structure or disk space.${NC}"
        exit 1
    fi

    sudo chown -R $USER:$USER "$HOME/.0gchaind"

    if [[ $delete_choice == "y" || $delete_choice == "Y" ]]; then
        echo -e "${YELLOW}Files were streamed directly and not saved locally.${NC}"
    else
        echo -e "${YELLOW}No local snapshot files to retain; they were streamed during extraction.${NC}"
    fi

    # Restore priv_validator_state.json if backed up
    if [ -f "$HOME/.0gchaind/priv_validator_state.json.backup" ]; then
        mkdir -p "$CONS_DATA"
        cp "$HOME/.0gchaind/priv_validator_state.json.backup" "$CONS_DATA/priv_validator_state.json"
    fi

    # Enable and restart services
    sudo systemctl enable 0gchaind 0g-geth || sudo systemctl enable 0gchaind 0ggeth
    sudo systemctl restart 0gchaind 0g-geth || sudo systemctl restart 0gchaind 0ggeth

    echo -e "${GREEN}0G snapshot setup (Grand Valley) completed successfully.${NC}"
}

# Function to download and decompress snapshots from ITRocket
extract_itrocket_snapshots() {
    mkdir -p "$EXEC_DIR"
    mkdir -p "$CONS_DIR"

    echo -e "${GREEN}Decompressing Execution Snapshot...${NC}"
    if ! curl "$GETH_URL" | lz4 -dc - | tar -xf - -C "$EXEC_DIR"; then
        echo -e "${RED}Failed to extract execution snapshot. Please check the archive structure or disk space.${NC}"
        exit 1
    fi

    echo -e "${GREEN}Decompressing Consensus Snapshot...${NC}"
    if ! curl "$CONS_URL" | lz4 -dc - | tar -xf - -C "$CONS_DIR"; then
        echo -e "${RED}Failed to extract consensus snapshot. Please check the archive structure or disk space.${NC}"
        exit 1
    fi
}

# Function to apply ITRocket snapshot
choose_itrocket_snapshot() {
    echo -e "${GREEN}ITRocket snapshot selected.${NC}"
    echo -e "Grand Valley extends its gratitude to ${YELLOW}ITRocket${NC} for providing snapshot support."

    echo -e "${GREEN}Checking availability of ITRocket snapshot:${NC}"

    SNAPSHOT_INFO=$(curl -s $ITR_API_URL)
    GETH_FILE=$(echo "$SNAPSHOT_INFO" | jq -r '.snapshot_geth_name')
    CONS_FILE=$(echo "$SNAPSHOT_INFO" | jq -r '.snapshot_name')

    GETH_URL="https://server-3.itrocket.net/mainnet/og/$GETH_FILE"
    CONS_URL="https://server-3.itrocket.net/mainnet/og/$CONS_FILE"

    echo -n "Execution Client (0g-geth) Snapshot: "
    check_url $GETH_URL
    echo -n "Consensus Client (0gchaind) Snapshot: "
    check_url $CONS_URL

    prompt_back_or_continue

    display_snapshot_details $ITR_API_URL

    read -p "Enter the directory where you want to download the snapshots (default is $HOME): " download_location
    download_location=${download_location:-$HOME}
    read -p "When the snapshot has been applied (decompressed), do you want to delete the downloaded files? (y/n): " delete_choice
    mkdir -p "$download_location"
    cd "$download_location"

    sudo apt install wget lz4 jq -y

    EXEC_DIR="$HOME/.0gchaind/0g-home/geth-home/geth"
    CONS_HOME="$HOME/.0gchaind/0g-home/0gchaind-home"
    CONS_DATA="$CONS_HOME/data"

    sudo systemctl stop 0gchaind 0g-geth || sudo systemctl stop 0gchaind 0ggeth
    sudo systemctl disable 0gchaind 0g-geth || sudo systemctl disable 0gchaind 0ggeth

    if [ -f "$CONS_DATA/priv_validator_state.json" ]; then
        cp "$CONS_DATA/priv_validator_state.json" "$HOME/.0gchaind/priv_validator_state.json.backup"
    else
        echo -e "${YELLOW}priv_validator_state.json not found. Skipping backup.${NC}"
    fi

    rm -rf "$EXEC_DIR/chaindata" "$CONS_DATA"

    extract_itrocket_snapshots

    sudo chown -R $USER:$USER "$HOME/.0gchaind"

    if [[ $delete_choice == "y" || $delete_choice == "Y" ]]; then
        echo -e "${YELLOW}Files were streamed directly and not saved locally.${NC}"
    else
        echo -e "${YELLOW}No local snapshot files to retain; they were streamed during extraction.${NC}"
    fi

    if [ -f "$HOME/.0gchaind/priv_validator_state.json.backup" ]; then
        mkdir -p "$CONS_DATA"
        cp "$HOME/.0gchaind/priv_validator_state.json.backup" "$CONS_DATA/priv_validator_state.json"
    fi

    sudo systemctl enable 0gchaind 0g-geth || sudo systemctl enable 0gchaind 0ggeth
    sudo systemctl restart 0gchaind 0g-geth || sudo systemctl restart 0gchaind 0ggeth

    echo -e "${GREEN}0G snapshot setup completed successfully.${NC}"
}

main_script() {
    echo -e "${GREEN}Choose a snapshot provider:${NC}"
    echo "1. Grand Valley"
    echo "2. Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1)
            choose_grandvalley_snapshot
            ;;
        2)
            echo -e "${YELLOW}Exiting.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Exiting.${NC}"
            exit 1
            ;;
    esac
}

main_script

echo "Let's Buidl 0G Together"
