#!/bin/bash

# Define color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# Function to display the simplified explanation of Cubic Slashing
display_explanation() {
    echo ""
    echo -e "${GREEN}--------------------------------------------${RESET}"
    echo -e "${BLUE}Purpose of This Tool:${RESET}"
    echo -e "${GREEN}--------------------------------------------${RESET}"
    echo -e "${WHITE}This tool helps stakers understand Namada's unique ${YELLOW}Cubic Slashing${RESET} system, which penalizes validators based on their ${YELLOW}voting power.${RESET}"
    echo -e "${WHITE}It helps you assess ${YELLOW}risks${RESET}, ${GREEN}rewards${RESET}, and encourages ${WHITE}decentralized staking${RESET} by spreading your stake across smaller validators.${RESET}"
    echo -e "${GREEN}--------------------------------------------${RESET}"
    echo ""

    echo -e "${GREEN}------------------------------------${RESET}"
    echo -e "${BLUE}How Does Namada Slashing Work?${RESET}"
    echo -e "${GREEN}------------------------------------${RESET}"
    echo -e "${WHITE}1. Think of ${RED}slashing${RESET} as a penalty: the more ${MAGENTA}marbles (stake)${RESET} a validator controls, the harsher the penalty if they misbehave.${RESET}"
    echo -e "${WHITE}2. When misbehavior happens, the validator is ${WHITE}frozen${RESET} – no one can withdraw their ${MAGENTA}marbles${RESET} until it's resolved.${RESET}"
    echo -e "${WHITE}3. The penalty ${RED}increases${RESET} if the validator controls more ${MAGENTA}marbles${RESET}, encouraging ${RED}fair play${RESET}.${RESET}"
    echo -e "${WHITE}4. The penalty is ${WHITE}delayed${RESET}, giving others time to ${YELLOW}react${RESET} and protect their stake.${RESET}"
    echo -e "${WHITE}5. Validators can ${WHITE}return${RESET} after proving they’re ready to follow the ${RED}rules${RESET} again.${RESET}"
    echo -e "${GREEN}------------------------------------${RESET}"
    echo ""

    echo -e "${GREEN}------------------------------------${RESET}"
    echo -e "${BLUE}Why Stake with Small Validators?${RESET}"
    echo -e "${GREEN}------------------------------------${RESET}"
    echo -e "${WHITE}1. Think of a ${MAGENTA}big jar${RESET}: if it falls, everyone loses more. Spread your stake across ${MAGENTA}many jars${RESET} (smaller validators).${RESET}"
    echo -e "${WHITE}2. Spreading your ${MAGENTA}marbles${RESET} across ${MAGENTA}jars${RESET} protects your ${YELLOW}investment${RESET} and strengthens the ${WHITE}network${RESET}.${RESET}"
    echo -e "${WHITE}3. ${WHITE}Decentralization${RESET} keeps the ${WHITE}network${RESET} secure and balanced.${RESET}"
    echo -e "${WHITE}4. Supporting smaller validators like ${WHITE}Grand Valley${RESET} promotes ${WHITE}stability${RESET} for Namada ${GREEN}(tnam1qyplu8gruqmmvwp7x7kd92m6x4xpyce265fa05r6)${RESET}"
    echo -e "${WHITE}5. Don’t put all your ${MAGENTA}marbles${RESET} in one ${MAGENTA}jar${RESET} – spread them for ${YELLOW}safety${RESET}!${RESET}"
    echo -e "${GREEN}------------------------------------${RESET}"

    echo -e "${GREEN}Let's Build Namada Together, Let's Shield Together. - Grand Valley${RESET}"
    echo ""
}

# Function to install dependencies
install_dependencies() {
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}curl is not installed. Installing...${RESET}"
        sudo apt-get update && sudo apt-get install -y curl
    fi

    if ! command -v jq &> /dev/null; then
        echo -e "${RED}jq is not installed. Installing...${RESET}"
        sudo apt-get update && sudo apt-get install -y jq
    fi
}

