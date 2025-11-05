#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
ORANGE='\033[38;5;214m'
RESET='\033[0m'

# Service file variables
OG_CONSENSUS_CLIENT_SERVICE="0gchaind.service"

LOGO="
 __      __     _  _                        __    ___    _____ 
 \ \    / /    | || |                      / _|  / _ \  / ____|
  \ \  / /__ _ | || |  ___  _   _    ___  | |_  | | | || |  __ 
  _\ \/ // __ || || | / _ \| | | |  / _ \ |  _| | | | || | |_ |
 | |\  /| (_| || || ||  __/| |_| | | (_) || |   | |_| || |__| |
 | |_\/  \__,_||_||_| \___| \__, |  \___/ |_|    \___/  \_____|
 | '_ \ | | | |              __/ |                             
 | |_) || |_| |             |___/                              
 |____/  \__, |                                                
          __/ |                                                
         |___/                                                 
 __                                   
/__ __ __ __   _|   \  / __ | |  _    
\_| | (_| | | (_|    \/ (_| | | (/_ \/
                                    /
"

INTRO="
Valley of 0G Mainnet by ${ORANGE}Grand Valley${RESET}

${GREEN}0G Validator Node System Requirements${RESET}
${YELLOW}| Category  | Requirements                   |
| --------- | ------------------------------ |
| CPU       | 8 cores                        |
| RAM       | 64+ GB                         |
| Storage   | 1+ TB NVMe SSD                 |
| Bandwidth | 100 MBps for Download / Upload |${RESET}

validator node current binaries version: ${CYAN}v1.0.2${RESET}
consensus client service file name: ${CYAN}0gchaind.service${RESET}
0g-geth service file name: ${CYAN}0g-geth.service${RESET}
current chain : ${CYAN}0gchain-16661 (Aristotle)${RESET}

------------------------------------------------------------------

${GREEN}Storage Node System Requirements${RESET}
${YELLOW}| Category  | Requirements                   |
| --------- | ------------------------------ |
| CPU       | 8+ cores                       |
| RAM       | 32+ GB                         |
| Storage   | 500GB / 1TB NVMe SSD           |
| Bandwidth | 100 MBps for Download / Upload |${RESET}

storage node current binary version: ${CYAN}v1.1.0${RESET}

------------------------------------------------------------------

${GREEN}Storage KV System Requirements${RESET}
${YELLOW}| Category | Requirements                                |
| -------- | ------------------------------------------- |
| CPU      | 8+ cores                                    |
| RAM      | 32+ GB                                      |
| Storage  | Matches the size of kv streams it maintains |${RESET}

storage kvs current binary version: ${CYAN}v1.4.0${RESET}

------------------------------------------------------------------
"

PRIVACY_SAFETY_STATEMENT="
${YELLOW}Privacy and Safety Statement${RESET}

${GREEN}No User Data Stored Externally${RESET}
- This script does not store any user data externally. All operations are performed locally on your machine.

${GREEN}No Phishing Links${RESET}
- This script does not contain any phishing links. All URLs and commands are provided for legitimate purposes related to 0G validator node operations.

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
Grand Valley 0G public endpoints:${RESET}
- cosmos-rpc: ${BLUE}https://lightnode-rpc-mainnet-0g.grandvalleys.com${RESET}
- evm-rpc: ${BLUE}https://lightnode-json-rpc-mainnet-0g.grandvalleys.com${RESET}
- cosmos rest-api: ${BLUE}https://lightnode-api-mainnet-0g.grandvalleys.com${RESET}
- peer: ${BLUE}813aeda202eae52b0d3e389a0e6e3a0354ad547a@peer-mainnet-0g.grandvalleys.com:28656${RESET}
- validator-profile: ${BLUE}https://explorer.0g.ai/mainnet/validators/0x108e619da0cdba8a301a53948a4acc23a3d79377/delegators ${RESET}

${GREEN}Connect with Zero Gravity (0G):${RESET}
- Official Website: ${BLUE}https://0g.ai/${RESET}
- X: ${BLUE}https://x.com/0G_labs${RESET}
- Official Docs: ${BLUE}https://docs.0g.ai/${RESET}
- Official Discord: ${BLUE}https://discord.gg/0glabs${RESET}
- Official GitHub: ${BLUE}https://github.com/0gfoundation${RESET}
- Official Telegram: ${BLUE}https://t.me/web3_0glabs${RESET}
- Official Explorer: ${BLUE}https://explorer.0g.ai/${RESET}

${GREEN}Connect with Grand Valley:${RESET}
- X: ${BLUE}https://x.com/bacvalley${RESET}
- GitHub: ${BLUE}https://github.com/hubofvalley${RESET}
- 0G Mainnet Guide on GitHub by Grand Valley: ${BLUE}https://github.com/hubofvalley/Mainnet-Guides/tree/main/0g%20(zero-gravity)${RESET}
- Email: ${BLUE}letsbuidltogether@grandvalleys.com${RESET}
"

# Function to detect the service file name
function detect_geth_service_file() {
  if [[ -f "/etc/systemd/system/0g-geth.service" ]]; then
    OG_GETH_SERVICE="0g-geth.service"
  elif [[ -f "/etc/systemd/system/0ggeth.service" ]]; then
    OG_GETH_SERVICE="0ggeth.service"
  else
    OG_GETH_SERVICE="Not found"
    echo -e "${RED}No execution client service file found (0g-geth.service or 0ggeth.service). Continuing without setting service file name.${RESET}"
  fi
}

# Display LOGO and wait for user input to continue
echo -e "$LOGO"
echo -e "$PRIVACY_SAFETY_STATEMENT"
echo -e "\n${YELLOW}Press Enter to continue...${RESET}"
read -r

# Display INTRO section and wait for user input to continue
echo -e "$INTRO"
echo -e "$ENDPOINTS"
echo -e "${YELLOW}\nPress Enter to continue${RESET}"
read -r
detect_geth_service_file #(enabled as requested)
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bash_profile
# echo "export OG_CHAIN_ID="0gchain-16661"" >> $HOME/.bash_profile
# echo "export SERVICE_FILE_NAME=\"$SERVICE_FILE_NAME\"" >> ~/.bash_profile
# echo "export DAEMON_NAME=0gchaind" >> ~/.bash_profile
# echo "export DAEMON_HOME=$(find $HOME -type d -name ".0gchain" -print -quit)" >> ~/.bash_profile
# echo "export DAEMON_DATA_BACKUP_DIR=$(find "$HOME/.0gchain/cosmovisor" -type d -name "backup" -print -quit)" >> ~/.bash_profile
source $HOME/.bash_profile

# Validator Node Functions
function deploy_validator_node() {
    clear
    echo -e "${RED}▓▒░ IMPORTANT DISCLAIMER AND TERMS ░▒▓${RESET}"
    echo -e "${YELLOW}1. SECURITY:${RESET}"
    echo -e "- This script ${GREEN}DOES NOT${RESET} send any data outside your server"
    echo "- All operations are performed locally"
    echo "- You are encouraged to audit the script at:"
    echo -e "  ${BLUE}https://github.com/hubofvalley/Mainnet-Guides/blob/main/0g%20(zero-gravity)/resources/0g_validator_node_aristotle_install.sh${RESET}"

    echo -e "\n${YELLOW}2. SYSTEM IMPACT:${RESET}"
    echo -e "${GREEN}New Services:${RESET}"
    echo -e "  • ${CYAN}0gchaind.service${RESET} (Consensus Client)"
    echo -e "  • ${CYAN}0g-geth.service${RESET} (Execution Client)"
    
    echo -e "\n${RED}Existing Services to be Replaced:${RESET}"
    echo -e "  • ${CYAN}0gchaind${RESET}"
    echo -e "  • ${CYAN}0g-geth${RESET}"
    echo -e "  • ${CYAN}0ggeth${RESET}"
    
    echo -e "\n${GREEN}Port Configuration:${RESET}"
    echo -e "Ports will be adjusted based on your input (example if you enter 28):"
    echo -e "  • ${CYAN}28657${RESET} (RPC) <-- 26657"
    echo -e "  • ${CYAN}28656${RESET} (P2P) <-- 26656"
    echo -e "  • ${CYAN}28545${RESET} (EVM-RPC) <-- 8545"
    echo -e "  • ${CYAN}28546${RESET} (WebSocket) <-- 8546"
    
    echo -e "\n${GREEN}Directories:${RESET}"
    echo -e "  • ${CYAN}$HOME/.0gchaind${RESET}"

    echo -e "\n${YELLOW}3. REQUIREMENTS:${RESET}"
    echo "- CPU: 8+ cores, RAM: 64+ GB, Storage: 1TB+ NVMe SSD"
    echo "- Ubuntu 22.04/24.04 recommended"

    echo -e "\n${YELLOW}4. VALIDATOR RESPONSIBILITIES:${RESET}"
    echo "- As a validator, you'll need to:"
    echo "  - Maintain good uptime (recommended 99%+)"
    echo "  - Keep your node software updated"
    echo "  - Regularly backup your keys and data"
    echo "- The network has slashing mechanisms to:"
    echo "  - Encourage validator reliability"
    echo "  - Prevent malicious behavior"

    echo -e "\n${GREEN}By continuing you agree to these terms.${RESET}"
    read -p $'\n\e[33mDo you want to proceed with installation? (yes/no): \e[0m' confirm
    
    if [[ "${confirm,,}" != "yes" ]]; then
        echo -e "${RED}Installation cancelled by user.${RESET}"
        menu
        return
    fi

    echo -e "\n${GREEN}Starting installation...${RESET}"
    echo -e "${YELLOW}This may take 1-5 minutes. Please don't interrupt the process.${RESET}"
    sleep 2

    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Mainnet-Guides/main/0g%20\(zero-gravity\)/resources/0g_validator_node_aristotle_install.sh)
    menu
}

function manage_validator_node() {
    echo "Choose an option:"
    echo "1. Update Validator Node Version (includes Cosmovisor migration and deployment)"
    echo "2. Back"
    read -p "Enter your choice (1/2): " choice

    case $choice in
        1)
            bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Mainnet-Guides/main/0g%20\(zero-gravity\)/resources/0g_validator_node_update_manual.sh)
            menu
            ;;
        2)
            menu
            ;;
        *)
            echo "Invalid choice. Please select a valid option."
            ;;
    esac
}

# Function to migrate to Cosmovisor


function apply_snapshot() {
     bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Mainnet-Guides/main/0g%20\(zero-gravity\)/resources/apply_snapshot.sh)
     menu
}

