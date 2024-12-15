#!/bin/bash

# Define color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# Function to check and install dependencies
install_dependencies() {
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}curl could not be found. Installing curl...${RESET}"
        sudo apt-get update
        sudo apt-get install -y curl
    fi

    if ! command -v jq &> /dev/null; then
        echo -e "${RED}jq could not be found. Installing jq...${RESET}"
        sudo apt-get update
        sudo apt-get install -y jq
    fi
}

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

    echo ""
    echo -e "${GREEN}Let's Buidl Namada Together, Let's Shiedl Together. - Grand Valley${RESET}"
    echo ""
}

# Function to calculate the cubic slash rate
calc_cubic_slash_rate() {
    local window_width=$1
    local validator_voting_power=$2
    local total_voting_power=$3
    local fractional_voting_power
    local sum_fractional_voting_power
    local cubic_slash_rate

    # Validate inputs
    if [[ -z "$window_width" || -z "$validator_voting_power" || -z "$total_voting_power" || "$total_voting_power" -le 0 ]]; then
        echo -e "${RED}Error: Invalid inputs${RESET}"
        return 1
    fi

    # Calculate the fractional voting power of the validator
    fractional_voting_power=$(echo "scale=10; $validator_voting_power / $total_voting_power" | bc)

    # Sum fractional voting power across the window
    sum_fractional_voting_power=$(echo "scale=10; $fractional_voting_power * (2 * $window_width + 1)" | bc)

    # Calculate the cubic slash rate
    cubic_slash_rate=$(echo "scale=10; 9 * ($sum_fractional_voting_power ^ 2)" | bc)

    # Clamp the slash rate to the range [0.01, 1.0]
    cubic_slash_rate=$(echo "scale=2; if ($cubic_slash_rate < 0.01) 0.01 else if ($cubic_slash_rate > 1.0) 1.0 else $cubic_slash_rate" | bc)

    # Return the cubic slash rate
    echo $cubic_slash_rate
}

# Function to fetch, sort, and display data with pagination
fetch_and_display_paginated_data() {
    # Fetch total voting power
    total_voting_power=$(curl -s -X 'GET' \
      'https://indexer-mainnet-namada.grandvalleys.com/api/v1/pos/voting-power' \
      -H 'accept: application/json' | jq -r '.totalVotingPower')

    # Fetch validator data
    validators=$(curl -s -X 'GET' \
      'https://indexer-mainnet-namada.grandvalleys.com/api/v1/pos/validator/all?state=consensus' \
      -H 'accept: application/json' | jq -r '.[] | "\(.name) \(.votingPower)"')

    # Sort the validators based on the numerical value using awk
    sorted_validators=$(echo "$validators" | awk '{print $NF, $0}' | sort -nr | cut -d' ' -f2-)

    # Convert sorted data to an array
    IFS=$'\n' read -d '' -r -a validator_array <<< "$sorted_validators"
    total_validators=${#validator_array[@]}

    # Initialize pagination variables
    items_per_page=25
    current_page=1
    total_pages=$(( (total_validators + items_per_page - 1) / items_per_page ))

    while true; do
        clear
        echo -e "${GREEN}Total Voting Power: $total_voting_power NAM${RESET}"
        echo -e "${GREEN}Page $current_page of $total_pages${RESET}"
        echo ""
        echo -e "${BLUE}Validator Name                      | Voting Power (NAM) | Voting Power (%) | CSR (NAM)       | CSR (%)${RESET}"
        echo "-----------------------------------------------------------------------------------------------------"

        # Calculate start and end indices for the current page
        start_index=$(( (current_page - 1) * items_per_page ))
        end_index=$(( start_index + items_per_page - 1 ))
        if [ $end_index -ge $total_validators ]; then
            end_index=$(( total_validators - 1 ))
        fi

        # Display validators for the current page
        for i in $(seq $start_index $end_index); do
            data="${validator_array[$i]}"
            name=$(echo "$data" | rev | cut -d' ' -f2- | rev)
            voting_power=$(echo "$data" | awk '{print $NF}')

            # Skip invalid voting power entries
            if [[ ! "$voting_power" =~ ^[0-9]+$ ]]; then
                continue
            fi

            # Calculate fractional voting power and CSR
            window_width=1  # Default window width
            cubic_slash_rate=$(calc_cubic_slash_rate $window_width $voting_power $total_voting_power)
            cubic_slash_rate_percentage=$(echo "$cubic_slash_rate * 100" | bc -l | awk '{printf "%.2f", $1}')
            cubic_slash_rate_nam=$(echo "$cubic_slash_rate * $voting_power" | bc -l | awk '{printf "%.2f", $1}')
            voting_power_percentage=$(echo "$voting_power / $total_voting_power * 100" | bc -l | awk '{printf "%.2f", $1}')

            # Display compact validator data with adjusted column width
            printf "%-35s | %-17s | %-16s | %-17s | %-8s\n" "$name" "$voting_power NAM" "$voting_power_percentage%" "$cubic_slash_rate_nam NAM" "$cubic_slash_rate_percentage%"
        done

        echo "-----------------------------------------------------------------------------------------------------"
        echo "Notes:"
        echo ""
        echo -e "\e[33mCSR Growth with Voting Power (VP):\e[0m The CSR grows proportionally with the validator's voting power, ensuring larger validators face higher penalties for misbehavior, thereby enhancing network security and resilience."
        echo ""
        echo -e "\e[33mFor example, a validator with a CSR of 50%\e[0m will lose 50% of its staked tokens as a penalty, indicating more serious misbehavior (e.g., losing 500 out of 1000 tokens)."
        echo ""
        echo -e "Commands: [\e[32mn\e[0m] Next Page, [\e[32mp\e[0m] Previous Page, [\e[32mq\e[0m] Quit, [\e[32mj\e[0m] Jump to Page, [\e[32mb\e[0m] Back to Main Menu"
        read -p "Enter command: " command

        case $command in
            n)
                if [ $current_page -lt $total_pages ]; then
                    current_page=$((current_page + 1))
                else
                    echo -e "${RED}You are already on the last page.${RESET}"
                    sleep 1
                fi
                ;;
            p)
                if [ $current_page -gt 1 ]; then
                    current_page=$((current_page - 1))
                else
                    echo -e "${RED}You are already on the first page.${RESET}"
                    sleep 1
                fi
                ;;
            j)
                read -p "Enter the page number to jump to: " jump_page
                if [[ $jump_page -ge 1 && $jump_page -le $total_pages ]]; then
                    current_page=$jump_page
                else
                    echo -e "${RED}Invalid page number. Please enter a valid page number.${RESET}"
                    sleep 1
                fi
                ;;
            q)
                echo -e "${GREEN}Exiting pagination...${RESET}"
                break
                ;;
            b)
                echo -e "${GREEN}Returning to the main menu...${RESET}"
                return
                ;;
            *)
                echo -e "${RED}Invalid command! Use [n], [p], [q], [j], or [b].${RESET}"
                sleep 1
                ;;
        esac
    done
}