# Main menu function
main_menu() {
    while true; do
        clear
        echo -e "${CYAN}Welcome to Namada CSR Monitoring Tool by Grand Valley${RESET}"
        display_explanation
        echo -e "${GREEN}Main menu:${RESET}"
        echo -e "1. Monitor CSR"
        echo -e "2. Back to the Valley of Namada Main Menu"
        read -p "Select an option: " choice

        case $choice in
            1) monitor_csr;;
            2) echo -e "${GREEN}Exiting...${RESET}"; exit 0;;
            *) echo -e "${RED}Invalid option. Try again.${RESET}"; sleep 1;;
        esac
    done
}

# Monitor CSR function
monitor_csr() {
    local current_page=1
    local items_per_page=20  # Changed to 20

    while true; do
        clear

        # Fetch total voting power
        total_voting_power=$(curl -s 'https://indexer-mainnet-namada.grandvalleys.com/api/v1/pos/voting-power' | jq -r '.totalVotingPower')

        # Fetch validator data
        validator_data=$(curl -s 'https://indexer-mainnet-namada.grandvalleys.com/api/v1/pos/validator/all?state=consensus' | jq -r '.[] | "\(.name) \(.votingPower)"')
        sorted_validators=$(echo "$validator_data" | awk '{print $NF, $0}' | sort -nr | cut -d' ' -f2-)

        # Create an array of validators
        IFS=$'\n' read -r -d '' -a validators <<< "$sorted_validators"
        total_validators=${#validators[@]}
        total_pages=$(( (total_validators + items_per_page - 1) / items_per_page ))

        # Display page data
        start_index=$(( (current_page - 1) * items_per_page ))
        end_index=$(( start_index + items_per_page - 1 ))
        [ $end_index -ge $total_validators ] && end_index=$(( total_validators - 1 ))

        echo -e "${CYAN}Page $current_page/$total_pages${RESET}"
        echo -e "${GREEN}No | Validator Name                 | Voting Power (NAM) (vp/tvp) | Independent CSR (%)${RESET}"
        echo "-------------------------------------------------------------------"

        for i in $(seq $start_index $end_index); do
            name=$(echo "${validators[$i]}" | rev | cut -d' ' -f2- | rev)
            voting_power=$(echo "${validators[$i]}" | awk '{print $NF}')

            # Calculate fractional voting power and CSR
            fractional_voting_power=$(echo "scale=10; $voting_power / $total_voting_power" | bc)
            fractional_voting_power_percentage=$(echo "$fractional_voting_power * 100" | bc -l | awk '{printf "%.2f", $1}')
            cubic_slash_rate=$(echo "scale=10; 9 * ($fractional_voting_power ^ 2)" | bc)
            cubic_slash_rate=$(echo "scale=2; if ($cubic_slash_rate < 0.01) 0.01 else if ($cubic_slash_rate > 1.0) 1.0 else $cubic_slash_rate" | bc)
            cubic_slash_rate_percentage=$(echo "$cubic_slash_rate * 100" | bc -l | awk '{printf "%.2f", $1}')

            printf "%2d | %-30s | %-18s ($fractional_voting_power_percentage%%) | %s\n" $((i + 1)) "$name" "$voting_power" "$cubic_slash_rate_percentage"
        done

        echo -e "${GREEN}--------------------------------------------${RESET}"
        echo -e "${BLUE}Simulate Infractions Feature:${RESET}"
        echo -e "${GREEN}--------------------------------------------${RESET}"
        echo -e "${YELLOW}Simulate Infractions${RESET} lets you estimate the impact of validator infractions on their ${YELLOW}Cubic Slashing Rate${RESET} (CSR). Input the number of infractions and see how they affect the CSR.${RESET}"
        echo -e "${WHITE}This feature helps with ${YELLOW}risk management${RESET} by showing how misbehaviors might influence your staking strategy in the Namada ecosystem.${RESET}"
        echo -e "${GREEN}--------------------------------------------${RESET}"
        echo -e "${CYAN}Notes:${RESET}"
        echo -e "${YELLOW}Independent CSR:${RESET} The Independent CSR estimates the slashing rate for a validator assuming it is the only one misbehaving within a 3-epoch window (epochs -1, 0, +1). It increases with the validator’s voting power, so larger validators face higher penalties, enhancing network security."
        echo ""
        echo -e "${YELLOW}Example of Independet CSR:${RESET} A validator with 10% of TVP could face, minimally, 9% slashing of staked tokens. For a validator with 1000 tokens, 90 could be slashed, assuming it is the only validator with an infraction during the 3-epoch window."
        echo ""
        echo -e "Commands: [${GREEN}n${RESET}] Next Page, [${GREEN}p${RESET}] Previous Page, [${GREEN}s${RESET}] Simulate Infractions, [${GREEN}j${RESET}] Jump to Page, [${GREEN}q${RESET}] Quit"
        read -p "Enter command: " command

        case $command in
            n) [ $current_page -lt $total_pages ] && current_page=$((current_page + 1)) || echo -e "${RED}Last page reached.${RESET}";;
            p) [ $current_page -gt 1 ] && current_page=$((current_page - 1)) || echo -e "${RED}First page reached.${RESET}";;
            s) simulate_infractions;;
            q) return;;
            *) echo -e "${RED}Invalid command.${RESET}"; sleep 1;;
        esac
    done
}

