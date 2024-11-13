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

    read -p "Enter the commision rate: " COMMISION_RATE

    read -p "Enter the max commision rate change: " MAX_COMMISION_RATE_CHANGE

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
                sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/config.toml
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
                sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/config.toml
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

function validator_node_logs() {
    echo "Displaying Namada Validator Node Logs:"
    sudo journalctl -u namadad -fn 100
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

# Menu function
function menu() {
    echo -e "${CYAN}Namada Validator Node${RESET}"
    echo "Menu:"
    echo -e "${GREEN}1. Node Interactions:${RESET}"
    echo "   a. Deploy/re-Deploy Validator Node (includes Cosmovisor deployment)"
    echo -e "${GREEN}2. Validator/Key Interactions:${RESET}"
    echo "   a. Create Validator"
    echo -e "${GREEN}3. Show Grand Valley's Endpoints${RESET}"
    echo -e "${RED}4. Exit${RESET}"

    echo -e "${GREEN}Let's Buidl Namada Together - Grand Valley${RESET}"
    read -p "Choose an option (e.g., 1a or 1 then a): " OPTION

    if [[ $OPTION =~ ^[1-2][a]$ ]]; then
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
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        2)
            case $SUB_OPTION in
                a) create_validator ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        3) show_endpoints ;;
        4) exit 0 ;;
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