function install_0gchain_app() {
    cd $HOME || return
    echo "Downloading and installing 0gchaind v1.0.2..."
    
    # Download and extract package
    wget -q https://github.com/0gfoundation/0gchain-Aristotle/releases/download/1.0.2/aristotle-v1.0.2.tar.gz -O aristotle-v1.0.2.tar.gz
    tar -xzf aristotle-v1.0.2.tar.gz -C $HOME
    if [ -d "$HOME/aristotle-v1.0.2" ]; then
        rm -rf "$HOME/aristotle"
        mv "$HOME/aristotle-v1.0.2" "$HOME/aristotle"
    fi
    
    # Ensure target directories exist
    mkdir -p $HOME/go/bin
    
    # Install binary
    if [ -f "$HOME/aristotle/bin/0gchaind" ]; then
        # Copy to standard location
        cp "$HOME/aristotle/bin/0gchaind" "$HOME/go/bin/0gchaind"
        sudo chmod +x "$HOME/go/bin/0gchaind"
        echo "0gchaind v1.0.2 installed successfully to:"
        echo "- $HOME/go/bin/0gchaind"
    else
        echo "Error: 0gchaind binary not found in extracted package!"
    fi
    
    # Cleanup
    rm -f aristotle-v1.0.2.tar.gz
    menu
}

function create_validator() {
    # Only check; install is optional and prompted later if needed for auto path
    ensure_evm_cli_tools check || true
    # Offer to load/provide PRIVATE_KEY up front for auto submission
    ensure_private_key optional || true
    echo -e "${CYAN}Create 0G Validator (Mainnet / Aristotle)${RESET}"
    echo -e "${YELLOW}Requirements:${RESET} Ensure 0gchaind and 0g-geth are fully synced, and your EVM wallet holds at least 500 OG plus gas."

    # Defaults (overridable via ENV)
    BIN_0GCHAIND="${BIN_0GCHAIND:-0gchaind}"
    OG_HOME="${OG_HOME:-$HOME/.0gchaind/0g-home/0gchaind-home}"
    OG_GENESIS_PATH="${OG_GENESIS_PATH:-$OG_HOME/config/genesis.json}"
    OG_EVM_RPC="${OG_EVM_RPC:-https://evmrpc.0g.ai}"
    STAKING_ADDRESS="${STAKING_ADDRESS:-0xea224dBB52F57752044c0C86aD50930091F561B9}"
    DEPOSIT_MSG_AMOUNT="${DEPOSIT_MSG_AMOUNT:-500000000000}"
    WITHDRAW_GWEI_DEFAULT="${WITHDRAW_GWEI_DEFAULT:-1}"

    # Inputs
    read -p "Enter validator name (moniker): " MONIKER
    read -p "Enter identity (Keybase, optional): " IDENTITY
    read -p "Enter website URL (optional): " WEBSITE
    read -p "Enter security contact email: " EMAIL
    read -p "Enter details (≤200 chars): " DETAILS

    read -p "Commission rate in % (e.g., 5 for 5%): " COMM_PCT
    COMM_PCT=${COMM_PCT:-5}
    COMM_BPS=$(awk 'BEGIN{printf "%d", ('"${COMM_PCT:-0}"')*10000}')
    if ! awk 'BEGIN{exit !('"${COMM_PCT:-0}"'>=0 && '"${COMM_PCT:-0}"'<=100)}'; then
        echo -e "${RED}Invalid commission (0–100).${RESET}"; menu; return 1
    fi

    read -p "Withdrawal fee in Gwei [default ${WITHDRAW_GWEI_DEFAULT}]: " WITHDRAW_GWEI
    WITHDRAW_GWEI=${WITHDRAW_GWEI:-$WITHDRAW_GWEI_DEFAULT}

    read -p "Custom EVM RPC? [Enter to use ${OG_EVM_RPC}]: " RPC_INPUT
    if [ -n "${RPC_INPUT}" ]; then OG_EVM_RPC="$RPC_INPUT"; fi

    echo -e "\n${YELLOW}Summary:${RESET}"
    echo "  Moniker:            $MONIKER"
    echo "  Commission (bps):   $COMM_BPS  (~${COMM_PCT}%)"
    echo "  Withdrawal fee:     ${WITHDRAW_GWEI} Gwei"
    echo "  EVM RPC:            $OG_EVM_RPC"
    echo "  Staking Contract:   $STAKING_ADDRESS"
    echo "  Payable on tx:      500 OG"
    read -p "Proceed? (y/n, b=back): " CONFIRM
    case "${CONFIRM,,}" in
        y|yes) ;;
        b|back) echo -e "${YELLOW}Returning to menu...${RESET}"; menu; return 0 ;;
        *) echo -e "${RED}Cancelled.${RESET}"; menu; return 1 ;;
    esac

    # 1) Generate deposit message (pubkey + signature)
    echo -e "${CYAN}Generating deposit message (pubkey + signature)...${RESET}"
    TMP_OUT="$(mktemp)"
    $BIN_0GCHAIND deposit create-delegation-validator \
        "$STAKING_ADDRESS" \
        "$DEPOSIT_MSG_AMOUNT" \
        "$OG_GENESIS_PATH" \
        --home "$OG_HOME" \
        --chaincfg.chain-spec=mainnet \
        --override-rpc-url \
        --rpc-dial-url "$OG_EVM_RPC" | tee "$TMP_OUT"
    RC=$?
    if [ $RC -ne 0 ]; then
        echo -e "${RED}Failed to create deposit message.${RESET}"; rm -f "$TMP_OUT"; menu; return 1
    fi

    PUBKEY=$(grep -Eo 'pubkey: 0x[0-9a-fA-F]+' "$TMP_OUT" | awk '{print $2}')
    SIGNATURE=$(grep -Eo 'signature: 0x[0-9a-fA-F]+' "$TMP_OUT" | awk '{print $2}')
    rm -f "$TMP_OUT"
    if [ -z "$PUBKEY" ] || [ -z "$SIGNATURE" ]; then
        echo -e "${RED}Could not parse pubkey/signature.${RESET}"; menu; return 1
    fi

    # 2) Validate signature
    echo -e "${CYAN}Validating deposit message...${RESET}"
    $BIN_0GCHAIND deposit validate-delegation \
        "$PUBKEY" \
        "$STAKING_ADDRESS" \
        "$DEPOSIT_MSG_AMOUNT" \
        "$SIGNATURE" \
        "$OG_GENESIS_PATH" \
        --home "$OG_HOME" \
        --chaincfg.chain-spec=mainnet \
        --override-rpc-url \
        --rpc-dial-url "$OG_EVM_RPC"

    # 3) Execute init tx via cast if available, else manual instruction
    echo -e "${CYAN}Initializing validator on Staking Contract...${RESET}"
    if command -v cast >/dev/null 2>&1 && [ -n "${PRIVATE_KEY:-}" ]; then
        DESC_TUPLE=$(printf '("%s","%s","%s","%s","%s")' "$MONIKER" "$IDENTITY" "$WEBSITE" "$EMAIL" "$DETAILS")
        cast send "$STAKING_ADDRESS" \
            'createAndInitializeValidatorIfNecessary((string,string,string,string,string),uint32,uint96,bytes,bytes)' \
            "$DESC_TUPLE" \
            "$COMM_BPS" \
            "$WITHDRAW_GWEI" \
            "$PUBKEY" \
            "$SIGNATURE" \
            --value 500ether \
            --rpc-url "$OG_EVM_RPC" \
            --private-key "$PRIVATE_KEY"
        echo -e "${GREEN}Submitted. Track on https://chainscan.0g.ai/${RESET}"
    else
        # Offer to install tools for auto path
        if [ -z "${PRIVATE_KEY:-}" ]; then
            echo -e "${YELLOW}PRIVATE_KEY not set; proceeding with manual path.${RESET}"
        elif ! command -v cast >/dev/null 2>&1; then
            echo -e "${YELLOW}'cast' not available for auto submission.${RESET}"
            read -p "Install Foundry to enable auto submission? (y/n, b=back): " _ans
            case "${_ans,,}" in
              y|yes)
                ensure_evm_cli_tools prompt || true
                if command -v cast >/dev/null 2>&1; then
                  DESC_TUPLE=$(printf '("%s","%s","%s","%s","%s")' "$MONIKER" "$IDENTITY" "$WEBSITE" "$EMAIL" "$DETAILS")
                  cast send "$STAKING_ADDRESS" \
                    'createAndInitializeValidatorIfNecessary((string,string,string,string,string),uint32,uint96,bytes,bytes)' \
                    "$DESC_TUPLE" \
                    "$COMM_BPS" \
                    "$WITHDRAW_GWEI" \
                    "$PUBKEY" \
                    "$SIGNATURE" \
                    --value 500ether \
                    --rpc-url "$OG_EVM_RPC" \
                    --private-key "$PRIVATE_KEY"
                  echo -e "${GREEN}Submitted. Track on https://chainscan.0g.ai/${RESET}"
                  echo -e "${YELLOW}Press Enter to return to menu...${RESET}"; read -r; menu; return 0
                fi
                ;;
              b|back) echo -e "${YELLOW}Returning to menu...${RESET}"; menu; return 0 ;;
              *) : ;;
            esac
        fi
        echo -e "${YELLOW}Manual path (ChainScan UI):${RESET}"
        echo "  1) Open: https://chainscan.0g.ai/address/$STAKING_ADDRESS (Contracts -> Write as Proxy)"
        echo "  2) Call: createAndInitializeValidatorIfNecessary"
        echo "     - description.moniker         = $MONIKER"
        echo "     - description.identity        = $IDENTITY"
        echo "     - description.website         = $WEBSITE"
        echo "     - description.securityContact = $EMAIL"
        echo "     - description.details         = $DETAILS"
        echo "     - commissionRate (bps)        = $COMM_BPS"
        echo "     - withdrawalFeeInGwei         = $WITHDRAW_GWEI"
        echo "     - pubkey                      = $PUBKEY"
        echo "     - signature                   = $SIGNATURE"
        echo "  3) Set payable amount = 500 OG, then submit."
    fi

    echo -e "\n${YELLOW}Validator may appear active after ~30–60 minutes on the explorer:${RESET}"
    echo "  https://explorer.0g.ai/mainnet/validators"
    echo -e "${YELLOW}Press Enter to return to menu...${RESET}"
    read -r
    menu
}