# Simulate infractions function
simulate_infractions() {
    local total_fraction=0
    declare -A validator_data
    declare -A infractions_data

    while true; do
        read -p "Enter validator name (or 'done' to finish): " validator_name
        [ "$validator_name" == "done" ] && break

        read -p "Enter infractions for epoch -1: " inf1
        read -p "Enter infractions for epoch 0: " inf2
        read -p "Enter infractions for epoch +1: " inf3

        total_infractions=$((inf1 + inf2 + inf3))

        # Fetch validator voting power
        vp=$(curl -s "https://indexer-mainnet-namada.grandvalleys.com/api/v1/pos/validator/all?state=consensus" | jq -r --arg name "$validator_name" '.[] | select(.name == $name) | .votingPower')
        [ -z "$vp" ] && echo -e "${RED}Validator not found. Try again.${RESET}" && continue

        fraction=$(echo "scale=10; $vp / $total_voting_power * $total_infractions" | bc)
        total_fraction=$(echo "scale=10; $total_fraction + $fraction" | bc)

        validator_data[$validator_name]="$vp"
        infractions_data[$validator_name]="$total_infractions"
    done

    # Calculate CSR
    csr=$(echo "scale=10; 9 * ($total_fraction ^ 2)" | bc)
    csr=$(echo "scale=2; if ($csr < 0.01) 0.01 else if ($csr > 1.0) 1.0 else $csr" | bc)
    csr_percentage=$(echo "$csr * 100" | bc -l | awk '{printf "%.2f", $1}')

    echo -e "\n${CYAN}Simulation Results:${RESET}"
    echo -e "CSR: ${YELLOW}$csr_percentage%${RESET}"

    for name in "${!validator_data[@]}"; do
        vp=${validator_data[$name]}
        infractions=${infractions_data[$name]}
        if [ $infractions -eq 0 ]; then
            slash_amount=0
        else
            slash_amount=$(echo "scale=2; $csr * $vp" | bc)
        fi
        echo -e "Validator: ${BLUE}$name${RESET}, Slashed Amount: ${RED}$slash_amount NAM${RESET}"
    done

    echo -e "\n${GREEN}Diversify your delegations to minimize risk and support smaller validators!${RESET}"
    echo -e "\n${CYAN}Conclusion:${RESET}"

    if [ ${#validator_data[@]} -eq 1 ]; then
        for name in "${!validator_data[@]}"; do
            infractions=${infractions_data[$name]}
            echo -e "If ${BLUE}$name${RESET} did ${YELLOW}$infractions${RESET} infractions in one window width (3 epochs), the CSR would be ${YELLOW}$csr_percentage%${RESET}. This highlights the importance of monitoring validator behavior and the potential impact of misbehavior on your stake."
        done
    else
        echo -e "If the validators did the following infractions in one window width (3 epochs), the CSR would be ${YELLOW}$csr_percentage%${RESET}:"
        for name in "${!validator_data[@]}"; do
            infractions=${infractions_data[$name]}
            echo -e "Validator: ${BLUE}$name${RESET}, Infractions: ${YELLOW}$infractions${RESET}"
        done
        echo -e "This emphasizes the cumulative impact of multiple validators misbehaving and the importance of decentralization and diversification in staking."
    fi

    read -p "Press Enter to return to the Monitor CSR menu..."
    monitor_csr
}

# Ensure dependencies are installed
install_dependencies

# Start the script
main_menu
