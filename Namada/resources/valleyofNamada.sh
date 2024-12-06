#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RESET='\033[0m'

LOGO="

 __      __     _  _                        __   _   _                               _
 \ \    / /    | || |                      / _| | \ | |                             | |
  \ \  / /__ _ | || |  ___  _   _    ___  | |_  |  \| |  __ _  ________    __ _   __| |  __ _
  _\ \/ // __ || || | / _ \| | | |  / _ \ |  _| | . _ | / __ ||  _   _ \  / __ | / __ | / __ |
 | |\  /| (_| || || ||  __/| |_| | | (_) || |   | |\  || (_| || | | | | || (_| || (_| || (_| |
 | |_\/  \____||_||_| \___| \___ |  \___/ |_|   |_| \_| \____||_| |_| |_| \____| \____| \____|
 |  _ \ | | | |              __/ |
 | |_) || |_| |             |___/
 |____/  \___ |
          __/ |
         |___/
 __                                   
/__ __ __ __   _|   \  / __ | |  _    
\_| | (_| | | (_|    \/ (_| | | (/_ \/
                                    /
"

INTRO="
Valley of Namada by Grand Valley

${GREEN}Namada Validator Node System Requirements${RESET}
${YELLOW}| Category  | Requirements     |
| --------- | ---------------- |
| CPU       | 8+ cores         |
| RAM       | 32+ GB           |
| Storage   | 500+ GB NVMe SSD |
| Bandwidth | 100+ MBit/s      |${RESET}

- validator node service file name: ${CYAN}namadad.service${RESET}
- current chain: ${CYAN}namada.5f5de2dd1b88cba30586420${RESET}
- current namada node version: ${CYAN}v1.0.0${RESET}
"

PRIVACY_SAFETY_STATEMENT="
${YELLOW}Privacy and Safety Statement${RESET}

${GREEN}No User Data Stored Externally${RESET}
- This script does not store any user data externally. All operations are performed locally on your machine.

${GREEN}No Phishing Links${RESET}
- This script does not contain any phishing links. All URLs and commands are provided for legitimate purposes related to Namada validator node operations.

${GREEN}Security Best Practices${RESET}
- Always verify the integrity of the script and its source.
- Ensure you are running the script in a secure environment.
- Be cautious when entering sensitive information such as wallet names and addresses.

${GREEN}Disclaimer${RESET}
- The authors of this script are not responsible for any misuse or damage caused by the use of this script.
- Use this script at your own risk.

${GREEN}Contact${RESET}
- If you have any concerns or questions, please contact us at letsbuidltogether@grandvalleys.com.
"

ENDPOINTS="${GREEN}
Grand Valley Namada mainnet public endpoints:${RESET}
- cosmos-rpc: ${BLUE}https://lightnode-rpc-mainnet-namada.grandvalleys.com${RESET}
- evm-rpc: ${BLUE}https://lightnode-json-rpc-mainnet-namada.grandvalleys.com${RESET}
- cosmos ws: ${BLUE}wss://lightnode-rpc-mainnet-namada.grandvalleys.com/websocket${RESET}
- seed: ${BLUE}tcp://65882ea69f4146d8cc83564257252f4711d3e05e@seed-mainnet-namada.grandvalleys.com:56656${RESET}
- peer: ${BLUE}tcp://3879583b9c6b1ac29d38fefb5a14815dd79282d6@peer-mainnet-namada.grandvalleys.com:38656${RESET}

Stake to Grand Valley: ${CYAN}tnam1qyplu8gruqmmvwp7x7kd92m6x4xpyce265fa05r6${RESET}

${GREEN}Connect with Namada:${RESET}
- Official Website: ${BLUE}https://namada.net${RESET}
- X: ${BLUE}https://twitter.com/namada${RESET}
- Official Docs: ${BLUE}https://docs.namada.net${RESET}

${GREEN}Connect with Grand Valley:${RESET}
- X: ${BLUE}https://x.com/bacvalley${RESET}
- GitHub: ${BLUE}https://github.com/hubofvalley${RESET}
- Email: ${BLUE}letsbuidltogether@grandvalleys.com${RESET}
"

# Display LOGO and wait for user input to continue
echo -e "$LOGO"
echo -e "$PRIVACY_SAFETY_STATEMENT"
echo -e "\n${YELLOW}Press Enter to continue...${RESET}"
read -r

# Display INTRO section and wait for user input to continue
echo -e "$INTRO"
echo -e "$ENDPOINTS"
echo -e "\n${YELLOW}Press Enter to continue${RESET}"
read -r
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bash_profile
echo 'export NAMADA_CHAIN_ID="namada.5f5de2dd1b88cba30586420"' >> $HOME/.bash_profile
export NAMADA_CHAIN_ID="namada.5f5de2dd1b88cba30586420"
source $HOME/.bash_profile

# Validator Node Functions
function deploy_validator_node() {
    echo -e "${CYAN}Deploying Validator Node...${RESET}"
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Mainnet-Guides/main/Namada/resources/namada_validator_node_install_mainnet.sh)
    menu
}

function create_validator() {
    DEFAULT_WALLET=$WALLET_NAME # Assuming $WALLET_NAME is set elsewhere in your script
    read -p "Enter the name for your validator: " NAME

    read -p "Enter the commission rate: (e.g. 0.5) " COMMISION_RATE

    read -p "Enter the max commission rate change: (e.g. 0.5) " MAX_COMMISION_RATE_CHANGE

    read -p "Enter the email for your validator security contact: " EMAIL

    read -p "Enter wallet name/alias (leave empty to use current default wallet --> $DEFAULT_WALLET): " WALLET_NAME

    namadac init-validator --email "$EMAIL" --commission-rate "$COMMISION_RATE" --name "$NAME" --max-commission-rate-change "$MAX_COMMISION_RATE_CHANGE" --account-keys $WALLET_NAME --chain-id $NAMADA_CHAIN_ID
    menu
}

function add_seeds() {
    echo "Select an option:"
    echo "1. Add seeds manually"
    echo "2. Use Grand Valley's seed"
    read -p "Enter your choice (1 or 2): " choice

    case $choice in
        1)
            read -p "Enter seeds (comma-separated): " seeds
            echo "You have entered the following seeds: $seeds"
            read -p "Do you want to proceed? (yes/no): " confirm
            if [[ $confirm == "yes" ]]; then
                sed -i -e "s|^seeds *=.*|seeds = \"$seeds\"|" $HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420/config.toml
                echo "seeds added manually."
            else
                echo "Operation cancelled. Returning to menu."
                menu
            fi
            ;;
        2)
            seeds="tcp://65882ea69f4146d8cc83564257252f4711d3e05e@seed-mainnet-namada.grandvalleys.com:56656"
            echo "Grand Valley's seeds: $seeds"
            read -p "Do you want to proceed? (yes/no): " confirm
            if [[ $confirm == "yes" ]]; then
                sed -i -e "s|^seeds *=.*|seeds = \"$seeds\"|" $HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420/config.toml
                echo "Grand Valley's seeds added."
            else
                echo "Operation cancelled. Returning to menu."
                menu
            fi
            ;;
        *)
            echo "Invalid choice. Please enter 1 or 2."
            menu
            ;;
    esac
    echo "Now you can restart your Namada node"
    menu
}

function add_peers() {
    echo "Select an option:"
    echo "1. Add peers manually"
    echo "2. Use Grand Valley's peers"
    read -p "Enter your choice (1 or 2): " choice

    case $choice in
        1)
            read -p "Enter peers (comma-separated): " peers
            echo "You have entered the following peers: $peers"
            read -p "Do you want to proceed? (yes/no): " confirm
            if [[ $confirm == "yes" ]]; then
                sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420/config.toml
                echo "Peers added manually."
            else
                echo "Operation cancelled. Returning to menu."
                menu
            fi
            ;;
        2)
            peers=$(curl -sS https://lightnode-rpc-mainnet-namada.grandvalleys.com/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | paste -sd, -)
            echo "Grand Valley's peers: $peers"
            read -p "Do you want to proceed? (yes/no): " confirm
            if [[ $confirm == "yes" ]]; then
                sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420/config.toml
                echo "Grand Valley's peers added."
            else
                echo "Operation cancelled. Returning to menu."
                menu
            fi
            ;;
        *)
            echo "Invalid choice. Please enter 1 or 2."
            menu
            ;;
    esac
    echo "Now you can restart your Namada node"
    menu
}



function delete_validator_node() {
    sudo systemctl stop namadad
    sudo systemctl disable namadad
    sudo rm -rf /etc/systemd/system/namadad.service
    sudo rm -rf $HOME/namada
    sudo rm -rf $HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420/
    sudo rm /usr/local/bin/namad*
    sed -i "/NAMADA_/d" $HOME/.bash_profile
    echo -e "${RED}Namada Validator node deleted successfully.${RESET}"
    menu
}

function stop_validator_node() {
    sudo systemctl stop namadad
    echo "Namada validator node service stopped."
    menu
}

function restart_validator_node() {
    sudo systemctl daemon-reload
    sudo systemctl restart namadad
    echo "Namada validator node service restarted."
    menu
}

function backup_validator_key() {
    cp $HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420/cometbft/config/priv_validator_key.json $HOME/priv_validator_key.json
    echo -e "\n${YELLOW}Your priv_vaidator_key.json file has been copied to $HOME${RESET}"
    menu
}

function show_validator_node_logs() {
    echo "Displaying Namada Validator Node Logs:"
    sudo journalctl -u namadad -fn 100
    menu
}

function show_validator_node_status() {
    port=$(grep -oP 'laddr = "tcp://(0.0.0.0|127.0.0.1):\K[0-9]+57' "$HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420/config.toml")
    curl -s http://127.0.0.1:$port/status | jq
    echo -e "\n${YELLOW}Press Enter to go back to Valley of Namada main menu${RESET}"
    read -r
    menu
}

function install_namada_app() {
    echo -e "${YELLOW}This option is only for those who want to execute the transactions without running the node.${RESET}"
    wget https://github.com/anoma/namada/releases/download/v1.0.0/namada-v1.0.0-Linux-x86_64.tar.gz
    tar -xvf namada-v1.0.0-Linux-x86_64.tar.gz
    cd namada-v1.0.0-Linux-x86_64
    mv namad* /usr/local/bin/
    export NAMADA_CHAIN_ID="namada.5f5de2dd1b88cba30586420"
    export NAMADA_NETWORK_CONFIGS_SERVER="https://github.com/anoma/namada-mainnet-genesis/releases/download/mainnet-genesis/"
    export BASE_DIR="$HOME/.local/share/namada"
    echo 'export NAMADA_CHAIN_ID="namada.5f5de2dd1b88cba30586420"' >> $HOME/.bash_profile
    echo 'export BASE_DIR="$HOME/.local/share/namada"' >> $HOME/.bash_profile
    echo 'export NAMADA_NETWORK_CONFIGS_SERVER="https://github.com/anoma/namada-mainnet-genesis/releases/download/mainnet-genesis/"' >> $HOME/.bash_profile
    namadac utils join-network --chain-id $NAMADA_CHAIN_ID
    menu
}

function create_wallet() {
    echo -e "${RED}Write down your mnemonic and store it securely -- this is the only time it will be shown. You can use your mnemonic to recover your account if you lose access (for example, if your laptop stops working or is stolen). If you are locked out of your account, and you haven't saved your mnemonic, your funds will be lost forever.
    Also carefully note the encryption password you provided -- you will need to provide it any time you make a transaction.${RESET}"

    echo -e "${YELLOW}Please provide only the prefix for the wallet name/alias.${RESET}"
    echo -e "Aliases will be automatically generated as follows:"
    echo -e "  - Transparent key: ${CYAN}<prefix>${RESET}"
    echo -e "  - Shielded key: ${CYAN}<prefix>-shielded${RESET}"
    echo -e "  - Shielded payment address: ${CYAN}<prefix>-shielded-addr${RESET}\n"

    read -p "Enter wallet name/alias prefix: " WALLET_NAME
    namadaw gen --alias $WALLET_NAME
    namadaw derive --shielded --alias ${WALLET_NAME}-shielded
    namadaw gen-payment-addr --key ${WALLET_NAME}-shielded --alias ${WALLET_NAME}-shielded-addr
    namadaw find --alias $WALLET_NAME
    namadaw find --alias $WALLET_NAME-shielded
    namadaw find --alias $WALLET_NAME-shielded-addr
    echo -e "${GREEN}Wallet creation completed successfully, including shielded wallet restoration.${RESET}"
    echo -e "\n${YELLOW}Press Enter to go back to Valley of Namada main menu${RESET}"
    read -r
    menu
}

function restore_wallet() {
    echo -e "${YELLOW}Please provide only the prefix for the wallet name/alias.${RESET}"
    echo -e "Aliases will be automatically generated as follows:"
    echo -e "  - Transparent key: ${CYAN}<prefix>${RESET}"
    echo -e "  - Shielded key: ${CYAN}<prefix>-shielded${RESET}"
    echo -e "  - Shielded payment address: ${CYAN}<prefix>-shielded-addr${RESET}\n"

    read -p "Enter wallet name/alias prefix: " WALLET_NAME
    namadaw derive --alias $WALLET_NAME --hd-path default
    namadaw derive --shielded --alias ${WALLET_NAME}-shielded
    namadaw gen-payment-addr --key ${WALLET_NAME}-shielded --alias ${WALLET_NAME}-shielded-addr
    namadaw find --alias $WALLET_NAME
    namadaw find --alias $WALLET_NAME-shielded
    namadaw find --alias $WALLET_NAME-shielded-addr
    echo -e "${GREEN}Wallet restoration completed successfully, including shielded wallet restoration.${RESET}"
    echo -e "\n${YELLOW}Press Enter to go back to Valley of Namada main menu${RESET}"
    read -
    menu
}

function create_shielded_payment_address() {
    # List existing shielded keys
    SHIELDED_KEYS=$(namadaw list --shielded --keys)

    # Check if there are no shielded keys
    if [[ "$SHIELDED_KEYS" =~ "No known keys" ]]; then
        echo -e "${RED}No shielded keys found. Please create a shielded key first.${RESET}"
        echo -e "\n${YELLOW}Press Enter to go back to the main menu.${RESET}"
        read -r
        menu
        return
    fi

    # Prompt user to select a shielded key and provide alias prefix
    echo -e "${GREEN}Available Shielded Keys:${RESET}"
    echo "$SHIELDED_KEYS"
    read -p "Enter your shielded key full alias: " SHIELDED_KEY_ALIAS
    read -p "Enter your desired alias prefix for the payment address: " ALIAS_PREFIX

    # Base alias format
    NEXT_ALIAS=$ALIAS_PREFIX
    i=0

    # Check for existing aliases and find the next available one
    while namadaw find --alias "${NEXT_ALIAS}-shielded-addr" 2>/dev/null | grep -q "^  \"${NEXT_ALIAS}-shielded-addr\""; do
        ((i++))
        NEXT_ALIAS="${ALIAS_PREFIX}${i}"
    done

    # Create the new alias
    FULL_ALIAS="${NEXT_ALIAS}-shielded-addr"

    # Generate the new payment address with the formatted alias
    namadaw gen-payment-addr --key "$SHIELDED_KEY_ALIAS" --alias "$FULL_ALIAS"

    # Verify the creation of the payment address
    if namadaw find --alias "$FULL_ALIAS" 2>/dev/null | grep -q "^  \"$FULL_ALIAS\""; then
        echo -e "${GREEN}Payment address created successfully: ${FULL_ALIAS}${RESET}"
    else
        echo -e "${RED}Failed to create payment address. Please try again.${RESET}"
    fi

    namadaw list --shielded --addr

    echo -e "\n${YELLOW}Press Enter to go back to the main menu${RESET}"
    read -r
    menu
}

function show_wallet() {
    namadaw list --addr | grep "Implicit"
    echo
    namadaw list --keys
    echo
    namadaw list --shielded --addr

    echo -e "${YELLOW}Press Enter to go back to Valley of Namada main menu${RESET}"
    read -r
    menu
}

function query_balance() {
    DEFAULT_WALLET=$WALLET_NAME # Assuming $WALLET_NAME is set elsewhere in your script

    while true; do
        echo "Choose an option:"
        echo "1. Query the balance of my wallet"
        echo "2. Query the balance of another wallet address"
        echo "3. Back"
        read -p "Enter your choice (1, 2, or 3): " WALLET_CHOICE

        if [ "$WALLET_CHOICE" == "3" ]; then
            echo "Returning to the Valley of Namada main menu."
            menu
            return
        fi

        if [ "$WALLET_CHOICE" == "1" ]; then
            echo "Available Wallets:"
            namadaw list --addr | grep "Implicit"
            namadaw list --keys

            # Prompt user for wallet alias
            read -p "Enter wallet name/alias (leave empty to use current default wallet --> $DEFAULT_WALLET): " USER_INPUT_WALLET_NAME
            if [ -z "$USER_INPUT_WALLET_NAME" ]; then
                WALLET_NAME=$DEFAULT_WALLET
            else
                WALLET_NAME=$USER_INPUT_WALLET_NAME
            fi
            echo "Selected wallet: $WALLET_NAME"
        elif [ "$WALLET_CHOICE" == "2" ]; then
            read -p "Enter the custom wallet address: " WALLET_ADDRESS
            echo "Querying the balance of custom wallet address: $WALLET_ADDRESS"
        else
            echo "Invalid choice. Please enter 1, 2, or 3."
            continue
        fi

        echo "Choose an address type to query:"
        echo "1. Transparent address"
        echo "2. Shielded address (viewing key)"
        echo "3. Back"
        read -p "Enter your choice (1, 2, or 3): " CHOICE

        if [ "$CHOICE" == "3" ]; then
            echo "Returning to the Valley of Namada main menu."
            menu
            return
        fi

        # Prompt for RPC choice
        read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE

        case $CHOICE in
            1)
                if [ "$WALLET_CHOICE" == "1" ]; then
                    WALLET_ADDRESS=$WALLET_NAME
                fi
                if [ "$RPC_CHOICE" == "grandvalley" ]; then
                    namadac balance --owner $WALLET_ADDRESS --token NAM --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
                else
                    namadac balance --owner $WALLET_ADDRESS --token NAM
                fi
                ;;
            2)
                if [ "$WALLET_CHOICE" == "1" ]; then
                    WALLET_ADDRESS=$WALLET_NAME
                fi
                if [ "$RPC_CHOICE" == "grandvalley" ]; then
                    namadac balance --owner ${WALLET_ADDRESS} --token NAM --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
                else
                    namadac balance --owner ${WALLET_ADDRESS} --token NAM
                fi
                ;;
            *)
                echo "Invalid choice. Please enter 1 or 2."
                ;;
        esac

        echo -e "${YELLOW}Press Enter to go back to the Valley of Namada main menu${RESET}"
        read -r
        menu
    done
}

