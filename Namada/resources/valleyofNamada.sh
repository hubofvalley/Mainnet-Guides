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
Valley Of Namada by Grand Valley

${GREEN}Namada Validator Node System Requirements${RESET}
${YELLOW}| Category  | Requirements     |
| --------- | ---------------- |
| CPU       | 8+ cores         |
| RAM       | 32+ GB           |
| Storage   | 500+ GB NVMe SSD |
| Bandwidth | 100+ MBit/s      |${RESET}

- validator node service file name: ${CYAN}namadad.service${RESET}
- current chain: ${CYAN}namada-dryrun.abaaeaf7b78cb3ac${RESET}
- current namada node version: ${CYAN}v0.45.1${RESET}
"

ENDPOINTS="${GREEN}
Grand Valley Namada mainnet public endpoints:${RESET}
- cosmos-rpc: ${BLUE}https://lightnode-rpc-mainnet-namada.grandvalleys.com${RESET}
- evm-rpc: ${BLUE}https://lightnode-json-rpc-mainnet-namada.grandvalleys.com${RESET}
- cosmos ws: ${BLUE}wss://lightnode-rpc-mainnet-namada.grandvalleys.com/websocket${RESET}

Grand Valley validator address: tnam1qyplu8gruqmmvwp7x7kd92m6x4xpyce265fa05r6

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
echo -e "\n${YELLOW}Press Enter to continue...${RESET}"
read -r

# Display INTRO section and wait for user input to continue
echo -e "$INTRO"
echo -e "$ENDPOINTS"
echo -e "\n${YELLOW}Press Enter to continue${RESET}"
read -r
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bash_profile
echo "export NAMADA_CHAIN_ID="namada-dryrun.abaaeaf7b78cb3ac"" >> $HOME/.bash_profile
source $HOME/.bash_profile

# Validator Node Functions
function deploy_validator_node() {
    echo -e "${CYAN}Deploying Validator Node...${RESET}"
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Mainnet-Guides/main/Namada/resources/namada_validator_node_install_dryrun.sh)
    menu
}

function create_validator() {
    read -p "Enter the name for your validator: " NAME

    read -p "Enter the commission rate: " COMMISION_RATE

    read -p "Enter the max commission rate change: " MAX_COMMISION_RATE_CHANGE

    read -p "Enter the email for your validator security contact: " EMAIL

    namadac init-validator --commission-rate "$COMMISION_RATE" --name "$NAME" --max-commission-rate-change "$MAX_COMMISION_RATE_CHANGE" --chain-id $NAMADA_CHAIN_ID
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
                sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/config.toml
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
                sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/config.toml
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
    echo "Now you can restart your consensus client"
    menu
}

function delete_validator_node() {
    sudo systemctl stop namadad
    sudo systemctl disable namadad
    sudo rm -rf /etc/systemd/system/namadad.service
    sudo rm -rf $HOME/namada
    sudo rm -rf $HOME/.local/share/namada
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
    sudo rm -f $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/data/upgrade-info.json
    sudo systemctl restart namadad
    echo "Namada validator node service restarted."
    menu
}

function show_validator_node_logs() {
    echo "Displaying Namada Validator Node Logs:"
    sudo journalctl -u namadad -fn 100
    menu
}

function show_validator_node_status() {
    port=$(grep -oP 'laddr = "tcp://(0.0.0.0|127.0.0.1):\K[0-9]+57' "$HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/config.toml")
    curl -s 127.0.0.1:$port/status | jq
    menu
}

function install_namada_app() {
    echo -e "${YELLOW}This option is only for those who want to execute the transactions without running the node.${RESET}"
    wget https://github.com/anoma/namada/releases/download/v0.45.1/namada-v0.45.1-Linux-x86_64.tar.gz
    tar -xvf namada-v0.45.1-Linux-x86_64.tar.gz
    cd namada-v0.45.1-Linux-x86_64
    mv namad* /usr/local/bin/
    menu
}

function create_wallet() {
    read -p "Enter wallet name/alias: " WALLET_NAME
    namadaw gen --alias $WALLET_NAME
    menu
}