# Delegate to a validator (0G Mainnet / Aristotle)
function delegate_to_validator() {
    set -euo pipefail

    # Tools: Foundry (cast) optional for auto flow; PRIVATE_KEY optional
    ensure_evm_cli_tools check || true
    ensure_private_key optional || true

    # 'bc' is not strictly required for delegation, but useful to have
    if ! command -v bc >/dev/null 2>&1; then
      echo -e "${YELLOW}Installing 'bc' (optional, useful for math) ...${RESET}"
      if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update -y && sudo apt-get install -y bc || true
      fi
    fi

    echo -e "${CYAN}Delegate 0G to Validator${RESET}"
    echo -e "${YELLOW}Requirements:${RESET} EVM wallet with 0G for stake + gas. For auto mode, both 'cast' and PRIVATE_KEY must be available."

    # Defaults (override via ENV)
    OG_EVM_RPC="${OG_EVM_RPC:-https://evmrpc.0g.ai}"
    STAKING_ADDRESS="${STAKING_ADDRESS:-0xea224dBB52F57752044c0C86aD50930091F561B9}"
    GV_VALIDATOR_ADDR="${GV_VALIDATOR_ADDR:-0x108e619dA0cdbA8A301A53948A4aCc23A3d79377}"
    GV_VALIDATOR_PUBKEY="${GV_VALIDATOR_PUBKEY:-0xb589c0c26210a065a4c4aee068346301490efad5bfaa0578f186c6e41cc4018004f08a411ef0f056468174c260307b7e}"

    echo "Select how to specify the validator:"
    echo "  1) Enter validator contract address (0x...)"
    echo "  2) Enter validator PUBKEY (48-byte) and resolve via Staking.getValidator(bytes)"
    echo "  3) Use Grand Valley defaults from ENV (GV_VALIDATOR_ADDR / GV_VALIDATOR_PUBKEY)"
    read -p "Choice [1/2/3, b=back]: " MODE
    if [[ "${MODE,,}" == "b" || "${MODE,,}" == "back" ]]; then menu; return; fi

    VALIDATOR_ADDR=""
    case "${MODE:-3}" in
      1)
        read -p "Validator contract address (0x...): " VALIDATOR_ADDR
        ;;
      2)
        read -p "Validator PUBKEY (0x... 48-byte): " VAL_PUBKEY
        if ! command -v cast >/dev/null 2>&1; then
          echo -e "${YELLOW}'cast' is required to resolve validator address from PUBKEY.${RESET}"
          read -p "Install Foundry now? (y/n, b=back): " _ans
          case "${_ans,,}" in
            y|yes) ensure_evm_cli_tools prompt || true ;;
            b|back) menu; return 0 ;;
            *) echo -e "${RED}Cannot resolve without 'cast'.${RESET}"; return 1 ;;
          esac
        fi
        command -v cast >/dev/null 2>&1 || { echo -e "${RED}Cast still unavailable.${RESET}"; return 1; }
        VALIDATOR_ADDR=$(cast call "$STAKING_ADDRESS" 'getValidator(bytes)(address)' "$VAL_PUBKEY" --rpc-url "$OG_EVM_RPC" | tail -n1 | tr -d '[:space:]')
        [[ -z "$VALIDATOR_ADDR" || "$VALIDATOR_ADDR" == "0x0000000000000000000000000000000000000000" ]] && { echo -e "${RED}Validator not found for the provided PUBKEY.${RESET}"; return 1; }
        ;;
      3|*)
        if [ -n "$GV_VALIDATOR_ADDR" ]; then
          VALIDATOR_ADDR="$GV_VALIDATOR_ADDR"
        elif [ -n "$GV_VALIDATOR_PUBKEY" ]; then
          if ! command -v cast >/dev/null 2>&1; then
            echo -e "${YELLOW}'cast' is required to resolve GV_VALIDATOR_PUBKEY.${RESET}"
            read -p "Install Foundry now? (y/n, b=back): " _ans
            case "${_ans,,}" in
              y|yes) ensure_evm_cli_tools prompt || true ;;
              b|back) menu; return 0 ;;
              *) echo -e "${RED}Cannot resolve without 'cast'.${RESET}"; return 1 ;;
            esac
          fi
          command -v cast >/dev/null 2>&1 || { echo -e "${RED}Cast still unavailable.${RESET}"; return 1; }
          VALIDATOR_ADDR=$(cast call "$STAKING_ADDRESS" 'getValidator(bytes)(address)' "$GV_VALIDATOR_PUBKEY" --rpc-url "$OG_EVM_RPC" | tail -n1 | tr -d '[:space:]')
          [[ -z "$VALIDATOR_ADDR" || "$VALIDATOR_ADDR" == "0x0000000000000000000000000000000000000000" ]] && { echo -e "${RED}Validator not found for GV_VALIDATOR_PUBKEY.${RESET}"; return 1; }
        else
          echo -e "${RED}GV_VALIDATOR_ADDR / GV_VALIDATOR_PUBKEY not set.${RESET}"
          return 1
        fi
        ;;
    esac

    read -p "Enter delegation amount in OG (decimals allowed, e.g., 123.45) [b=back]: " AMOUNT_OG
    if [[ "${AMOUNT_OG,,}" == "b" || "${AMOUNT_OG,,}" == "back" ]]; then menu; return; fi
    [[ -z "${AMOUNT_OG:-}" || ! "$AMOUNT_OG" =~ ^[0-9]+([.][0-9]+)?$ ]] && { echo -e "${RED}Invalid amount.${RESET}"; return 1; }

    if command -v cast >/dev/null 2>&1 && [ -n "${PRIVATE_KEY:-}" ]; then
      set +e
      DELEGATOR_ADDR=$(cast wallet address --private-key "$PRIVATE_KEY" 2>/dev/null || true)
      set -e
    fi
    if [ -z "${DELEGATOR_ADDR:-}" ]; then
      read -p "Your EVM address (delegator, 0x...): " DELEGATOR_ADDR
    fi

    read -p "Custom EVM RPC? [Enter to use ${OG_EVM_RPC}, b=back]: " RPC_INPUT
    if [[ "${RPC_INPUT,,}" == "b" || "${RPC_INPUT,,}" == "back" ]]; then menu; return; fi
    if [ -n "${RPC_INPUT}" ]; then OG_EVM_RPC="$RPC_INPUT"; fi

    echo -e "\n${YELLOW}Summary:${RESET}"
    echo "  Validator:  $VALIDATOR_ADDR"
    echo "  Delegator:  $DELEGATOR_ADDR"
    echo "  Amount:     $AMOUNT_OG OG"
    echo "  RPC:        $OG_EVM_RPC"
    read -p "Proceed with delegation? (y/n, b=back): " OK
    case "${OK,,}" in
      y|yes) ;;
      b|back) echo -e "${YELLOW}Returning to menu...${RESET}"; menu; return 0 ;;
      *) echo -e "${RED}Cancelled.${RESET}"; return 1 ;;
    esac

    if command -v cast >/dev/null 2>&1 && [ -n "${PRIVATE_KEY:-}" ]; then
      echo -e "${CYAN}Sending delegation transaction via 'cast'...${RESET}"
      TX_OUT=$(
        cast send "$VALIDATOR_ADDR" \
          'delegate(address)' "$DELEGATOR_ADDR" \
          --value "${AMOUNT_OG}ether" \
          --rpc-url "$OG_EVM_RPC" \
          --private-key "$PRIVATE_KEY" 2>&1 | tee /dev/tty
      )
      # Extract transaction hash (JSON or plain)
      TX_HASH=$(echo "$TX_OUT" | sed -n 's/.*"transactionHash"[[:space:]]*:[[:space:]]*"\(0x[0-9a-fA-F]\{64\}\)".*/\1/p' | head -n1)
      if [ -z "$TX_HASH" ]; then
        TX_HASH=$(echo "$TX_OUT" | sed -n 's/.*transactionHash[[:space:]]*\(0x[0-9a-fA-F]\{64\}\).*/\1/p' | head -n1)
      fi
      if [ -z "$TX_HASH" ]; then
        TX_HASH=$(echo "$TX_OUT" | grep -Eo '0x[0-9a-fA-F]{64}' | head -n1)
      fi

      if [ -n "$TX_HASH" ]; then
        echo -e "${GREEN}Delegation submitted. Track on Chainscan:${RESET} https://chainscan.0g.ai/tx/$TX_HASH"
      else
        echo -e "${YELLOW}Delegation submitted (tx hash not detected). Track contract:${RESET} https://chainscan.0g.ai/address/$VALIDATOR_ADDR"
      fi
    else
      echo -e "${YELLOW}Manual path (Chainscan UI):${RESET}"
      echo "  1) Open https://chainscan.0g.ai/address/$VALIDATOR_ADDR"
      echo "  2) Contract -> Write -> select 'delegate(address)'"
      echo "  3) Set 'delegator' = $DELEGATOR_ADDR"
      echo "  4) Set payable value = $AMOUNT_OG OG (native), connect your 0G Mainnet wallet, then submit."
    fi

    echo -e "${YELLOW}Useful checks:${RESET}"
    echo "  # Delegation info (returns delegator, shares):"
    echo "  cast call $VALIDATOR_ADDR 'getDelegation(address)(address,uint256)' $DELEGATOR_ADDR --rpc-url $OG_EVM_RPC"
    echo "  # Total tokens and shares on the validator:"
    echo "  cast call $VALIDATOR_ADDR 'tokens()(uint256)' --rpc-url $OG_EVM_RPC"
    echo "  cast call $VALIDATOR_ADDR 'delegatorShares()(uint256)' --rpc-url $OG_EVM_RPC"

    echo -e "\n${YELLOW}Press Enter to go back to main menu...${RESET}"
    read -r
    menu
}