function transfer_transparent() {
    DEFAULT_WALLET=$WALLET_NAME # Assuming $WALLET_NAME is set elsewhere in your script
    while true; do
        read -p "Enter wallet name/alias (leave empty to use current default wallet --> $DEFAULT_WALLET): " WALLET_NAME
        if [ -z "$WALLET_NAME" ]; then
            WALLET_NAME=$DEFAULT_WALLET
        fi

        # Get wallet address
        WALLET_ADDRESS=$(namadaw find --alias $WALLET_NAME | grep -oP '(?<=Implicit: ).*')

        if [ -n "$WALLET_ADDRESS" ]; then
            break
        else
            echo "Wallet name not found. Please check the wallet name/alias and try again."
        fi
    done

    echo "Using wallet: $WALLET_NAME ($WALLET_ADDRESS)"

    read -p "Enter target transparent wallet address: " TARGET_TRANSPARENT_WALLET_ADDRESS

    read -p "Enter the amount to transfer: " AMOUNT

    read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE

    read -p "Which token do you want to interact with? (1: NAM, 2: OSMO): " TOKEN_CHOICE
    if [ "$TOKEN_CHOICE" == "1" ]; then
        TOKEN="NAM"
    elif [ "$TOKEN_CHOICE" == "2" ]; then
        TOKEN="tnam1p5z8ruwyu7ha8urhq2l0dhpk2f5dv3ts7uyf2n75"
    else
        echo "Invalid token choice. Defaulting to NAM."
        TOKEN="NAM"
    fi

    if [ "$RPC_CHOICE" == "grandvalley" ]; then
        namadac transparent-transfer --source $WALLET_ADDRESS --target $TARGET_TRANSPARENT_WALLET_ADDRESS --token $TOKEN --amount $AMOUNT --signing-keys $WALLET_NAME --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
    else
        namadac transparent-transfer --source $WALLET_ADDRESS --target $TARGET_TRANSPARENT_WALLET_ADDRESS --token $TOKEN --amount $AMOUNT --signing-keys $WALLET_NAME
    fi

    echo -e "${GREEN}Transfer from transparent address to another transparent address completed successfully.${RESET}"
    echo -e "${YELLOW}Press Enter to go back to Valley of Namada main menu${RESET}"
    read -r
    menu
}