function restore_wallet() {
    read -p "Enter wallet name/alias: " WALLET_NAME
    namada wallet derive --alias $WALLET_NAME --hd-path default
    namadaw derive --alias $WALLET_NAME --hd-path default
    namadaw derive --shielded --alias ${WALLET_NAME}-shielded
    echo -e "${GREEN}Wallet restoration completed successfully, including shielded wallet restoration.${RESET}"
    menu
}

function create_payment_address() {
    read -p "Enter wallet name/alias: " WALLET_NAME
    namadaw gen-payment-addr --key ${WALLET_NAME}-shielded --alias ${WALLET_NAME}-shielded-addr
    echo -e "${GREEN}Payment address created successfully.${RESET}"
    menu
}

function query_balance() {
    DEFAULT_WALLET=$WALLET  # Assuming $WALLET is set elsewhere in your script
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
    echo "1. Query balance from transparent address"
    echo "2. Query balance from shielded address"
    read -p "Enter your choice (1 or 2): " CHOICE

    read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE

    case $CHOICE in
        1)
            if [ "$RPC_CHOICE" == "grandvalley" ]; then
                namadac balance --owner $WALLET_NAME --token nam --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
            else
                namadac balance --owner $WALLET_NAME --token nam
            fi
            ;;
        2)
            if [ "$RPC_CHOICE" == "grandvalley" ]; then
                namadac balance --owner ${WALLET_NAME}-shielded --token nam --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
            else
                namadac balance --owner ${WALLET_NAME}-shielded --token nam
            fi
            ;;
        *)
            echo "Invalid choice. Please enter 1 or 2."
            ;;
    esac

    menu
}

function stake_tokens() {
    DEFAULT_WALLET=$WALLET  # Assuming $WALLET is set elsewhere in your script
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
    read -p "Enter your choice (1, 2, or 3): " CHOICE

    read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE

    case $CHOICE in
        1)
            read -p "Enter amount to stake: " AMOUNT
            VALIDATOR_ADDRESS="tnam1qyplu8gruqmmvwp7x7kd92m6x4xpyce265fa05r6"
            if [ "$RPC_CHOICE" == "grandvalley" ]; then
                namadac bond --source $WALLET_NAME --validator $VALIDATOR_ADDRESS --amount $AMOUNT --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
            else
                namadac bond --source $WALLET_NAME --validator $VALIDATOR_ADDRESS --amount $AMOUNT
            fi
            ;;
        2)
            read -p "Enter amount to stake: " AMOUNT
            port=$(grep -oP 'laddr = "tcp://(0.0.0.0|127.0.0.1):\K[0-9]+57' "$HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/config.toml")
            VALIDATOR_ADDRESS=$(namadac find-validator --tm-address=$(curl -s 127.0.0.1:$port/status | jq -r .result.validator_info.address) | grep 'Found validator address' | awk -F'"' '{print $2}')
            if [ "$RPC_CHOICE" == "grandvalley" ]; then
                namadac bond --source $WALLET_NAME --validator $VALIDATOR_ADDRESS --amount $AMOUNT --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
            else
                namadac bond --source $WALLET_NAME --validator $VALIDATOR_ADDRESS --amount $AMOUNT
            fi
            ;;
        3)
            read -p "Enter validator address: " VALIDATOR_ADDRESS
            read -p "Enter amount to stake: " AMOUNT
            if [ "$RPC_CHOICE" == "grandvalley" ]; then
                namadac bond --source $WALLET_NAME --validator $VALIDATOR_ADDRESS --amount $AMOUNT --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
            else
                namadac bond --source $WALLET_NAME --validator $VALIDATOR_ADDRESS --amount $AMOUNT
            fi
            ;;
        *)
            echo "Invalid choice. Please enter 1, 2, or 3."
            ;;
    esac

    menu
}