# Undelegate from a validator (0G Mainnet / Aristotle)
function undelegate_from_validator() {
  set -euo pipefail

  # Tools & key (auto mode optional)
  ensure_evm_cli_tools prompt || true
  ensure_private_key optional || true

  # Ensure 'bc' for big-int math
  if ! command -v bc >/dev/null 2>&1; then
    echo -e "${YELLOW}Installing 'bc' (required for share calculations) ...${RESET}"
    if command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update -y && sudo apt-get install -y bc || true
    fi
    command -v bc >/dev/null 2>&1 || { echo -e "${RED}'bc' is required for the OG→shares calculation.${RESET}"; return 1; }
  fi

  echo -e "${CYAN}Undelegate from Validator${RESET}"
  echo -e "${YELLOW}Requirements:${RESET} A small amount of 0G for gas and the validator's withdrawal fee (in gwei). For auto mode, both 'cast' and PRIVATE_KEY must be available."

  # ===== Defaults (override via ENV) =====
  OG_EVM_RPC="${OG_EVM_RPC:-https://evmrpc.0g.ai}"
  STAKING_ADDRESS="${STAKING_ADDRESS:-0xea224dBB52F57752044c0C86aD50930091F561B9}"
  GV_VALIDATOR_ADDR="${GV_VALIDATOR_ADDR:-0x108e619dA0cdbA8A301A53948A4aCc23A3d79377}"
  GV_VALIDATOR_PUBKEY="${GV_VALIDATOR_PUBKEY:-0xb589c0c26210a065a4c4aee068346301490efad5bfaa0578f186c6e41cc4018004f08a411ef0f056468174c260307b7e}"

  # ===== Choose how to specify the validator =====
  echo "Select how to specify the validator:"
  echo "  1) Enter validator contract address (0x...)"
  echo "  2) Enter validator PUBKEY (48-byte) and resolve via Staking.getValidator(bytes)"
  echo "  3) Use Grand Valley defaults from ENV (GV_VALIDATOR_ADDR / GV_VALIDATOR_PUBKEY)"
  read -rp "Choice [1/2/3, b=back]: " MODE
  if [[ "${MODE,,}" == "b" || "${MODE,,}" == "back" ]]; then menu; return; fi

  VALIDATOR_ADDR=""
  case "${MODE:-3}" in
    1)
      read -rp "Validator contract address (0x...): " VALIDATOR_ADDR
      ;;
    2)
      read -rp "Validator PUBKEY (0x... 48-byte): " VAL_PUBKEY
      if command -v cast >/dev/null 2>&1; then
        VALIDATOR_ADDR=$(cast call "$STAKING_ADDRESS" 'getValidator(bytes)(address)' "$VAL_PUBKEY" --rpc-url "$OG_EVM_RPC" | tail -n1 | tr -d '[:space:]')
      else
        echo -e "${RED}Resolving from pubkey requires 'cast'.${RESET}"; return 1
      fi
      ;;
    3|*)
      if [ -n "$GV_VALIDATOR_ADDR" ]; then
        VALIDATOR_ADDR="$GV_VALIDATOR_ADDR"
      elif [ -n "$GV_VALIDATOR_PUBKEY" ] && command -v cast >/dev/null 2>&1; then
        VALIDATOR_ADDR=$(cast call "$STAKING_ADDRESS" 'getValidator(bytes)(address)' "$GV_VALIDATOR_PUBKEY" --rpc-url "$OG_EVM_RPC" | tail -n1 | tr -d '[:space:]')
      fi
      ;;
  esac

  if [[ -z "$VALIDATOR_ADDR" || "$VALIDATOR_ADDR" == "0x0000000000000000000000000000000000000000" ]]; then
    echo -e "${RED}Validator address not resolved. Provide a contract address or ensure 'cast' is available for PUBKEY resolution.${RESET}"
    return 1
  fi

  # ===== Delegator address =====
  if command -v cast >/dev/null 2>&1 && [ -n "${PRIVATE_KEY:-}" ]; then
    set +e
    DELEGATOR_ADDR=$(cast wallet address --private-key "$PRIVATE_KEY" 2>/dev/null || true)
    set -e
  fi
  if [ -z "${DELEGATOR_ADDR:-}" ]; then
    read -rp "Your EVM address (delegator, 0x...): " DELEGATOR_ADDR
  fi

  # ===== Optional: custom RPC =====
  read -rp "Custom EVM RPC? [Enter to use ${OG_EVM_RPC}, b=back]: " RPC_INPUT
  if [[ "${RPC_INPUT,,}" == "b" || "${RPC_INPUT,,}" == "back" ]]; then menu; return; fi
  if [ -n "${RPC_INPUT}" ]; then OG_EVM_RPC="$RPC_INPUT"; fi

  # ===== Input mode: OG amount -> shares; or raw shares =====
  echo "Select undelegation input:"
  echo "  1) Enter target amount in OG (recommended)"
  echo "  2) Enter raw shares (advanced)"
  read -rp "Choice [1/2, b=back]: " AMODE
  if [[ "${AMODE,,}" == "b" || "${AMODE,,}" == "back" ]]; then menu; return; fi

  SHARES=""
  AMOUNT_OG=""
  if [[ "${AMODE:-1}" == "2" ]]; then
    read -rp "Shares to undelegate (uint) [b=back]: " SHARES
    if [[ "${SHARES,,}" == "b" || "${SHARES,,}" == "back" ]]; then menu; return; fi
    [[ -z "$SHARES" || ! "$SHARES" =~ ^[0-9]+$ ]] && { echo -e "${RED}Invalid shares.${RESET}"; return 1; }
  else
    read -rp "Target amount to withdraw (in OG, decimals allowed, e.g., 12.34) [b=back]: " AMOUNT_OG
    if [[ "${AMOUNT_OG,,}" == "b" || "${AMOUNT_OG,,}" == "back" ]]; then menu; return; fi
    [[ -z "${AMOUNT_OG:-}" || ! "$AMOUNT_OG" =~ ^[0-9]+([.][0-9]+)?$ ]] && { echo -e "${RED}Invalid amount.${RESET}"; return 1; }
  fi

  # ===== Read pool state & compute shares if needed =====
  if [ -z "$SHARES" ]; then
    if ! command -v cast >/dev/null 2>&1; then
      echo -e "${RED}On-chain reads require 'cast'. Install it or use raw shares (option 2).${RESET}"
      return 1
    fi

    TOTAL_TOKENS=$(cast call "$VALIDATOR_ADDR" 'tokens()(uint256)' --rpc-url "$OG_EVM_RPC" | tail -n1 | tr -d '[:space:]')
    TOTAL_SHARES=$(cast call "$VALIDATOR_ADDR" 'delegatorShares()(uint256)' --rpc-url "$OG_EVM_RPC" | tail -n1 | tr -d '[:space:]')

    if [[ -z "$TOTAL_TOKENS" || "$TOTAL_TOKENS" == "0" || -z "$TOTAL_SHARES" || "$TOTAL_SHARES" == "0" ]]; then
      echo -e "${RED}Pool state invalid (zero tokens or shares).${RESET}"; return 1
    fi

    # getDelegation returns (address, uint). Take the last line as shares.
    mapfile -t _DELEG_OUT < <(cast call "$VALIDATOR_ADDR" 'getDelegation(address)(address,uint256)' "$DELEGATOR_ADDR" --rpc-url "$OG_EVM_RPC")
    MY_SHARES="${_DELEG_OUT[-1]//[[:space:]]/}"

    if [[ -z "$MY_SHARES" || "$MY_SHARES" == "0" ]]; then
      echo -e "${RED}No active delegation found for this address.${RESET}"; return 1
    fi

    AMOUNT_WEI=$(cast to-wei "$AMOUNT_OG" ether)
    # sharesNeeded = ceil(amountWei * totalShares / totalTokens)
    SHARES=$(echo "($AMOUNT_WEI * $TOTAL_SHARES + $TOTAL_TOKENS - 1) / $TOTAL_TOKENS" | bc)
    if [[ -z "$SHARES" || "$SHARES" -le 0 ]]; then
      echo -e "${RED}Computed shares <= 0. Choose a larger amount.${RESET}"; return 1
    fi
    if (( SHARES > MY_SHARES )); then
      echo -e "${RED}Computed shares exceed your current shares ($MY_SHARES). Lower the amount.${RESET}"; return 1
    fi
  fi

  # ===== Withdrawal recipient (defaults to delegator) =====
  read -rp "Withdrawal recipient (default: $DELEGATOR_ADDR, b=back): " WITHDRAW_ADDR
  if [[ "${WITHDRAW_ADDR,,}" == "b" || "${WITHDRAW_ADDR,,}" == "back" ]]; then menu; return; fi
  WITHDRAW_ADDR=${WITHDRAW_ADDR:-$DELEGATOR_ADDR}

  # ===== Withdrawal fee (msg.value) =====
  if command -v cast >/dev/null 2>&1; then
    FEE_GWEI=$(cast call "$VALIDATOR_ADDR" 'withdrawalFeeInGwei()(uint96)' --rpc-url "$OG_EVM_RPC" | tail -n1 | tr -d '[:space:]')
    FEE_WEI=$(cast to-wei "$FEE_GWEI" gwei)
  else
    read -rp "Validator withdrawal fee in Gwei (cannot query without 'cast'): " FEE_GWEI
    FEE_WEI=$(printf "%.0f" "$(awk "BEGIN{print $FEE_GWEI * 1000000000}")")
  fi

  # ===== Confirm =====
  echo -e "\n${YELLOW}Summary:${RESET}"
  echo "  Validator:         $VALIDATOR_ADDR"
  echo "  Delegator:         $DELEGATOR_ADDR"
  echo "  Withdrawal to:     $WITHDRAW_ADDR"
  echo "  Shares to remove:  $SHARES"
  echo "  Withdrawal fee:    ${FEE_GWEI:-unknown} gwei (${FEE_WEI} wei)"
  echo "  RPC:               $OG_EVM_RPC"
  read -rp "Proceed with undelegation? (y/n, b=back): " OK
  case "${OK,,}" in
    y|yes) ;;
    b|back) echo -e "${YELLOW}Returning to menu...${RESET}"; menu; return 0 ;;
    *) echo -e "${RED}Cancelled.${RESET}"; return 1 ;;
  esac

  # ===== Send TX or print manual steps =====
  if command -v cast >/dev/null 2>&1 && [ -n "${PRIVATE_KEY:-}" ]; then
    echo -e "${CYAN}Sending undelegation transaction via 'cast'...${RESET}"
    TX_OUT=$(
      cast send "$VALIDATOR_ADDR" \
        'undelegate(address,uint256)' "$WITHDRAW_ADDR" "$SHARES" \
        --value "$FEE_WEI" \
        --rpc-url "$OG_EVM_RPC" \
        --private-key "$PRIVATE_KEY" 2>&1 | tee /dev/tty
    )

    # Extract transaction hash (JSON or plain)
    TX_HASH=$(echo "$TX_OUT" | sed -n 's/.*"transactionHash"[[:space:]]*:[[:space:]]*"\(0x[0-9a-fA-F]\{64\}\)".*/\1/p' | head -n1)
    if [ -z "$TX_HASH" ]; then
      TX_HASH=$(echo "$TX_OUT" | sed -n 's/.*transactionHash[[:space:]]*\(0x[0-9a-fA-F]\{64\}\).*/\1/p' | head -n1)
    fi
    if [ -z "$TX_HASH" ]; then
      TX_HASH=$(echo "$TX_OUT" | grep -Eo '0x[0-9a-fA-F]{64}' | head -n1)
    fi

    if [ -n "$TX_HASH" ]; then
      echo -e "${GREEN}Undelegation submitted. Track on Chainscan:${RESET} https://chainscan.0g.ai/tx/$TX_HASH"
    else
      echo -e "${YELLOW}Undelegation submitted (tx hash not detected). Track contract:${RESET} https://chainscan.0g.ai/address/$VALIDATOR_ADDR"
    fi
  else
    echo -e "${YELLOW}Manual path (Chainscan UI):${RESET}"
    echo "  1) Open https://chainscan.0g.ai/address/$VALIDATOR_ADDR"
    echo "  2) Contract → Write → select 'undelegate(address,uint256)'"
    echo "  3) Set:"
    echo "       withdrawalAddress = $WITHDRAW_ADDR"
    echo "       shares            = $SHARES"
    echo "  4) Set payable value = ${FEE_GWEI:-<fee in gwei>} gwei (i.e., ${FEE_WEI} wei)."
    echo "  5) Connect your 0G Mainnet wallet and submit."
  fi

    echo -e "\n${YELLOW}Press Enter to go back to main menu...${RESET}"
    read -r
    menu
}