function stake_tokens() {
    sudo apt install bc
    DEFAULT_WALLET=$WALLET_NAME # Assuming $WALLET_NAME is set elsewhere in your script
    while true; do
        read -p "Enter wallet name/alias (leave empty to use current default wallet --> $DEFAULT_WALLET): " WALLET_NAME
        if [ -z "$WALLET_NAME" ]; then
            WALLET_NAME=$DEFAULT_WALLET
        fi

        # Get wallet address
        WALLET_ADDRESS=$(namadaw find --alias $WALLET_NAME | grep -oP '(?<=Implicit: ).*')

        if [ -n "$WALLET_ADDRESS" ]; then
            break
        else
            echo "Wallet name not found. Please check the wallet name/alias and try again."
        fi
    done

    echo "Using wallet: $WALLET_NAME ($WALLET_ADDRESS)"

    echo "Choose an option:"
    echo "1. Delegate to Grand Valley"
    echo "2. Self-delegate"
    echo "3. Delegate to another validator"
    echo "4. Back"
    read -p "Enter your choice (1, 2, 3 or 4): " CHOICE

    case $CHOICE in
        1)
            read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE
            read -p "Enter amount to stake: " AMOUNT
            VALIDATOR_ADDRESS="tnam1qyplu8gruqmmvwp7x7kd92m6x4xpyce265fa05r6"
            if [ "$RPC_CHOICE" == "grandvalley" ]; then
                namadac bond --source $WALLET_NAME --validator $VALIDATOR_ADDRESS --amount $AMOUNT --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
            else
                namadac bond --source $WALLET_NAME --validator $VALIDATOR_ADDRESS --amount $AMOUNT
            fi
            ;;
        2)
            read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE
            read -p "Enter amount to stake: " AMOUNT
            port=$(grep -oP 'laddr = "tcp://(0.0.0.0|127.0.0.1):\K[0-9]+57' "$HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420/config.toml")
            VALIDATOR_ADDRESS=$(namadac find-validator --tm-address=$(curl -s 127.0.0.1:$port/status | jq -r .result.validator_info.address) | grep 'Found validator address' | awk -F'"' '{print $2}')

            # Ask if the user wants to support Grand Valley
            read -p "Enjoying this? Support Grand Valley by delegating 5% of your stake! :) (y/n): " SUPPORT_GV
            if [ "$SUPPORT_GV" == "y" ]; then
                GV_AMOUNT=$(echo "$AMOUNT * 0.05" | bc)
                GV_VALIDATOR_ADDRESS="tnam1qyplu8gruqmmvwp7x7kd92m6x4xpyce265fa05r6"
                AMOUNT=$(echo "$AMOUNT - $GV_AMOUNT" | bc)
            fi

            if [ "$RPC_CHOICE" == "grandvalley" ]; then
                namadac bond --source $WALLET_NAME --validator $VALIDATOR_ADDRESS --amount $AMOUNT --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
            else
                namadac bond --source $WALLET_NAME --validator $VALIDATOR_ADDRESS --amount $AMOUNT
            fi

            if [ "$SUPPORT_GV" == "y" ]; then
                if [ "$RPC_CHOICE" == "grandvalley" ]; then
                    namadac bond --source $WALLET_NAME --validator $GV_VALIDATOR_ADDRESS --amount $GV_AMOUNT --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
                else
                    namadac bond --source $WALLET_NAME --validator $GV_VALIDATOR_ADDRESS --amount $GV_AMOUNT
                fi
            fi
            ;;
        3)
            read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE
            read -p "Enter amount to stake: " AMOUNT
            read -p "Enter validator address: " VALIDATOR_ADDRESS

            # Ask if the user wants to support Grand Valley
            read -p "I hope you're enjoying this! Support Grand Valley by delegating 5% of your stake! :) (y/n): " SUPPORT_GV
            if [ "$SUPPORT_GV" == "y" ]; then
                GV_AMOUNT=$(echo "$AMOUNT * 0.05" | bc)
                GV_VALIDATOR_ADDRESS="tnam1qyplu8gruqmmvwp7x7kd92m6x4xpyce265fa05r6"
                AMOUNT=$(echo "$AMOUNT - $GV_AMOUNT" | bc)
            fi

            if [ "$RPC_CHOICE" == "grandvalley" ]; then
                namadac bond --source $WALLET_NAME --validator $VALIDATOR_ADDRESS --amount $AMOUNT --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
            else
                namadac bond --source $WALLET_NAME --validator $VALIDATOR_ADDRESS --amount $AMOUNT
            fi

            if [ "$SUPPORT_GV" == "y" ]; then
                if [ "$RPC_CHOICE" == "grandvalley" ]; then
                    namadac bond --source $WALLET_NAME --validator $GV_VALIDATOR_ADDRESS --amount $GV_AMOUNT --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
                else
                    namadac bond --source $WALLET_NAME --validator $GV_VALIDATOR_ADDRESS --amount $GV_AMOUNT
                fi
            fi
            ;;
        4)
            echo "Returning to the Valley of Namada main menu."
            menu
            ;;
        *)
            echo "Invalid choice. Please enter 1, 2, 3 or 4"
            ;;
    esac
    echo -e "${YELLOW}Press Enter to go back to Valley of Namada main menu${RESET}"
    read -r
    menu
}