function unstake_tokens() {
    DEFAULT_WALLET=$WALLET  # Assuming $WALLET is set elsewhere in your script
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
    echo "1. Self-delegate"
    echo "2. Delegate to another validator"
    read -p "Enter your choice (1 or 2): " CHOICE

    read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE

    case $CHOICE in
        1)
            read -p "Enter amount to unstake: " AMOUNT
            port=$(grep -oP 'laddr = "tcp://(0.0.0.0|127.0.0.1):\K[0-9]+57' "$HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/config.toml")
            VALIDATOR_ADDRESS=$(namadac find-validator --tm-address=$(curl -s 127.0.0.1:$port/status | jq -r .result.validator_info.address) --node https://lightnode-rpc-mainnet-namada.grandvalleys.com | grep 'Found validator address' | awk -F'"' '{print $2}')
            if [ "$RPC_CHOICE" == "grandvalley" ]; then
                namadac unbond --source $WALLET_NAME --validator $VALIDATOR_ADDRESS --amount $AMOUNT --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
            else
                namadac unbond --source $WALLET_NAME --validator $VALIDATOR_ADDRESS --amount $AMOUNT
            fi
            ;;
        2)
            read -p "Enter validator address: " VALIDATOR_ADDRESS
            read -p "Enter amount to unstake: " AMOUNT
            if [ "$RPC_CHOICE" == "grandvalley" ]; then
                namadac unbond --source $WALLET_NAME --validator $VALIDATOR_ADDRESS --amount $AMOUNT --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
            else
                namadac unbond --source $WALLET_NAME --validator $VALIDATOR_ADDRESS --amount $AMOUNT
            fi
            ;;
        *)
            echo "Invalid choice. Please enter 1 or 2."
            ;;
    esac

    menu
}

function redelegate_tokens() {
    DEFAULT_WALLET=$WALLET  # Assuming $WALLET is set elsewhere in your script
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
    read -p "Enter your choice (1, 2, or 3): " CHOICE

    read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE

    case $CHOICE in
        1)
            read -p "Enter amount to redelegate: " AMOUNT
            SOURCE_VALIDATOR_ADDRESS=$(namadac find-validator --tm-address=$(curl -s 127.0.0.1:$port/status | jq -r .result.validator_info.address) --node https://lightnode-rpc-mainnet-namada.grandvalleys.com | grep 'Found validator address' | awk -F'"' '{print $2}')
            TARGET_VALIDATOR_ADDRESS="tnam1qyplu8gruqmmvwp7x7kd92m6x4xpyce265fa05r6"

            if [ "$RPC_CHOICE" == "grandvalley" ]; then
                namadac redelegate --source-validator $SOURCE_VALIDATOR_ADDRESS --destination-validator $TARGET_VALIDATOR_ADDRESS --owner $WALLET_NAME --amount $AMOUNT --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
            else
                namadac redelegate --source-validator $SOURCE_VALIDATOR_ADDRESS --destination-validator $TARGET_VALIDATOR_ADDRESS --owner $WALLET_NAME --amount $AMOUNT
            fi
            ;;
        2)
            read -p "Enter amount to redelegate: " AMOUNT
            port=$(grep -oP 'laddr = "tcp://(0.0.0.0|127.0.0.1):\K[0-9]+57' "$HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/config.toml")
            SOURCE_VALIDATOR_ADDRESS=$(namadac find-validator --tm-address=$(curl -s 127.0.0.1:$port/status | jq -r .result.validator_info.address) --node https://lightnode-rpc-mainnet-namada.grandvalleys.com | grep 'Found validator address' | awk -F'"' '{print $2}')

            echo "Choose a destination validator:"
            echo "2. Another validator"
            read -p "Enter your choice (2): " DEST_CHOICE

            case $DEST_CHOICE in
                2)
                    read -p "Enter destination validator address: " TARGET_VALIDATOR_ADDRESS
                    ;;
                *)
                    echo "Invalid choice. Please enter 2."
                    menu
                    ;;
            esac

            if [ "$RPC_CHOICE" == "grandvalley" ]; then
                namadac redelegate --source-validator $SOURCE_VALIDATOR_ADDRESS --destination-validator $TARGET_VALIDATOR_ADDRESS --owner $WALLET_NAME --amount $AMOUNT --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
            else
                namadac redelegate --source-validator $SOURCE_VALIDATOR_ADDRESS --destination-validator $TARGET_VALIDATOR_ADDRESS --owner $WALLET_NAME --amount $AMOUNT
            fi
            ;;
        3)
            read -p "Enter source validator address: " SOURCE_VALIDATOR_ADDRESS
            read -p "Enter amount to redelegate: " AMOUNT

            echo "Choose a destination validator:"
            echo "2. Another validator"
            read -p "Enter your choice (2): " DEST_CHOICE

            case $DEST_CHOICE in
                2)
                    read -p "Enter destination validator address: " TARGET_VALIDATOR_ADDRESS
                    ;;
                *)
                    echo "Invalid choice. Please enter 2."
                    menu
                    ;;
            esac

            if [ "$RPC_CHOICE" == "grandvalley" ]; then
                namadac redelegate --source-validator $SOURCE_VALIDATOR_ADDRESS --destination-validator $TARGET_VALIDATOR_ADDRESS --owner $WALLET_NAME --amount $AMOUNT --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
            else
                namadac redelegate --source-validator $SOURCE_VALIDATOR_ADDRESS --destination-validator $TARGET_VALIDATOR_ADDRESS --owner $WALLET_NAME --amount $AMOUNT
            fi
            ;;
        *)
            echo "Invalid choice. Please enter 1, 2, or 3."
            ;;
    esac

    menu
}