function query_balance() {
    echo -e "${CYAN}Select an option:${RESET}"
    echo "1. Query balance of EVM address"
    echo "2. Back"
    read -p "Enter your choice (1 or 2): " choice

    case $choice in
        1)
            read -p "Enter the EVM address to query: " evm_address
            ;;
        2)
            menu
            return
            ;;
        *)
            echo -e "${RED}Invalid choice. Please enter 1, 2, or 3.${RESET}"
            query_balance
            return
            ;;
    esac

    echo -e "${CYAN}Fetching balance from mainnet RPC for $evm_address...${RESET}"
    curl -s --insecure -X POST https://lightnode-json-rpc-mainnet-0g.grandvalleys.com \
        -H "Content-Type: application/json" \
        -d "{
            \"jsonrpc\":\"2.0\",
            \"method\":\"eth_getBalance\",
            \"params\": [\"$evm_address\", \"latest\"],
            \"id\":16661
        }" | jq -r '.result' | awk '{printf "Balance of %s: %0.18f 0G\n", "'"$evm_address"'", strtonum($1)/1e18}'

    echo -e "\n${YELLOW}Press Enter to go back to main menu...${RESET}"
    read -r
    menu
}

# function send_transaction() {
#     echo -e "\n${YELLOW}Available wallets:${RESET}"
#     0gchaind keys list
#
#     read -p "Enter sender wallet name: " SENDER_WALLET
#     read -p "Enter recipient wallet address: " RECIPIENT_ADDRESS
#     read -p "Enter amount to send (in AOGI, e.g. 10 = 10 AOGI): " AMOUNT_AOGI
#
#     AMOUNT_UAOGI=$(awk "BEGIN { printf \"%.0f\", $AMOUNT_AOGI * 1000000 }")
#
#     0gchaind tx bank send "$SENDER_WALLET" "$RECIPIENT_ADDRESS" "${AMOUNT_UAOGI}u0G" --chain-id "$OG_CHAIN_ID" --gas auto --gas-adjustment 1.5 -y
#
#     menu
# }

# function stake_tokens() {
#     echo -e "\n${YELLOW}Available wallets:${RESET}"
#     0gchaind keys list
#
#     DEFAULT_WALLET=$WALLET
#
#     read -p "Enter wallet name (leave empty to use current default wallet --> $DEFAULT_WALLET): " WALLET_NAME
#     if [ -z "$WALLET_NAME" ]; then
#         WALLET_NAME=$DEFAULT_WALLET
#     fi
#
#     echo "Choose an option:"
#     echo "1. Delegate to Grand Valley"
#     echo "2. Self-delegate"
#     echo "3. Delegate to another validator"
#     read -p "Enter your choice (1, 2, or 3): " CHOICE
#
#     # Prompt for RPC choice
#     read -p "Use your own RPC or Grand Valley's? (own/gv, leave empty for gv): " RPC_CHOICE
#     if [ -z "$RPC_CHOICE" ]; then
#         RPC_CHOICE="gv"
#     fi
#
#     case $CHOICE in
#         1)
#             read -p "Enter amount to stake (in AOGI, e.g. 10 = 10 AOGI): " AMOUNT_AOGI
#             VAL="0gvaloper1gela3jtnmen0dmj2q5p0pne5y45ftshzs053x3"
#             ;;
#         2)
#             read -p "Enter amount to stake (in AOGI, e.g. 10 = 10 AOGI): " AMOUNT_AOGI
#             VAL=$(0gchaind keys show "$WALLET_NAME" --bech val -a)
#             ;;
#         3)
#             read -p "Enter validator address: " VAL
#             read -p "Enter amount to stake (in AOGI, e.g. 10 = 10 AOGI): " AMOUNT_AOGI
#             ;;
#         *)
#             echo "Invalid choice. Please enter 1, 2, or 3."
#             menu
#             return
#             ;;
#     esac
#
#     AMOUNT_UAOGI=$(awk "BEGIN { printf \"%.0f\", $AMOUNT_AOGI * 1000000 }")
#
#     if [ "$RPC_CHOICE" == "gv" ]; then
#         NODE="--node https://lightnode-rpc-mainnet-0g.grandvalleys.com:443"
#     else
#         NODE=""
#     fi
#
#     0gchaind tx staking delegate "$VAL" "${AMOUNT_UAOGI}u0G" --from "$WALLET_NAME" --chain-id "$OG_CHAIN_ID" --gas auto --gas-adjustment 1.5 $NODE -y
#
#     menu
# }

# function unstake_tokens() {
#     echo -e "\n${YELLOW}Available wallets:${RESET}"
#     0gchaind keys list
#
#     DEFAULT_WALLET=$WALLET
#
#     read -p "Enter wallet name (leave empty to use current default wallet --> $DEFAULT_WALLET): " WALLET_NAME
#     if [ -z "$WALLET_NAME" ]; then
#         WALLET_NAME=$DEFAULT_WALLET
#     fi
#
#     read -p "Enter validator address: " VALIDATOR_ADDRESS
#     read -p "Enter amount to unstake (in AOGI, e.g. 10 = 10 AOGI): " AMOUNT_AOGI
#
#     # Prompt for RPC choice
#     read -p "Use your own RPC or Grand Valley's? (own/gv, leave empty for gv): " RPC_CHOICE
#     if [ -z "$RPC_CHOICE" ]; then
#         RPC_CHOICE="gv"
#     fi
#
#     AMOUNT_UAOGI=$(awk "BEGIN { printf \"%.0f\", $AMOUNT_AOGI * 1000000 }")
#
#     if [ "$RPC_CHOICE" == "gv" ]; then
#         NODE="--node https://lightnode-rpc-mainnet-0g.grandvalleys.com:443"
#     else
#         NODE=""
#     fi
#
#     0gchaind tx staking unbond "$VALIDATOR_ADDRESS" "${AMOUNT_UAOGI}u0G" --from "$WALLET_NAME" --chain-id "$OG_CHAIN_ID" --gas auto --gas-adjustment 1.5 $NODE -y
#
#     menu
# }

# function unjail_validator() {
#     echo -e "\n${YELLOW}Available wallets:${RESET}"
#     0gchaind keys list
#
#     DEFAULT_WALLET=$WALLET
#
#     read -p "Enter wallet name to unjail (leave empty to use default --> $DEFAULT_WALLET): " WALLET_NAME
#     if [ -z "$WALLET_NAME" ]; then
#         WALLET_NAME=$DEFAULT_WALLET
#     fi
#
#     # Prompt for RPC choice
#     read -p "Use your own RPC or Grand Valley's? (own/gv, leave empty for gv): " RPC_CHOICE
#     if [ -z "$RPC_CHOICE" ]; then
#         RPC_CHOICE="gv"
#     fi
#
#     if [ "$RPC_CHOICE" == "gv" ]; then
#         NODE="--node https://lightnode-rpc-mainnet-0g.grandvalleys.com:443"
#     else
#         NODE=""
#     fi
#
#     0gchaind tx slashing unjail --from "$WALLET_NAME" --chain-id "$OG_CHAIN_ID" --gas-adjustment 1.6 --gas auto --gas-prices 0.003u0G $NODE -y
#
#     menu
# }

# function export_evm_private_key() {
#     read -p "Enter wallet name: " WALLET_NAME
#     0gchaind keys unsafe-export-eth-key $WALLET_NAME
#     echo -e "\n${YELLOW}Press Enter to go back to main menu${RESET}"
#     read -r
#     menu
# }

# function restore_wallet() {
#     read -p "Enter wallet name: " WALLET_NAME
#     0gchaind keys add $WALLET_NAME --recover --eth
#     menu
# }

# function create_wallet() {
#     read -p "Enter wallet name: " WALLET_NAME
#     0gchaind keys add $WALLET_NAME --eth
#     menu
# }

function ensure_evm_cli_tools() {
  # Modes:
  #  - check:   only check and report; never install
  #  - prompt:  prompt to install if missing (default)
  #  - require: prompt to install; fail if still missing
  local mode="${1:-prompt}"
  local missing_bc=0
  local missing_cast=0
  local foundry_bin="$HOME/.foundry/bin"
  local export_line='export PATH="$HOME/.foundry/bin:$PATH"'

  # Persist PATH for future shells
  _persist_foundry_path() {
    for f in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; do
      if [ -e "$f" ]; then
        grep -qs 'foundry/bin' "$f" || echo "$export_line" >> "$f"
      else
        echo "$export_line" >> "$f"
      fi
    done
  }

  # Activate in current shell
  _activate_foundry_in_session() {
    export PATH="$foundry_bin:$PATH"
    hash -r 2>/dev/null || true
  }

  # Check bc
  if ! command -v bc >/dev/null 2>&1; then
    missing_bc=1
    if [ "$mode" != "check" ]; then
      echo -e "${YELLOW}'bc' is required for calculations but not found.${RESET}"
      read -p "Install 'bc' now? (y/n, b=back): " ans
      case "${ans,,}" in
        y|yes)
          if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update -y && sudo apt-get install -y bc || true
          elif command -v brew >/dev/null 2>&1; then
            brew install bc || true
          else
            echo -e "${RED}Automatic installation not supported on this system.${RESET}"
          fi
          ;;
        b|back) return 1 ;;
        *) : ;;
      esac
      command -v bc >/dev/null 2>&1 || missing_bc=1
      [ $missing_bc -eq 0 ] && echo -e "${GREEN}'bc' is installed.${RESET}"
    fi
  fi

  # If Foundry exists but PATH isn't set, activate it
  if ! command -v cast >/dev/null 2>&1 && [ -x "$foundry_bin/cast" ]; then
    _activate_foundry_in_session
  fi

  # Check cast (Foundry)
  if ! command -v cast >/dev/null 2>&1; then
    missing_cast=1
    if [ "$mode" != "check" ]; then
      echo -e "${YELLOW}'cast' (Foundry) is required for EVM RPC/tx, but not found.${RESET}"
      read -p "Install Foundry (provides 'cast') now? (y/n, b=back): " ans
      case "${ans,,}" in
        y|yes)
          # Bootstrap Foundry if needed
          if [ ! -x "$foundry_bin/foundryup" ]; then
            (curl -L https://foundry.paradigm.xyz | bash) || true
          fi
          # Activate + persist PATH
          _activate_foundry_in_session
          _persist_foundry_path
          # Install/update binaries non-interactively
          if [ -x "$foundry_bin/foundryup" ]; then
            "$foundry_bin/foundryup" -y || true
          fi
          # Re-activate (in case PATH changed)
          _activate_foundry_in_session
          ;;
        b|back) return 1 ;;
        *) : ;;
      esac
      command -v cast >/dev/null 2>&1 || missing_cast=1
      [ $missing_cast -eq 0 ] && echo -e "${GREEN}'cast' is installed and on PATH.${RESET}"
    fi
  fi

  # Require mode: enforce availability
  if [ "$mode" = "require" ]; then
    if [ $missing_bc -ne 0 ] || [ $missing_cast -ne 0 ]; then
      echo -e "${RED}Required tools are missing ('bc' and/or 'cast').${RESET}"
      return 1
    fi
  fi

  return 0
}