function unstake_tokens() {
    DEFAULT_WALLET=$WALLET_NAME # Assuming $WALLET_NAME is set elsewhere in your script
    while true; do
        read -p "Enter wallet name/alias (leave empty to use current default wallet --> $DEFAULT_WALLET): " WALLET_NAME
        if [ -z "$WALLET_NAME" ]; then
            WALLET_NAME=$DEFAULT_WALLET
        fi

        # Get wallet address
        WALLET_ADDRESS=$(namadaw find --alias $WALLET_NAME | grep -oP '(?<=Implicit: ).*')

        if [ -n "$WALLET_ADDRESS" ]; then
            break
        else
            echo "Wallet name not found. Please check the wallet name/alias and try again."
        fi
    done

    echo "Using wallet: $WALLET_NAME ($WALLET_ADDRESS)"

    echo "Choose an option:"
    echo "1. Self-undelegate"
    echo "2. Undelegate from another validator"
    echo "3. Back"
    read -p "Enter your choice (1 or 2): " CHOICE

    case $CHOICE in
        1)
            read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE
            read -p "Enter amount to unstake: " AMOUNT
            port=$(grep -oP 'laddr = "tcp://(0.0.0.0|127.0.0.1):\K[0-9]+57' "$HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420/config.toml")
            VALIDATOR_ADDRESS=$(namadac find-validator --tm-address=$(curl -s 127.0.0.1:$port/status | jq -r .result.validator_info.address) --node https://lightnode-rpc-mainnet-namada.grandvalleys.com | grep 'Found validator address' | awk -F'"' '{print $2}')
            if [ "$RPC_CHOICE" == "grandvalley" ]; then
                namadac unbond --source $WALLET_NAME --validator $VALIDATOR_ADDRESS --amount $AMOUNT --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
            else
                namadac unbond --source $WALLET_NAME --validator $VALIDATOR_ADDRESS --amount $AMOUNT
            fi
            ;;
        2)
            read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE
            read -p "Enter validator address: " VALIDATOR_ADDRESS
            read -p "Enter amount to unstake: " AMOUNT
            if [ "$RPC_CHOICE" == "grandvalley" ]; then
                namadac unbond --source $WALLET_NAME --validator $VALIDATOR_ADDRESS --amount $AMOUNT --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
            else
                namadac unbond --source $WALLET_NAME --validator $VALIDATOR_ADDRESS --amount $AMOUNT
            fi
            ;;
        3)
            echo "Returning to the Valley of Namada main menu."
            menu
            ;;
        *)
            echo "Invalid choice. Please enter 1, 2 or 3."
            ;;
    esac
    echo -e "${YELLOW}Press Enter to go back to Valley of Namada main menu${RESET}"
    read -r
    menu
}