# Manual calculation function
manual_calculation() {
    echo -e "${GREEN}Enter the Voting Power (NAM):${RESET}"
    read voting_power
    total_voting_power=$(curl -s -X 'GET' \
      'https://indexer-mainnet-namada.grandvalleys.com/api/v1/pos/voting-power' \
      -H 'accept: application/json' | jq -r '.totalVotingPower')
    echo -e "${GREEN}Enter Total Voting Power (NAM) (Current: $total_voting_power, leave empty to use current):${RESET}"
    read user_input
    # If the user input is empty, use the current total voting power
    total_voting_power="${user_input:-$total_voting_power}"
    echo -e "${GREEN}Using Total Voting Power: $total_voting_power${RESET}"
    echo -e "${GREEN}Enter the Window Width (default: 1, leave empty to use default):${RESET}"
    read window_width
    # If the user input is empty, use the default value of 1
    window_width="${window_width:-1}"
    echo -e "${GREEN}Using Window Width: $window_width${RESET}"

    # Calculate the cubic slash rate
    cubic_slash_rate=$(calc_cubic_slash_rate $window_width $voting_power $total_voting_power)

    # Convert Cubic Slashing Rate to percentage
    cubic_slash_rate_percentage=$(echo "$cubic_slash_rate * 100" | bc -l | awk '{printf "%.2f", $1}')

    # Calculate the Cubic Slashing Rate in NAM
    cubic_slash_rate_nam=$(echo "$cubic_slash_rate * $voting_power" | bc -l | awk '{printf "%.2f", $1}')

    # Calculate the Voting Power Percentage
    voting_power_percentage=$(echo "$voting_power / $total_voting_power * 100" | bc -l | awk '{printf "%.2f", $1}')

    # Display the result in a compact format
    echo ""
    echo -e "${GREEN}Manual CSR Calculation${RESET}"
    echo -e "${GREEN}-----------------------------${RESET}"
    printf "%-20s | %-17s | %-16s | %-17s | %-7s\n" "Voting Power (NAM)" "Voting Power (%)" "CSR (NAM)" "CSR (%)"
    echo "-------------------------------------------------------------------------------------"
    printf "%-20s | %-17s | %-16s | %-17s | %-7s\n" "$voting_power NAM" "$voting_power_percentage%" "$cubic_slash_rate_nam NAM" "$cubic_slash_rate_percentage%"
    echo "-------------------------------------------------------------------------------------"
    echo ""
}

# Main menu for the user to select
while true; do
    clear
    echo -e "${CYAN}Welcome to Cubic Slashing Rate Monitoring Tool by Grand Valley${RESET}"
    display_explanation
    echo "Choose an option:"
    echo "1. View All Validators' CSR (Paginated, Descending by Voting Power)"
    echo "2. Manual CSR Calculation"
    echo "3. Back to Valley of Namada Main Menu"
    read -p "Enter your choice (1, 2, or 3): " choice

    # Install dependencies
    install_dependencies

    case $choice in
        1)
            fetch_and_display_paginated_data
            ;;
        2)
            manual_calculation
            ;;
        3)
            echo -e "${CYAN}Exiting the script. Goodbye!${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Please try again.${RESET}"
            sleep 1
            ;;
    esac

    # Friendly reminder after they select an option
    echo -e "\033[1;33mRemember: Staking to smaller validators helps reduce Cubic Slashing and supports decentralization. A balanced network is a stronger network! ????\033[0m"
    read -p "Press [Enter] to return to the main menu." dummy
done