# Helper to resolve default .env file location for 0gchaind
function _resolve_og_env_file() {
  local home_dir
  home_dir="${OG_HOME:-$HOME/.0gchaind/0g-home/0gchaind-home}"
  echo "$home_dir/.env"
}

# Ensure PRIVATE_KEY is available (optionally prompt the user)
# Modes:
#  - optional (default): try env var, then .env file, then ask user if they want to provide; returns 0 even if not set
#  - required: same, but if still not available after prompts, return 1
function ensure_private_key() {
  local mode="${1:-optional}"
  local env_file
  env_file=$(_resolve_og_env_file)

  # If already set, nothing to do
  if [ -n "${PRIVATE_KEY:-}" ]; then
    return 0
  fi

  # Try to load from env file
  if [ -f "$env_file" ]; then
    local pk
    pk=$(grep -E '^PRIVATE_KEY=' "$env_file" | head -n1 | sed -E 's/^PRIVATE_KEY=//')
    if [ -n "$pk" ]; then
      export PRIVATE_KEY="$pk"
      return 0
    fi
  fi

  # Interactive prompt
  echo -e "${YELLOW}Auto-submit requires an EVM private key (hex).${RESET}"
  read -p "Provide a private key now to enable auto submission? (y/n, b=back): " _ans
  case "${_ans,,}" in
    y|yes)
      ;;
    b|back)
      [ "$mode" = "required" ] && return 1 || return 0 ;;
    *)
      [ "$mode" = "required" ] && { echo -e "${RED}PRIVATE_KEY is required for this action.${RESET}"; return 1; } || return 0 ;;
  esac

  read -p "Enter private key (0x-prefixed or 64-hex), or path to a .env file: " _input
  if [ -z "$_input" ]; then
    [ "$mode" = "required" ] && { echo -e "${RED}PRIVATE_KEY not provided.${RESET}"; return 1; } || return 0
  fi

  if [ -f "$_input" ]; then
    # Treat as env file path
    local pk
    pk=$(grep -E '^PRIVATE_KEY=' "$_input" | head -n1 | sed -E 's/^PRIVATE_KEY=//')
    if [ -z "$pk" ]; then
      echo -e "${RED}No PRIVATE_KEY entry found in $_input.${RESET}"
      [ "$mode" = "required" ] && return 1 || return 0
    fi
    export PRIVATE_KEY="$pk"
  else
    # Treat as raw key
    local re='^(0x)?[0-9a-fA-F]{64}$'
    if [[ ! $_input =~ $re ]]; then
      echo -e "${RED}Input does not look like a valid 64-hex private key.${RESET}"
      [ "$mode" = "required" ] && return 1 || return 0
    fi
    export PRIVATE_KEY="$_input"

    # Offer to persist to default env file
    read -p "Save PRIVATE_KEY to $(dirname "$env_file")/.env for future use? (y/n, b=back): " _save
    case "${_save,,}" in
      y|yes)
        mkdir -p "$(dirname "$env_file")"
        {
          # Remove existing PRIVATE_KEY entries to avoid duplicates
          if [ -f "$env_file" ]; then
            grep -v -E '^PRIVATE_KEY=' "$env_file" || true
          fi
          echo "PRIVATE_KEY=$PRIVATE_KEY"
        } > "${env_file}.tmp" && mv "${env_file}.tmp" "$env_file"
        chmod 600 "$env_file" 2>/dev/null || true
        echo -e "${GREEN}Saved to $env_file (permissions set to 600).${RESET}"
        ;;
      b|back) : ;;
      *) : ;;
    esac
  fi

  return 0
}

function delete_validator_node() {
    sudo systemctl stop $OG_CONSENSUS_CLIENT_SERVICE $OG_GETH_SERVICE
    sudo systemctl disable $OG_CONSENSUS_CLIENT_SERVICE $OG_GETH_SERVICE
    sudo rm -rf /etc/systemd/system/$OG_CONSENSUS_CLIENT_SERVICE $OG_GETH_SERVICE
    sudo rm -r $HOME/aristotle
    sudo rm -r $HOME/.0gchaind
    sudo rm -r $HOME/aristotle-v1.0.2
    sed -i "/OG_/d" $HOME/.bash_profile
    echo "Validator node deleted successfully."
    menu
}

function show_validator_logs() {
    echo "Displaying Consensus Client and Execution Client (Geth) Logs:"
    sudo journalctl -u $OG_CONSENSUS_CLIENT_SERVICE -u $OG_GETH_SERVICE -fn 100 --no-pager
    menu
}

function show_consensus_client_logs() {
    echo "Displaying Consensus Client Logs:"
    sudo journalctl -u $OG_CONSENSUS_CLIENT_SERVICE -fn 100
    menu
}

function show_geth_logs() {
    echo "Displaying Execution Client (Geth) Logs:"
    sudo journalctl -u $OG_GETH_SERVICE -fn 100
    menu
}

function show_node_status() {
    port=$(grep -oP 'laddr = "tcp://(0.0.0.0|127.0.0.1):\K[0-9]+57' "$HOME/.0gchaind/0g-home/0gchaind-home/config/config.toml") && curl "http://127.0.0.1:$port/status" | jq
    realtime_block_height=$(curl -s -X POST "https://evmrpc.0g.ai" -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq -r '.result' | xargs printf "%d\n")
    geth_block_height=$(0g-geth --exec "eth.blockNumber" attach $HOME/.0gchaind/0g-home/geth-home/geth.ipc)
    node_height=$(curl -s "http://127.0.0.1:$port/status" | jq -r '.result.sync_info.latest_block_height')
    echo "Consensus client block height: $node_height"
    echo "Execution client (0g-geth) block height: $geth_block_height"
    block_difference=$(( realtime_block_height - node_height ))
    echo "Real-time Block Height: $realtime_block_height"
    echo -e "${YELLOW}Block Difference:${NC} $block_difference"

    # Add explanation for negative values
    if (( block_difference < 0 )); then
        echo -e "${GREEN}Note:${NC} A negative value is normal - this means 0G Official's Mainnet RPC block height is currently behind your node's height"
    fi
    echo -e "\n${YELLOW}Press Enter to go back to main menu${RESET}"
    read -r
    menu
}

function stop_validator_node() {
    sudo systemctl stop $OG_CONSENSUS_CLIENT_SERVICE $OG_GETH_SERVICE
    menu
}

function restart_validator_node() {
    sudo systemctl daemon-reload
    sudo systemctl restart $OG_CONSENSUS_CLIENT_SERVICE $OG_GETH_SERVICE
    menu
}

# function backup_validator_key() {
#     cp $HOME/.0gchain/config/priv_validator_key.json $HOME/priv_validator_key.json
#     echo -e "\n${YELLOW}Your priv_vaidator_key.json file has been copied to $HOME${RESET}"
#     menu
# }

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
                sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.0gchaind/0g-home/0gchaind-home/config/config.toml
                echo "Peers added manually."
            else
                echo "Operation cancelled. Returning to menu."
                menu
            fi
            ;;
        2)
            peers=$(curl -sS https://lightnode-rpc-mainnet-0g.grandvalleys.com/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | paste -sd, -)
            echo "Grand Valley's peers: $peers"
            read -p "Do you want to proceed? (yes/no): " confirm
            if [[ $confirm == "yes" ]]; then
                sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"a97c8615903e795135066842e5739e30d64e2342@peer-0g.grandvalleys.com:28656,$peers\"|" $HOME/.0gchaind/0g-home/0gchaind-home/config/config.toml
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
    echo "Now you can restart your Validator Node"
    menu
}

# Storage Node Functions
function deploy_storage_node() {
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Mainnet-Guides/main/0g%20\(zero-gravity\)/resources/0g_storage_node_install.sh)
    menu
}

function update_storage_node() {
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Mainnet-Guides/main/0g%20\(zero-gravity\)/resources/0g_storage_node_update.sh)
    menu
}

function apply_storage_node_snapshot() {
    clear
    # Display critical information
    echo -e "\033[0;31m▓▒░ CRITICAL NOTICE:\033[0m"
    echo -e "\033[0;33m░ Snapshot contains: \033[0;32mflow_db (blockchain data)\033[0m"
    echo -e "\033[0;33m░ Not included:      \033[38;5;214mdata_db (mining storage)\033[0m"
    echo -e "\033[0;32m░ Your data_db will auto-create when node starts\033[0m"
    echo -e "\033[0;31m░ \033[38;5;214m⚠ SECURITY WARNING: \033[0;31mNever use pre-made data_db!\033[0m"
    echo -e "\033[0;31m░               It would mine for someone else's wallet!\033[0m"
    echo -e "\033[0;36mDocumentation: \033[0;34mhttps://docs.0g.ai/run-a-node/storage-node#snapshot\033[0m\n"

    # Get explicit confirmation
    read -p $'\033[0;36mDo you accept these conditions? (y/N): \033[0m' agree
    if [[ "${agree,,}" != "y" ]]; then
        echo -e "\033[0;31mOperation cancelled by user\033[0m"
        sleep 1
        menu
        return
    fi

    # Contract selection loop
    while true; do
        clear
        echo -e "\033[0;36m▓▒░ Storage Node Contract Type\033[0m"
        echo -e "\033[0;32m1) Standard Contract\033[0m   (Not Available)"
        echo -e "\033[0;33m2) Turbo Contract\033[0m     (Available)"
        echo -e "\033[0;31m3) Cancel & Return\033[0m"
        
        read -p $'\033[0;34mSelect option [1-3]: \033[0m' contract_choice

        case $contract_choice in
            1)
                echo -e "\033[0;33mStandard Contract snapshot not available."
                echo -e "Please monitor official channels for updates!\033[0m"
                sleep 2
                ;;
            2)
                echo -e "\n\033[0;31m▓▒░ IMPORTANT: Post-Snapshot Downtime Expected ░▒▓\033[0m"
                echo -e "\033[0;33mAfter applying the snapshot, your storage node will experience"
                echo -e "several hours of downtime while the data_db automatically syncs."
                echo -e "This is NORMAL BEHAVIOR - no action is needed!\033[0m\n"
                echo -e "The node will resume normal operations once sync completes."
                echo -e "\033[0;36mProgress can be monitored via node logs.\033[0m"
                sleep 3

                echo -e "\n\033[0;32mInitializing Standard Contract snapshot...\033[0m"
                echo -e "\033[0;33mThis may take several minutes...\033[0m"
                bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Mainnet-Guides/main/0g%20\(zero-gravity\)/resources/0g_turbo_zgs_node_snapshot.sh)

                echo -e "\n\033[0;32m▓▒░ Snapshot Applied Successfully ░▒▓\033[0m"
                echo -e "\033[0;33mYour node is now syncing data_db - this will take several hours"
                echo -e "\033[0;31mDO NOT RESTART OR INTERRUPT THIS PROCESS\033[0m"
                echo -e "\033[0;33mMonitor progress with: \033[0;36mshow_storage_logs\033[0m"
                echo -e "Concerned? Check logs before contacting support!"
                sleep 3
                menu
                break
                ;;
            3)
                echo -e "\033[0;31mOperation aborted by user\033[0m"
                sleep 1
                menu
                break
                ;;
            *)
                echo -e "\033[0;31mInvalid selection! Please choose 1, 2, or 3.\033[0m"
                sleep 1
                ;;
        esac
    done
}