function redelegate_tokens() {
    sudo apt install bc
    DEFAULT_WALLET=$WALLET_NAME # Assuming $WALLET_NAME is set elsewhere in your script
    while true; do
        read -p "Enter wallet name/alias (leave empty to use current default wallet --> $DEFAULT_WALLET): " WALLET_NAME
        if [ -z "$WALLET_NAME" ]; then
            WALLET_NAME=$DEFAULT_WALLET
        fi

        # Get wallet address
        WALLET_ADDRESS=$(namadaw find --alias $WALLET_NAME | grep -oP '(?<=Implicit: ).*')

        if [ -n "$WALLET_ADDRESS" ]; then
            break
        else
            echo "Wallet name not found. Please check the wallet name/alias and try again."
        fi
    done

    echo "Using wallet: $WALLET_NAME ($WALLET_ADDRESS)"

    echo "Choose an option:"
    echo "1. Redelegate to Grand Valley"
    echo "2. Redelegate from your validator"
    echo "3. Redelegate from another validator"
    echo "4. Back"
    read -p "Enter your choice (1, 2, 3 or 4): " CHOICE


    case $CHOICE in
        1)
            read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE
            read -p "Enter amount to redelegate: " AMOUNT
            TARGET_VALIDATOR_ADDRESS="tnam1qyplu8gruqmmvwp7x7kd92m6x4xpyce265fa05r6"
            read -p "Enter source validator address: " SOURCE_VALIDATOR_ADDRESS

            if [ "$RPC_CHOICE" == "grandvalley" ]; then
                namadac redelegate --source-validator $SOURCE_VALIDATOR_ADDRESS --destination-validator $TARGET_VALIDATOR_ADDRESS --owner $WALLET_NAME --amount $AMOUNT --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
            else
                namadac redelegate --source-validator $SOURCE_VALIDATOR_ADDRESS --destination-validator $TARGET_VALIDATOR_ADDRESS --owner $WALLET_NAME --amount $AMOUNT
            fi
            ;;
        2)
            read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE
            read -p "Enter amount to redelegate: " AMOUNT
            port=$(grep -oP 'laddr = "tcp://(0.0.0.0|127.0.0.1):\K[0-9]+57' "$HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420/config.toml")
            SOURCE_VALIDATOR_ADDRESS=$(namadac find-validator --tm-address=$(curl -s 127.0.0.1:$port/status | jq -r .result.validator_info.address) --node https://lightnode-rpc-mainnet-namada.grandvalleys.com | grep 'Found validator address' | awk -F'"' '{print $2}')

            read -p "Enter destination validator address: " TARGET_VALIDATOR_ADDRESS

            # Ask if the user wants to support Grand Valley
            read -p "Glad this helped! Would you consider supporting me by redelegating 5% of your amount to Grand Valley? :) (y/n): " SUPPORT_GV
            if [ "$SUPPORT_GV" == "y" ]; then
                GV_AMOUNT=$(echo "$AMOUNT * 0.05" | bc)
                GV_VALIDATOR_ADDRESS="tnam1qyplu8gruqmmvwp7x7kd92m6x4xpyce265fa05r6"
                AMOUNT=$(echo "$AMOUNT - $GV_AMOUNT" | bc)
            fi

            if [ "$RPC_CHOICE" == "grandvalley" ]; then
                namadac redelegate --source-validator $SOURCE_VALIDATOR_ADDRESS --destination-validator $TARGET_VALIDATOR_ADDRESS --owner $WALLET_NAME --amount $AMOUNT --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
            else
                namadac redelegate --source-validator $SOURCE_VALIDATOR_ADDRESS --destination-validator $TARGET_VALIDATOR_ADDRESS --owner $WALLET_NAME --amount $AMOUNT
            fi

            if [ "$SUPPORT_GV" == "y" ]; then
                if [ "$RPC_CHOICE" == "grandvalley" ]; then
                    namadac redelegate --source-validator $SOURCE_VALIDATOR_ADDRESS --destination-validator $GV_VALIDATOR_ADDRESS --owner $WALLET_NAME --amount $GV_AMOUNT --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
                else
                    namadac redelegate --source-validator $SOURCE_VALIDATOR_ADDRESS --destination-validator $GV_VALIDATOR_ADDRESS --owner $WALLET_NAME --amount $GV_AMOUNT
                fi
            fi
            ;;
        3)
            read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE
            read -p "Enter amount to redelegate: " AMOUNT
            read -p "Enter source validator address: " SOURCE_VALIDATOR_ADDRESS
            read -p "Enter destination validator address: " TARGET_VALIDATOR_ADDRESS

            # Ask if the user wants to support Grand Valley
            read -p "Glad this helped! Would you consider supporting me by redelegating 5% of your amount to Grand Valley? :) (y/n): " SUPPORT_GV
            if [ "$SUPPORT_GV" == "y" ]; then
                GV_AMOUNT=$(echo "$AMOUNT * 0.05" | bc)
                GV_VALIDATOR_ADDRESS="tnam1qyplu8gruqmmvwp7x7kd92m6x4xpyce265fa05r6"
                AMOUNT=$(echo "$AMOUNT - $GV_AMOUNT" | bc)
            fi

            if [ "$RPC_CHOICE" == "grandvalley" ]; then
                namadac redelegate --source-validator $SOURCE_VALIDATOR_ADDRESS --destination-validator $TARGET_VALIDATOR_ADDRESS --owner $WALLET_NAME --amount $AMOUNT --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
            else
                namadac redelegate --source-validator $SOURCE_VALIDATOR_ADDRESS --destination-validator $TARGET_VALIDATOR_ADDRESS --owner $WALLET_NAME --amount $AMOUNT
            fi

            if [ "$SUPPORT_GV" == "y" ]; then
                if [ "$RPC_CHOICE" == "grandvalley" ]; then
                    namadac redelegate --source-validator $SOURCE_VALIDATOR_ADDRESS --destination-validator $GV_VALIDATOR_ADDRESS --owner $WALLET_NAME --amount $GV_AMOUNT --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
                else
                    namadac redelegate --source-validator $SOURCE_VALIDATOR_ADDRESS --destination-validator $GV_VALIDATOR_ADDRESS --owner $WALLET_NAME --amount $GV_AMOUNT
                fi
            fi
            ;;
        4)
            echo "Returning to the Valley of Namada main menu."
            menu
            ;;
        *)
            echo "Invalid choice. Please enter 1, 2, 3 or 4."
            ;;
    esac
    echo -e "${YELLOW}Press Enter to go back to Valley of Namada main menu${RESET}"
    read -r
    menu
}

function withdraw_unbonded_tokens() {
    DEFAULT_WALLET=$WALLET_NAME # Assuming $WALLET_NAME is set elsewhere in your script
    while true; do
        read -p "Enter wallet name/alias (leave empty to use current default wallet --> $DEFAULT_WALLET): " WALLET_NAME
        if [ -z "$WALLET_NAME" ]; then
            WALLET_NAME=$DEFAULT_WALLET
        fi

        # Get wallet address
        WALLET_ADDRESS=$(namadaw find --alias $WALLET_NAME | grep -oP '(?<=Implicit: ).*')

        if [ -n "$WALLET_ADDRESS" ]; then
            break
        else
            echo "Wallet name not found. Please check the wallet name/alias and try again."
        fi
    done

    echo "Using wallet: $WALLET_NAME ($WALLET_ADDRESS)"

    read -p "Enter validator address: " VALIDATOR_ADDRESS

    read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE

    if [ "$RPC_CHOICE" == "grandvalley" ]; then
        namadac withdraw --source $WALLET_NAME --validator $VALIDATOR_ADDRESS --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
    else
        namadac withdraw --source $WALLET_NAME --validator $VALIDATOR_ADDRESS
    fi
    echo -e "${YELLOW}Press Enter to go back to Valley of Namada main menu${RESET}"
    read -r
    menu
}