function withdraw_unbonded_tokens() {
    DEFAULT_WALLET=$WALLET  # Assuming $WALLET is set elsewhere in your script
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

    menu
}

function claim_rewards() {
    DEFAULT_WALLET=$WALLET  # Assuming $WALLET is set elsewhere in your script
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

    menu
}

function transfer_shielding() {
    DEFAULT_WALLET=$WALLET  # Assuming $WALLET is set elsewhere in your script
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

    read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE

    if [ "$RPC_CHOICE" == "grandvalley" ]; then
        namadac transfer --source $WALLET_NAME --target ${WALLET_NAME}-shielded-addr --token nam --amount 1 --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
    else
        namadac transfer --source $WALLET_NAME --target ${WALLET_NAME}-shielded-addr --token nam --amount 1
    fi

    echo -e "${GREEN}Transfer from transparent account to shielded account (shielding) completed successfully.${RESET}"
    menu
}

function transfer_shielded_to_shielded() {
    DEFAULT_WALLET=$WALLET  # Assuming $WALLET is set elsewhere in your script
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

    read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE

    if [ "$RPC_CHOICE" == "grandvalley" ]; then
        namadac transfer --source ${WALLET_NAME}-shielded --target $TARGET_SHIELDED_WALLET_ADDRESS --token nam --amount 1 --signing-keys $WALLET_NAME --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
    else
        namadac transfer --source ${WALLET_NAME}-shielded --target $TARGET_SHIELDED_WALLET_ADDRESS --token nam --amount 1 --signing-keys $WALLET_NAME
    fi

    echo -e "${GREEN}Transfer from shielded address to another shielded address completed successfully.${RESET}"
    menu
}

function transfer_unshielding() {
    DEFAULT_WALLET=$WALLET  # Assuming $WALLET is set elsewhere in your script
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

    read -p "Do you want to use your own RPC or Grand Valley's RPC? (own/grandvalley): " RPC_CHOICE

    if [ "$RPC_CHOICE" == "grandvalley" ]; then
        namadac transfer --source ${WALLET_NAME}-shielded --target $WALLET_NAME --token nam --amount 1 --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
    else
        namadac transfer --source ${WALLET_NAME}-shielded --target $WALLET_NAME --token nam --amount 1
    fi

    echo -e "${GREEN}Transfer from shielded account to transparent account (unshielding) completed successfully.${RESET}"
    menu
}