function delete_storage_node() {
    sudo systemctl stop zgs
    sudo systemctl disable zgs
    sudo rm -rf /etc/systemd/system/zgs.service
    sudo rm -r $HOME/0g-storage-node
    echo "Storage node deleted successfully."
    menu
}

function change_storage_node() {
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Mainnet-Guides/main/0g%20\(zero-gravity\)/resources/0g_storage_node_change.sh)
    menu
}

function show_storage_logs() {
    clear
    LOG_FILE="$HOME/0g-storage-node/run/log/zgs.log.$(TZ=UTC date +%Y-%m-%d)"
    
    # Verify log file exists
    if [[ ! -f "$LOG_FILE" ]]; then
        echo -e "${RED}Error: Log file not found!${RESET}"
        echo -e "Verify node is running at: ${CYAN}$LOG_FILE${RESET}"
        sleep 2
        menu
        return
    fi

    # Show persistent instructions first
    echo -e "${CYAN}▓▒░ Storage Node Log Viewer ░▒▓${RESET}"
    echo -e "${YELLOW}┌────────────────────────────────────────────────────┐"
    echo -e "│ ${GREEN}Controls:${RESET}"
    echo -e "│ ${CYAN}Shift+F${RESET}                 - Auto-scroll new logs"
    echo -e "│ ${CYAN}Ctrl+C${RESET}                  - Pause auto-scroll"
    echo -e "│ ${CYAN}up arrow/down arrow${RESET}     - Scroll manually"
    echo -e "│ ${CYAN}/search${RESET}                 - Find text (n=next match)"
    echo -e "│ ${CYAN}Q${RESET}                       - Quit to menu"
    echo -e "└────────────────────────────────────────────────────┘${RESET}"
    
    # Wait for user confirmation
    read -n 1 -s -p $'\n\e[33mPress ANY KEY to view logs (Q to cancel): \e[0m' input
    echo ""
    
    if [[ "${input,,}" == "q" ]]; then
        echo -e "${GREEN}Operation cancelled. Returning to menu...${RESET}"
        sleep 1
        menu
        return
    fi

    # Show logs with instructions visible first
    echo -e "\n${CYAN}Loading logs...${RESET}"
    sleep 1  # Pause to see loading message
    less -R +F "$LOG_FILE"
    
    # Return to menu
    echo -e "\n${GREEN}Log viewing session closed. Returning to menu...${RESET}"
    sleep 1
    menu
}

function show_storage_status() {
    echo -e "${YELLOW}Storage Node Status:${RESET}"

    # Show Storage Node RPC Status
    curl -s -X POST http://localhost:5678 \
        -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","method":"zgs_getStatus","params":[],"id":1}' \
        | jq

    config_file=$(sudo systemctl cat zgs | grep ExecStart | sed -E 's/.*--config[= ]([^ ]+)/\1/')

    if [[ -f "$config_file" ]]; then
        # Show ZGS node version
        if [[ -x "$HOME/0g-storage-node/target/release/zgs_node" ]]; then
            zgs_version=$("$HOME/0g-storage-node/target/release/zgs_node" --version)
            echo -e "\nZGS Node Version: ${GREEN}$zgs_version${RESET}"
        else
            echo -e "\n${RED}ZGS node binary not found or not executable!${RESET}"
        fi

        # Get blockchain RPC endpoint
        rpc_endpoint=$(grep -E '^blockchain_rpc_endpoint' "$config_file" | sed -E 's/.*= *"([^"]+)"/\1/')
        echo -e "\nBlockchain RPC Endpoint: ${GREEN}$rpc_endpoint${RESET}"

        # Get miner contract address
        contract_address=$(grep -E '^mine_contract_address' "$config_file" | sed -E 's/.*= *"([^"]+)"/\1/')
        echo -e "Miner Contract Address: ${GREEN}$contract_address${RESET}"

        # Detect contract type
        if [[ "$contract_address" == "0x1785c8683b3c527618eFfF78d876d9dCB4b70285" ]]; then
            echo -e "Contract Type: ${CYAN}Standard Contract${RESET}"
        elif [[ "$contract_address" == "0xCd01c5Cd953971CE4C2c9bFb95610236a7F414fe" ]]; then
            echo -e "Contract Type: ${CYAN}Turbo Contract${RESET}"
        else
            echo -e "Contract Type: ${RED}Unknown Contract${RESET}"
        fi

        # Get PoRA Transactions - UPDATED SECTION
        log_file="$HOME/0g-storage-node/run/log/zgs.log.$(TZ=UTC date +%Y-%m-%d)"
        if [[ -f "$log_file" ]]; then
            hit_value=$(tail -n 100 "$log_file" | grep -oP 'hit: \K\d+' | tail -n1)
            if [[ -n "$hit_value" ]]; then
                echo -e "\nLatest PoRA TXs Count: ${GREEN}$hit_value${RESET}"
            else
                echo -e "\nLatest PoRA TXs Count: ${RED}No valid hits found in recent logs${RESET}"
            fi
        else
            echo -e "\nLatest PoRA TXs Count: ${RED}Log file not found${RESET}"
        fi
    else
        echo -e "\n${RED}Config file not found! Unable to determine contract or RPC info.${RESET}"
    fi

    echo -e "\n${YELLOW}Press Enter to go back to main menu${RESET}"
    read -r
    menu
}

function stop_storage_node() {
    sudo systemctl stop zgs
    menu
}

function restart_storage_node() {
    sudo systemctl daemon-reload
    sudo systemctl restart zgs
    menu
}

# Storage KV Functions
function deploy_storage_kv() {
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Mainnet-Guides/main/0g%20\(zero-gravity\)/resources/0g_storage_kv_install.sh)
    menu
}

function show_storage_kv_logs() {
    sudo journalctl -u zgskv -fn 100
    menu
}

function delete_storage_kv() {
    sudo systemctl stop zgskv
    sudo systemctl disable zgskv
    sudo rm -rf /etc/systemd/system/zgskv.service
    sudo rm -r $HOME/0g-storage-kv
    echo "Storage KV deleted successfully."
    menu
}

function update_storage_kv() {
    bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Mainnet-Guides/main/0g%20\(zero-gravity\)/resources/0g_storage_kv_update.sh)
    menu
}

function stop_storage_kv() {
    sudo systemctl stop zgskv
    menu
}

function restart_storage_kv() {
    sudo systemctl daemon-reload
    sudo systemctl restart zgskv
    menu
}

# AI Alignment Node Functions
function run_ai_alignment_node() {
     bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Mainnet-Guides/main/0g%20\(zero-gravity\)/resources/0g_ai_alignment_node_install.sh)
     menu
}

function show_ai_alignment_logs() {
    echo -e "${GREEN}Showing AI Alignment Node Logs...${RESET}"
    # Service name used by installer: 0g-alignment-node
    sudo journalctl -u 0g-alignment-node -fn 100 --no-pager
    menu
}

function stop_ai_alignment_node() {
    sudo systemctl stop 0g-alignment-node
    menu
}

function delete_ai_alignment_node() {
    sudo systemctl stop 0g-alignment-node
    sudo systemctl disable 0g-alignment-node
    sudo rm -rf /etc/systemd/system/0g-alignment-node.service
    sudo rm -r $HOME/0g-alignment-node
    echo "AI Alignment Node deleted successfully."
    menu
}

function restart_ai_alignment_node() {
    sudo systemctl daemon-reload
    sudo systemctl restart 0g-alignment-node
    menu
}