function claim_rewards() {
    DEFAULT_WALLET=$WALLET_NAME # Assuming $WALLET_NAME is set elsewhere in your script
    while true; do
        read -p "Enter wallet name/alias (leave empty to use current default wallet --> $DEFAULT_WALLET): " WALLET_NAME
        if [ -z "$WALLET_NAME" ]; then
            WALLET_NAME=$DEFAULT_WALLET
        fi

        # Get wallet address
        WALLET_ADDRESS=$(namadaw find --alias $WALLET_NAME | grep -oP '(?<=Implicit: ).*')

        if [ -n "$WALLET_ADDRESS" ]; then
            break
        else
            echo "Wallet name not found. Please check the wallet name/alias and try again."
        fi
    done

    echo "Using wallet: $WALLET_NAME ($WALLET_ADDRESS)"

    read -p "Enter validator address: " VALIDATOR_ADDRESS

    read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE

    if [ "$RPC_CHOICE" == "grandvalley" ]; then
        namadac claim-rewards --source $WALLET_NAME --validator $VALIDATOR_ADDRESS --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
    else
        namadac claim-rewards --source $WALLET_NAME --validator $VALIDATOR_ADDRESS
    fi
    echo -e "${YELLOW}Press Enter to go back to Valley of Namada main menu${RESET}"
    read -r
    menu
}

function transfer_shielding() {
    DEFAULT_WALLET=$WALLET_NAME # Assuming $WALLET_NAME is set elsewhere in your script

    # Show available wallets
    echo "Available wallets:"
    namadaw list | grep Implicit | grep -vE 'consensus-key|tendermint-node-key'

    while true; do
        read -p "Enter source wallet name/alias (leave empty to use current default wallet --> $DEFAULT_WALLET): " SOURCE_WALLET_NAME
        if [ -z "$SOURCE_WALLET_NAME" ]; then
            SOURCE_WALLET_NAME=$DEFAULT_WALLET
        fi

        # Get source wallet address
        SOURCE_WALLET_ADDRESS=$(namadaw find --alias $SOURCE_WALLET_NAME | grep -oP '(?<=Implicit: ).*')

        if [ -n "$SOURCE_WALLET_ADDRESS" ]; then
            break
        else
            echo "Source wallet name not found. Please check the wallet name/alias and try again."
        fi
    done

    echo "Using source wallet: $SOURCE_WALLET_NAME ($SOURCE_WALLET_ADDRESS)"

    # Show available shielded wallets
    echo "Available shielded wallets:"
    namadaw list | grep shielded-addr

    while true; do
        read -p "Enter target shielded wallet name/alias (leave empty to use default shielded wallet --> ${SOURCE_WALLET_NAME}-shielded-addr): " TARGET_WALLET_NAME
        if [ -z "$TARGET_WALLET_NAME" ]; then
            TARGET_WALLET_NAME="${SOURCE_WALLET_NAME}-shielded-addr"
        fi

        # Get target shielded wallet address
        TARGET_WALLET_ADDRESS=$(namadaw find --alias $TARGET_WALLET_NAME | grep 'znam' | awk '{print $2}' | tr -d '"')

        if [ -n "$TARGET_WALLET_ADDRESS" ]; then
            break
        else
            echo "Target shielded wallet name not found. Please check the wallet name/alias and try again."
        fi
    done

    echo "Using target shielded wallet: $TARGET_WALLET_NAME ($TARGET_WALLET_ADDRESS)"

    read -p "Enter the amount to shield: " AMOUNT

    read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE

    read -p "Which token do you want to interact with? (1: NAM, 2: OSMO): " TOKEN_CHOICE
    if [ "$TOKEN_CHOICE" == "1" ]; then
        TOKEN="NAM"
    elif [ "$TOKEN_CHOICE" == "2" ]; then
        TOKEN="tnam1p5z8ruwyu7ha8urhq2l0dhpk2f5dv3ts7uyf2n75"
    else
        echo "Invalid token choice. Defaulting to NAM."
        TOKEN="NAM"
    fi

    if [ "$RPC_CHOICE" == "grandvalley" ]; then
        namadac shield --source $SOURCE_WALLET_NAME --target $TARGET_WALLET_NAME --token $TOKEN --amount $AMOUNT --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
    else
        namadac shield --source $SOURCE_WALLET_NAME --target $TARGET_WALLET_NAME --token $TOKEN --amount $AMOUNT
    fi

    echo -e "${GREEN}Transfer from transparent account to shielded account (shielding) completed successfully.${RESET}"
    echo -e "${YELLOW}Press Enter to go back to Valley of Namada main menu${RESET}"
    read -r
    menu
}

function transfer_shielded_to_shielded() {
    DEFAULT_WALLET=$WALLET_NAME # Assuming $WALLET_NAME is set elsewhere in your script
    while true; do
        read -p "Enter wallet name/alias (leave empty to use current default wallet --> $DEFAULT_WALLET): " WALLET_NAME
        if [ -z "$WALLET_NAME" ]; then
            WALLET_NAME=$DEFAULT_WALLET
        fi

        # Get wallet address
        WALLET_ADDRESS=$(namadaw find --alias $WALLET_NAME | grep -oP '(?<=Implicit: ).*')

        if [ -n "$WALLET_ADDRESS" ]; then
            break
        else
            echo "Wallet name not found. Please check the wallet name/alias and try again."
        fi
    done

    echo "Using wallet: $WALLET_NAME ($WALLET_ADDRESS)"

    read -p "Enter target shielded wallet address: " TARGET_SHIELDED_WALLET_ADDRESS

    read -p "Enter the amount to transfer: " AMOUNT

    read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE

    read -p "Which token do you want to interact with? (1: NAM, 2: OSMO): " TOKEN_CHOICE
    if [ "$TOKEN_CHOICE" == "1" ]; then
        TOKEN="NAM"
    elif [ "$TOKEN_CHOICE" == "2" ]; then
        TOKEN="tnam1p5z8ruwyu7ha8urhq2l0dhpk2f5dv3ts7uyf2n75"
    else
        echo "Invalid token choice. Defaulting to NAM."
        TOKEN="NAM"
    fi

    if [ "$RPC_CHOICE" == "grandvalley" ]; then
        namadac transfer --source ${WALLET_NAME}-shielded --target $TARGET_SHIELDED_WALLET_ADDRESS --token $TOKEN --amount $AMOUNT --signing-keys $WALLET_NAME --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
    else
        namadac transfer --source ${WALLET_NAME}-shielded --target $TARGET_SHIELDED_WALLET_ADDRESS --token $TOKEN --amount $AMOUNT --signing-keys $WALLET_NAME
    fi

    echo -e "${GREEN}Transfer from shielded address to another shielded address completed successfully.${RESET}"
    echo -e "${YELLOW}Press Enter to go back to Valley of Namada main menu${RESET}"
    read -r
    menu
}