function vote_proposal() {
    DEFAULT_WALLET=$WALLET  # Assuming $WALLET is set elsewhere in your script
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
    read -p "Enter your choice (1, 2, or 3): " CHOICE

    read -p "Do you want to use your own RPC or Grand Valley's RPC? (1 for own, 2 for Grand Valley): " RPC_CHOICE

    case $CHOICE in
        1)
            if [ "$RPC_CHOICE" == "2" ]; then
                namadac query-proposal --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
            else
                namadac query-proposal
            fi
            ;;
        2)
            read -p "Enter proposal ID: " PROPOSAL_ID
            if [ "$RPC_CHOICE" == "2" ]; then
                namadac query-proposal --proposal-id $PROPOSAL_ID --node https://lightnode-rpc-mainnet-namada.grandvalleys.com
            else
                namadac query-proposal --proposal-id $PROPOSAL_ID
            fi
            ;;
        3)
            read -p "Enter proposal ID: " PROPOSAL_ID
            read -p "Enter your vote (yay/nay): " VOTE

            read -p "Do you want to vote through your implicit address or your validator address? (1 for implicit, 2 for validator): " ADDRESS_TYPE

            if [ "$ADDRESS_TYPE" == "2" ]; then
                # Query validator address
                port=$(grep -oP 'laddr = "tcp://(0.0.0.0|127.0.0.1):\K[0-9]+57' "$HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/config.toml")
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
        *)
            echo "Invalid choice. Please enter 1, 2, or 3."
            ;;
    esac

    menu
}

function apply_snapshot() {
    echo -e "${CYAN}Applying snapshot...${RESET}"
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Mainnet-Guides/main/Namada/resources/apply_snapshot.sh)
    menu
}

# Menu function
function menu() {
    echo -e "${CYAN}Namada Validator Node${RESET}"
    echo "Menu:"
    echo -e "${GREEN}1. Node Interactions:${RESET}"
    echo "   a. Deploy/re-Deploy Validator Node (includes Cosmovisor deployment)"
    echo "   b. Show Validator Node Status"
    echo "   c. Show Validator Node Logs"
    echo "   d. Apply Snapshot"
    echo "   e. Add Peers"
    echo "   f. Restart Validator Node"
    echo "   g. Stop Validator Node"
    echo "   h. Delete Validator Node"
    echo -e "${GREEN}2. Validator/Key Interactions:${RESET}"
    echo "   a. Create Validator"
    echo "   b. Create Wallet"
    echo "   c. Restore Wallet"
    echo "   d. Create Payment Address"
    echo "   e. Query Balance"
    echo "   f. Stake NAM"
    echo "   g. Unstake NAM"
    echo "   h. Redelegate NAM"
    echo "   i. Withdraw Unbonded Tokens"
    echo "   j. Claim Rewards"
    echo "   k. Transfer (Shielding)"
    echo "   l. Transfer (Shielded to Shielded)"
    echo "   m. Transfer (Unshielding)"
    echo "   n. Vote Proposal"
    echo -e "${GREEN}3. Install Namada App${RESET}"
    echo -e "${GREEN}4. Show Grand Valley's Endpoints${RESET}"
    echo -e "${RED}5. Exit${RESET}"

    echo -e "${GREEN}Let's Buidl Namada Together - Grand Valley${RESET}"
    read -p "Choose an option (e.g., 1a or 1 then a): " OPTION

    if [[ $OPTION =~ ^[1-2][a-n]$ ]]; then
        MAIN_OPTION=${OPTION:0:1}
        SUB_OPTION=${OPTION:1:1}
    else
        MAIN_OPTION=$OPTION
        if [[ $MAIN_OPTION =~ ^[1-2]$ ]]; then
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
                e) add_peers ;;
                f) restart_validator_node ;;
                g) stop_validator_node ;;
                h) delete_validator_node ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        2)
            case $SUB_OPTION in
                a) create_validator ;;
                b) create_wallet ;;
                c) restore_wallet ;;
                d) create_payment_address ;;
                e) query_balance ;;
                f) stake_tokens ;;
                g) unstake_tokens ;;
                h) redelegate_tokens ;;
                i) withdraw_unbonded_tokens ;;
                j) claim_rewards ;;
                k) transfer_shielding ;;
                l) transfer_shielded_to_shielded ;;
                m) transfer_unshielding ;;
                n) vote_proposal ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        3) install_namada_app ;;
        4) show_endpoints ;;
        5) exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
}


# Function to show endpoints
function show_endpoints() {
    echo -e "$ENDPOINTS"
    menu
}

# Start menu
menu