# Approve AI Alignment Node delegations (bulk token-ids)
function approve_ai_alignment_node() {
    local APP_DIR="$HOME/0g-alignment-node"
    local BIN_PATH="$APP_DIR/0g-alignment-node"

    if [ ! -x "$BIN_PATH" ]; then
        echo -e "${YELLOW}Alignment node binary not found at ${BIN_PATH}.${RESET}"
        echo -e "Install it first via: Run AI Alignment Node option."
        read -p "Press Enter to go back..." _
        menu
        return
    fi

    if [ -f "$APP_DIR/.env" ]; then
        source "$APP_DIR/.env"
        DEFAULT_KEY="$ZG_ALIGNMENT_NODE_SERVICE_PRIVATEKEY"
    fi

    read -p "Enter private key (no 0x). Leave blank to use .env: " INPUT_KEY
    if [ -z "$INPUT_KEY" ]; then
        INPUT_KEY="$DEFAULT_KEY"
    fi
    if [ -z "$INPUT_KEY" ]; then
        echo -e "${RED}Private key is required.${RESET}"
        return
    fi

    read -p "Enter comma-separated NFT token IDs to approve: (e.g: ID1,ID2,ID3,....)" TOKEN_IDS
    if [ -z "$TOKEN_IDS" ]; then
        echo -e "${RED}At least one token id is required.${RESET}"
        return
    fi

    read -p "RPC endpoint [default https://arb1.arbitrum.io/rpc]: " RPC
    RPC=${RPC:-https://arb1.arbitrum.io/rpc}
    read -p "Commission [default 10]: " COMMISSION
    COMMISSION=${COMMISSION:-10}
    CHAIN_ID=42161

    echo -e "${GREEN}Executing approval command...${RESET}"
    (cd "$APP_DIR" && ./"$(basename "$BIN_PATH")" registerOperator \
        --key "$INPUT_KEY" \
        --token-id "$TOKEN_IDS" \
        --commission "$COMMISSION" \
        --chain-id "$CHAIN_ID" \
        --rpc "$RPC" \
        --contract 0xdD158B8A76566bC0c342893568e8fd3F08A9dAac \
        --mainnet)

    echo -e "${GREEN}Approval tx submitted. Verify on-chain explorers.${RESET}"
    read -p "Press Enter to return to menu..." _
    menu
}

# Show Grand Valley's Endpoints
function show_endpoints() {
    echo -e "$ENDPOINTS"
    echo -e "\n${YELLOW}Press Enter to go back to main menu${RESET}"
    read -r
    menu
}

function show_guidelines() {
    echo -e "${CYAN}Guidelines on How to Use the Valley of 0G${RESET}"
    echo -e "${YELLOW}This tool is designed to help you manage your 0G nodes. Below are the guidelines on how to use it effectively:${RESET}"
    
    echo -e "${GREEN}1. Navigating the Menu${RESET}"
    echo "   - The menu is divided into several sections: Validator Node, Storage Node, Storage KV, Node Management, and Utilities."
    echo "   - To select an option, you can either:"
    echo "     a. Enter the corresponding number followed by the letter (e.g., 1a for Deploy Validator Node)."
    echo "     b. Enter the number, press Enter, and then enter the letter (e.g., 1 then a)."

    echo -e "${GREEN}2. Entering Choices${RESET}"
    echo "   - For any prompt that has choices, you only need to enter the number (1, 2, 3, etc.) or the letter (a, b, c, etc.)."
    echo "   - For y/n prompts, enter 'y' for yes and 'n' for no."
    echo "   - For yes/no prompts, enter 'yes' for yes and 'no' for no."

    echo -e "${GREEN}3. Running Commands${RESET}"
    echo "   - After selecting an option, the script will execute the corresponding commands."
    echo "   - Ensure you have the necessary permissions and dependencies installed for the commands to run successfully."

    echo -e "${GREEN}4. Exiting the Script${RESET}"
    echo "   - To exit the script, select option 9 from the main menu."
    echo "   - Remember to run 'source ~/.bash_profile' after exiting to apply any changes made to environment variables."

    echo -e "${GREEN}5. Additional Tips${RESET}"
    echo "   - Always backup your wallets and important data before performing operations like deleting nodes."
    echo "   - Regularly update your nodes to the latest version (currently v1.0.2) to ensure compatibility and security."

    echo -e "${GREEN}6. Option Descriptions and Guides${RESET}"
    echo -e "${GREEN}Validator Node Options:${RESET}"
    echo "   a. Deploy/re-Deploy Validator Node: Sets up a new validator node or redeploys an existing one (v1.0.2)."
    echo "      - Guide: This will install all necessary components. Ensure your system meets requirements."
    echo "   b. Manage Validator Node: Update validator node version (v1.0.2) or return to menu."
    echo "   c. Add Peers: Manually add peers or use Grand Valley's peers."
    echo "      - Guide: Improves node connectivity and network participation."
    echo "   d. Show Node Status: Displays your validator's current status and health."
    echo "   e. Show Validator Logs: Views the validator's operational logs."
    echo "   f. Query Balance: Checks the balance of an EVM address."

    echo -e "${GREEN}Storage Node Options:${RESET}"
    echo "   a. Deploy Storage Node: Sets up a new storage node."
    echo "   b. Update Storage Node: Upgrades to the latest storage node version."
    echo "   c. Apply Storage Node Snapshot: Applies official snapshot for faster sync"
    echo -e "      - ${YELLOW}Important:${RESET} Always generate your own data_db - using others' will make you mine for them!"
    echo -e "      - Official docs: ${BLUE}https://docs.0g.ai/run-a-node/storage-node#snapshot${RESET}"
    echo "   d. Change Storage Node: Modifies storage node configuration."
    echo "   e. Show Storage Node Logs: Views storage node operational logs."
    echo "   f. Show Storage Node Status: Checks storage node health."

    echo -e "${GREEN}Storage KV Options:${RESET}"
    echo "   a. Deploy Storage KV: Sets up a key-value storage node."
    echo "   b. Show Storage KV Logs: Views KV node operational logs."
    echo "   c. Update Storage KV: Upgrades the KV node version."
 
    echo -e "${GREEN}AI Alignment Node Options:${RESET}"
    echo "   a. Run AI Alignment Node: Starts the AI Alignment Node process (experimental)."
    echo "      - Note: This is an optional experimental component to manage AI alignment tasks."
    echo "   b. Show AI Alignment Node Logs: Display AI Alignment Node logs (journalctl or logfile)."
    echo ""
 
    echo -e "${GREEN}Node Management:${RESET}"
    echo "   a. Restart Validator Node: Gracefully restarts validator."
    echo "   b. Restart Storage Node: Gracefully restarts storage node."
    echo "   c. Restart Storage KV: Gracefully restarts KV node."
    echo "   d. Stop Validator Node: Safely stops validator operations."
    echo "   e. Stop Storage Node: Safely stops storage operations."
    echo "   f. Stop Storage KV: Safely stops KV operations."
    echo "   g. Delete Validator Node: Removes validator (BACKUP WALLET & PRIV_KEYS FIRST!)."
    echo "   h. Delete Storage Node: Removes storage node."
    echo "   i. Delete Storage KV: Removes KV node."
 
    echo -e "${GREEN}Utilities:${RESET}"
    echo "   6. Install 0gchain App: Installs CLI (v1.0.2) for transactions without running a node."
    echo "   7. Show Endpoints: Displays Grand Valley's public endpoints."
    echo "   8. Show Guidelines: Displays this help information."
 
    echo -e "\n${YELLOW}Press Enter to go back to main menu${RESET}"
    read -r
    menu
}

# Menu function
function menu() {
    detect_geth_service_file
    realtime_block_height=$(curl -s -X POST "https://evmrpc.0g.ai" -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq -r '.result' | xargs printf "%d\n")
    echo -e "${ORANGE}Valley of 0G Mainnet${RESET}"
    echo "Main Menu:"
    echo -e "${GREEN}1. Validator Node${RESET}"
    echo "    a. Deploy/re-Deploy Validator Node"
    echo "    b. Manage Validator Node"
    echo "    c. Apply Validator Node Snapshot"
    echo "    d. Add Peers"
    echo "    e. Show Node Status"
    echo "    f. Show Validator Node Logs (Consensus + Geth)"
    echo "    g. Show Consensus Client Logs"
    echo "    h. Show Geth Logs"
    echo "    i. Query Balance"
    echo "    j. Create Validator"
    echo "    k. Delegate to Validator"
    echo "    l. Undelegate from Validator"
    echo -e "${GREEN}2. Storage Node${RESET}"
    echo "    a. Deploy Storage Node"
    echo "    b. Update Storage Node"
    echo "    c. Apply Storage Node Snapshot (Updated every 03.00 UTC)"
    echo "    d. Change Storage Node"
    echo "    e. Show Storage Node Logs"
    echo "    f. Show Storage Node Status"
    echo -e "${GREEN}3. Storage KV${RESET}"
    echo "    a. Deploy Storage KV"
    echo "    b. Show Storage KV Logs"
    echo "    c. Update Storage KV"
    echo -e "${GREEN}4. AI Alignment Node${RESET}"
    echo "    a. Run AI Alignment Node"
    echo "    b. Show AI Alignment Node Logs"
    echo "    c. Approve AI Alignment Delegations (bulk registerOperator)"
    echo -e "${GREEN}5. Node Management:${RESET}"
    echo "    a. Restart Validator Node"
    echo "    b. Restart Storage Node"
    echo "    c. Restart Storage KV"
    echo "    d. Restart AI Alignment Node"
    echo "    e. Stop Validator Node"
    echo "    f. Stop Storage Node"
    echo "    g. Stop Storage KV"
    echo "    h. Stop AI Alignment Node"
    echo "    i. Delete Validator Node (BACKUP YOUR SEEDS PHRASE/EVM-PRIVATE KEY AND priv_validator_key.json BEFORE YOU DO THIS)"
    echo "    j. Delete Storage Node"
    echo "    k. Delete Storage KV"
    echo "    l. Delete AI Alignment Node"
    echo -e "${GREEN}6. Install the 0gchain App (v1.0.2) only to execute transactions without running a node${RESET}"
    echo -e "${GREEN}7. Show Grand Valley's Endpoints${RESET}"
    echo -e "${YELLOW}8. Show Guidelines${RESET}"
    echo -e "${RED}9. Exit${RESET}"

    echo -e "Latest Block Height: ${GREEN}$realtime_block_height${RESET}"
    echo -e "\n${YELLOW}Please run the following command to apply the changes after exiting the script:${RESET}"
    echo -e "${GREEN}source ~/.bash_profile${RESET}"
    echo -e "${YELLOW}This ensures the environment variables are set in your current bash session.${RESET}"
    echo -e "Stake your 0G with Grand Valley: ${ORANGE}https://explorer.0g.ai/mainnet/validators/0x108e619da0cdba8a301a53948a4acc23a3d79377/delegators${RESET}"
    echo -e "${GREEN}Let's Buidl 0G Together - Grand Valley${RESET}"
    read -p "Choose an option (e.g., 1a or 1 then a): " OPTION

    # Accept combined selections up to 9 and sub-letters up to 'l' (for Node Management extended sub-options)
    if [[ $OPTION =~ ^[1-9][a-m]$ ]]; then
        MAIN_OPTION=${OPTION:0:1}
        SUB_OPTION=${OPTION:1:1}
    else
        MAIN_OPTION=$OPTION
        # If the selected main option is one that has sub-options (1..5), prompt for sub-option
        if [[ $MAIN_OPTION =~ ^[1-5]$ ]]; then
            read -p "Choose a sub-option: " SUB_OPTION
        fi
    fi

    case $MAIN_OPTION in
        1)
            case $SUB_OPTION in
                a) deploy_validator_node ;;
                b) manage_validator_node ;;
                c) apply_snapshot ;;
                d) add_peers ;;
                e) show_node_status ;;
                f) show_validator_logs ;;
                g) show_consensus_client_logs ;;
                h) show_geth_logs ;;
                i) query_balance ;;
                j) create_validator ;;
                k) delegate_to_validator ;;
                l) undelegate_from_validator ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        2)
            case $SUB_OPTION in
                a) deploy_storage_node ;;
                b) update_storage_node ;;
                c) apply_storage_node_snapshot ;;
                d) change_storage_node ;;
                e) show_storage_logs ;;
                f) show_storage_status ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        3)
            case $SUB_OPTION in
                a) deploy_storage_kv ;;
                b) show_storage_kv_logs ;;
                c) update_storage_kv ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        4)
            case $SUB_OPTION in
                a) run_ai_alignment_node ;;
                b) show_ai_alignment_logs ;;
                c) approve_ai_alignment_node ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        5)
            case $SUB_OPTION in
                a) restart_validator_node ;;
                b) restart_storage_node ;;
                c) restart_storage_kv ;;
                d) restart_ai_alignment_node ;;
                e) stop_validator_node ;;
                f) stop_storage_node ;;
                g) stop_storage_kv ;;
                h) stop_ai_alignment_node ;;
                i) delete_validator_node ;;
                j) delete_storage_node ;;
                k) delete_storage_kv ;;
                l) delete_ai_alignment_node ;;
                *) echo "Invalid sub-option. Please try again." ;;
            esac
            ;;
        6) install_0gchain_app ;;
        7) show_endpoints ;;
        8) show_guidelines ;;
        9) exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
}

# Start menu
menu