function transfer_unshielding() {
    DEFAULT_WALLET=$WALLET_NAME # Assuming $WALLET_NAME is set elsewhere in your script

    # Show available shielded wallets
    echo "Available shielded wallets:"
    namadaw list | grep shielded

    while true; do
        read -p "Enter shielded wallet name/alias (leave empty to use default shielded wallet --> ${DEFAULT_WALLET}-shielded): " SHIELDED_WALLET_NAME
        if [ -z "$SHIELDED_WALLET_NAME" ]; then
            SHIELDED_WALLET_NAME="${DEFAULT_WALLET}-shielded"
        fi

        # Get shielded wallet address
        SHIELDED_WALLET_ADDRESS=$(namadaw find --alias $SHIELDED_WALLET_NAME | grep 'znam' | awk '{print $2}' | tr -d '"')

        if [ -n "$SHIELDED_WALLET_ADDRESS" ]; then
            break
        else
            echo "Shielded wallet name not found. Please check the wallet name/alias and try again."
        fi
    done

    echo "Using shielded wallet: $SHIELDED_WALLET_NAME ($SHIELDED_WALLET_ADDRESS)"

    # Show available wallets
    echo "Available wallets:"
    namadaw list | grep Implicit | grep -vE 'consensus-key|tendermint-node-key'

    while true; do
        read -p "Enter target wallet name/alias (leave empty to use current default wallet --> $DEFAULT_WALLET): " TARGET_WALLET_NAME
        if [ -z "$TARGET_WALLET_NAME" ]; then
            TARGET_WALLET_NAME=$DEFAULT_WALLET
        fi

        # Get target wallet address
        TARGET_WALLET_ADDRESS=$(namadaw find --alias $TARGET_WALLET_NAME | grep -oP '(?<=Implicit: ).*')

        if [ -n "$TARGET_WALLET_ADDRESS" ]; then
            break
        else
            echo "Target wallet name not found. Please check the wallet name/alias and try again."
        fi
    done

    echo "Using target wallet: $TARGET_WALLET_NAME ($TARGET_WALLET_ADDRESS)"

    read -p "Enter the amount to unshield: " AMOUNT

    read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE

    read -p "Which token do you want to interact with? (1: NAM, 2: OSMO): " TOKEN_CHOICE
    if [ "$TOKEN_CHOICE" == "1" ]; then
        TOKEN="NAM"
    elif [ "$TOKEN_CHOICE" == "2" ]; then
        TOKEN="tnam1p5z8ruwyu7ha8urhq2l0dhpk2f5dv3ts7uyf2n75"
    else
        echo "Invalid token choice. Defaulting to NAM."
        TOKEN="NAM"
    fi

    if [ "$RPC_CHOICE" == "grandvalley" ]; then
        namadac unshield --source $SHIELDED_WALLET_NAME --target $TARGET_WALLET_NAME --token $TOKEN --amount $AMOUNT --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
    else
        namadac unshield --source $SHIELDED_WALLET_NAME --target $TARGET_WALLET_NAME --token $TOKEN --amount $AMOUNT
    fi

    echo -e "${GREEN}Transfer from shielded account to transparent account (unshielding) completed successfully.${RESET}"
    echo -e "${YELLOW}Press Enter to go back to Valley of Namada main menu${RESET}"
    read -r
    menu
}

function vote_proposal() {
    DEFAULT_WALLET=$WALLET_NAME # Assuming $WALLET_NAME is set elsewhere in your script
    while true; do
        read -p "Enter wallet name/alias to use as signing keys (leave empty to use current default wallet --> $DEFAULT_WALLET): " WALLET_NAME
        if [ -z "$WALLET_NAME" ]; then
            WALLET_NAME=$DEFAULT_WALLET
        fi

        # Get wallet address
        WALLET_ADDRESS=$(namadaw find --alias $WALLET_NAME | grep -oP '(?<=Implicit: ).*')

        if [ -n "$WALLET_ADDRESS" ]; then
            break
        else
            echo "Wallet name not found. Please check the wallet name/alias and try again."
        fi
    done

    echo "Using wallet: $WALLET_NAME ($WALLET_ADDRESS)"

    echo "Choose an option:"
    echo "1. Query all proposal list"
    echo "2. Query specific proposal"
    echo "3. Vote on a proposal"
    echo "4. Back"
    read -p "Enter your choice (1, 2, 3 or 4): " CHOICE

    case $CHOICE in
        1)
            read -p "Do you want to use your own RPC or Grand Valley's RPC? (1 for own, 2 for Grand Valley): " RPC_CHOICE
            if [ "$RPC_CHOICE" == "2" ]; then
                namadac query-proposal --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
            else
                namadac query-proposal
            fi
            ;;
        2)
            read -p "Do you want to use your own RPC or Grand Valley's RPC? (1 for own, 2 for Grand Valley): " RPC_CHOICE
            read -p "Enter proposal ID: " PROPOSAL_ID
            if [ "$RPC_CHOICE" == "2" ]; then
                namadac query-proposal --proposal-id $PROPOSAL_ID --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
            else
                namadac query-proposal --proposal-id $PROPOSAL_ID
            fi
            ;;
        3)
            read -p "Do you want to use your own RPC or Grand Valley's RPC? (1 for own, 2 for Grand Valley): " RPC_CHOICE
            read -p "Enter proposal ID: " PROPOSAL_ID
            read -p "Enter your vote (yay/nay): " VOTE

            read -p "Do you want to vote through your implicit address or your validator address? (1 for implicit, 2 for validator): " ADDRESS_TYPE

            if [ "$ADDRESS_TYPE" == "2" ]; then
                # Query validator address
                port=$(grep -oP 'laddr = "tcp://(0.0.0.0|127.0.0.1):\K[0-9]+57' "$HOME/.local/share/namada/namada.5f5de2dd1b88cba30586420/config.toml")
                VALIDATOR_ADDRESS=$(namadac find-validator --tm-address=$(curl -s 127.0.0.1:$port/status | jq -r .result.validator_info.address) | grep 'Found validator address' | awk -F'"' '{print $2}')
                ADDRESS=$VALIDATOR_ADDRESS
            else
                ADDRESS=$WALLET_ADDRESS
            fi

            if [ "$RPC_CHOICE" == "2" ]; then
                namadac vote-proposal --proposal-id $PROPOSAL_ID --vote $VOTE --address $ADDRESS --signing-keys $WALLET_NAME --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
            else
                namadac vote-proposal --proposal-id $PROPOSAL_ID --vote $VOTE --address $ADDRESS --signing-keys $WALLET_NAME
            fi
            ;;
        4)
            echo "Returning to the Valley of Namada main menu."
            menu
            ;;
        *)
            echo "Invalid choice. Please enter 1, 2, 3 or 4."
            ;;
    esac
    echo -e "${YELLOW}Press Enter to go back to Valley of Namada main menu${RESET}"
    read -r
    menu
}

function apply_snapshot() {
    echo -e "${CYAN}Applying snapshot...${RESET}"
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Mainnet-Guides/main/Namada/resources/apply_snapshot.sh)
    menu
}

# Function to show endpoints
function show_endpoints() {
    echo -e "$ENDPOINTS"
    echo -e "${YELLOW}Press Enter to go back to Valley of Namada main menu${RESET}"
    read -r
    menu
}

function show_guidelines() {
    echo -e "${CYAN}Guidelines on How to Use the Valley of Namada${RESET}"
    echo -e "${YELLOW}This tool is designed to help you manage your Namada Validator Node. Below are the guidelines on how to use it effectively:${RESET}"

    echo -e "${GREEN}1. Navigating the Menu${RESET}"
    echo "   - The menu is divided into several sections: Node Interactions, Validator/Key Interactions, Node Management, Install Namada App, Show Grand Valley's Endpoints, and Guidelines."
    echo "   - To select an option, you can either:"
    echo "     a. Enter the corresponding number followed by the letter (e.g., 1a for Deploy/re-Deploy Validator Node)."
    echo "     b. Enter the number, press Enter, and then enter the letter (e.g., 1 then a)."
    echo "   - For sub-options, you will be prompted to enter the letter corresponding to your choice."

    echo -e "${GREEN}2. Entering Choices${RESET}"
    echo "   - For any prompt that has choices, you only need to enter the numbering (1, 2, 3, etc.) or the letter (a, b, c, etc.)."
    echo "   - For yes/no prompts, enter 'yes' for yes and 'no' for no."
    echo "   - For y/n prompts, enter 'y' for yes and 'n' for no."

    echo -e "${GREEN}3. Running Commands${RESET}"
    echo "   - After selecting an option, the script will execute the corresponding commands."
    echo "   - Ensure you have the necessary permissions and dependencies installed for the commands to run successfully."

    echo -e "${GREEN}4. Exiting the Script${RESET}"
    echo "   - To exit the script, select option 7 from the main menu."
    echo "   - Remember to run 'source ~/.bash_profile' after exiting to apply any changes made to environment variables."

    echo -e "${GREEN}5. Additional Tips${RESET}"
    echo "   - Always backup your keys and important data before performing operations like deleting the node."
    echo "   - Regularly update your node to the latest version to ensure compatibility and security."

    echo -e "${GREEN}6. Option Descriptions and Guides${RESET}"
    echo -e "${GREEN}Node Interactions:${RESET}"
    echo "   a. Deploy/re-Deploy Validator Node: Deploys and re-deploys the validator node."
    echo "   b. Show Validator Node Status: Displays the status of the validator node."
    echo "   c. Show Validator Node Logs: Displays the logs for the validator node."
    echo "   d. Apply Snapshot: Applies a snapshot to the node."
    echo "   e. Add Peers: Adds peers to the node."

    echo -e "${GREEN}Validator/Key Interactions:${RESET}"
    echo "   a. Create Wallet: Creates a new wallet."
    echo "   b. Restore Wallet: Restores a wallet from its seed phrase."
    echo "   c. Query Balance: Queries the balance of a wallet."
    echo "   d. Create Validator: Creates a new validator."
    echo "   e. Transfer (Transparent): Transfers tokens transparently."
    echo "   f. Delegate NAM: Delegates NAM tokens to a validator."
    echo "   g. Undelegate NAM: Undelegates NAM tokens from a validator."
    echo "   h. Redelegate NAM: Redelegates NAM tokens to another validator."
    echo "   i. Withdraw Unbonded NAM: Withdraws unbonded NAM tokens."
    echo "   j. Claim Rewards: Claims rewards for staking."
    echo "   k. Vote Proposal: Votes on a proposal."

    echo -e "${GREEN}Node Management:${RESET}"
    echo "   a. Restart Validator Node: Restarts the validator node."
    echo "   b. Stop Validator Node: Stops the validator node."
    echo "   c. Backup Validator Key (store it to $HOME directory)"
    echo "   d. Delete Validator Node: Deletes the validator node. Ensure you backup your seeds phrase and priv_validator_key.json before doing this."
    echo "      - Guide: Use this option to delete your validator node. Make sure to backup all important data before proceeding."

    echo -e "${GREEN}Install Namada App:${RESET}"
    echo "   - Just for those who want to interact with the namada chain without running a node."
    echo "   - Use this option to install the Namada App, which allows you to make transactions, view balances, and interact with the chain without the need for a validator or full node."
    echo "   - This is a lightweight option for users who prefer not to run a node but still want to participate in the network's ecosystem."

    echo -e "${GREEN}Show Grand Valley's Endpoints:${RESET}"
    echo "   - Displays Grand Valley's public endpoints."
    echo "   - Guide: This option will show you the public endpoints provided by Grand Valley. These endpoints can be used for various operations."

    echo -e "${GREEN}Show Guidelines:${RESET}"
    echo "   - Displays these guidelines."
    echo "   - Guide: Use this option to view the guidelines on how to use the tool effectively."

    echo -e "\n${YELLOW}Press Enter to go back to Valley of Namada main menu${RESET}"
    read -r
    menu
}

# Menu function
function menu() {
    echo -e "Show your support for Grand Valley by staking with us!: ${CYAN}tnam1qyplu8gruqmmvwp7x7kd92m6x4xpyce265fa05r6${RESET}"
    echo -e "${CYAN}Valley of Namada${RESET}"
    echo "Main Menu:"
    echo -e "${GREEN}1. Node Interactions:${RESET}"
    echo "   a. Deploy/re-Deploy Validator Node"
    echo "   b. Show Validator Node Status"
    echo "   c. Show Validator Node Logs"
    echo "   d. Apply Snapshot"
    echo "   e. Add Seeds"
    echo "   f. Add Peers"
    echo -e "${GREEN}2. Validator/Key Interactions:${RESET}"
    echo "   a. Create Wallet (Transparent Key, Shielded Key, Shielded Payment Address)"
    echo "   b. Restore Wallet (Transparent Key, Shielded Key, Shielded Payment Address)"
    echo "   c. Show Wallet (Transparent Key, Shielded Key, Shielded Payment Address)"
    echo "   d. Query Balance"
    echo "   e. Create Validator"
    echo "   f. Transfer (Transparent)"
    echo "   g. Delegate NAM"
    echo "   h. Undelegate NAM"
    echo "   i. Redelegate NAM"
    echo "   j. Withdraw Unbonded NAM"
    echo "   k. Claim Rewards"
    echo "   l. Vote Proposal"
    echo "   m. Create Another Shielded Payment Address"
    echo "   n. Transfer (Shielding)"
    echo "   o. Transfer (Shielded to Shielded)"
    echo "   p. Transfer (Unshielding)"
    echo -e "${GREEN}3. Node Management:${RESET}"
    echo "   a. Restart Validator Node"
    echo "   b. Stop Validator Node"
    echo "   c. Backup Validator Key (store it to $HOME directory)"
    echo "   d. Delete Validator Node (BACKUP YOUR SEEDS PHRASE AND priv_validator_key.json BEFORE YOU DO THIS)"
    echo -e "${GREEN}4. Install the Namada App (v1.0.0) only to execute transactions without running a node${RESET}"
    echo -e "${GREEN}5. Show Grand Valley's Endpoints${RESET}"
    echo -e "${YELLOW}6. Show Guidelines${RESET}"
    echo -e "${RED}7. Exit${RESET}"

    echo -e "\n${YELLOW}Please run the following command to apply the changes after exiting the script:${RESET}"
    echo -e "${GREEN}source ~/.bash_profile${RESET}"
    echo -e "${YELLOW}This ensures the environment variables are set in your current bash session.${RESET}"
    echo -e "${GREEN}Let's Buidl Namada Together, Let's Shiedl Together. - Grand Valley${RESET}"
    read -p "Choose an option (e.g., 1a or 1 then a): " OPTION

    if [[ $OPTION =~ ^[1-7][a-z]$ ]]; then
        MAIN_OPTION=${OPTION:0:1}
        SUB_OPTION=${OPTION:1:1}
    else
        MAIN_OPTION=$OPTION
        if [[ $MAIN_OPTION =~ ^[1-3]$ ]]; then
            read -p "Choose a sub-option: " SUB_OPTION
        fi
    fi

    case $MAIN_OPTION in
        1)
            case $SUB_OPTION in
                a) deploy_validator_node ;;
                b) show_validator_node_status ;;
                c) show_validator_node_logs ;;
                d) apply_snapshot ;;
                e) add_seeds ;;
                f) add_peers ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        2)
            case $SUB_OPTION in
                a) create_wallet ;;
                b) restore_wallet ;;
                c) show_wallet ;;
                d) query_balance ;;
                e) create_validator ;;
                f) transfer_transparent ;;
                g) stake_tokens ;;
                h) unstake_tokens ;;
                i) redelegate_tokens ;;
                j) withdraw_unbonded_tokens ;;
                k) claim_rewards ;;
                l) vote_proposal ;;
                m) create_shielded_payment_address ;;
                n) transfer_shielding ;;
                o) transfer_shielded_to_shielded ;;
                p) transfer_unshielding ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        3)
            case $SUB_OPTION in
                a) restart_validator_node ;;
                b) stop_validator_node ;;
                c) backup_validator_key ;;
                d) delete_validator_node ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        4) install_namada_app ;;
        5) show_endpoints ;;
        6) show_guidelines ;;
        7) exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
}

# Start menu
menu
