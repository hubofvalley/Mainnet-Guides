#!/bin/bash

# Function to check and install dependencies
install_dependencies() {
    if ! command -v curl &> /dev/null; then
        echo "curl could not be found. Installing curl..."
        sudo apt-get update
        sudo apt-get install -y curl
    fi

    if ! command -v jq &> /dev/null; then
        echo "jq could not be found. Installing jq..."
        sudo apt-get update
        sudo apt-get install -y jq
    fi
}

# Function to display the simplified explanation of Cubic Slashing
display_explanation() {
    echo -e "\033[1;32m------------------------------------\033[0m"
    echo -e "\033[1;32m------------------------------------\033[0m"
    echo -e "\033[1;34mHow Does Namada Slashing Work?\033[0m"
    echo -e "\033[1;32m------------------------------------\033[0m"
    echo -e "\033[1;33m1. \033[0mThink of \033[1;31mslashing\033[0m like a penalty in a game. If a player (validator) breaks the rules (goes offline), they get a penalty (slashed) that is based on how many marbles (stake) they control."
    echo -e "\033[1;33m2. \033[0mWhen misbehavior is detected, the validator is frozen – like they’re sitting out for the next few rounds. No one can withdraw their marbles from that validator until the issue is resolved."
    echo -e "\033[1;33m3. \033[0mAfter a few rounds, the penalty is finalized. The validator’s penalty increases if they control too many marbles, which can hurt the network more if they're slashed. This encourages fair play."
    echo -e "\033[1;33m4. \033[0mThe penalty doesn’t happen instantly, but after some time. It gives other validators time to notice and react."
    echo -e "\033[1;33m5. \033[0mOnce a validator’s penalty is processed, they might be allowed to play again – but only after proving they’re ready to follow the rules."
    echo -e "\033[1;32m------------------------------------\033[0m"
    echo ""

    echo -e "\033[1;34mWhy Stake with Small Validators?\033[0m"
    echo -e "\033[1;32m------------------------------------\033[0m"
    echo -e "\033[1;33m1. \033[0mImagine a big jar where everyone places their marbles (staking). If one person fills up the jar, and they drop their marbles, everyone else loses more because their stake is concentrated in one place. That's the risk when too many people stake with big validators!"
    echo -e "\033[1;33m2. \033[0mBy spreading your marbles (stake) across smaller jars (validators), you make the system more stable. If one jar falls over, not all the marbles are lost!"
    echo -e "\033[1;33m3. \033[0mThis helps protect the network and makes it stronger. \033[1;36mDecentralization\033[0m (many small validators) is key to keeping things secure and balanced."
    echo -e "\033[1;33m4. \033[0mValidators like \033[1;36mGrand Valley\033[0m are committed to making sure this happens. Supporting smaller validators like these helps the whole system!"
    echo -e "\033[1;33m5. \033[0mRemember, don’t put all your marbles in one jar – spread them out and keep things safe!\033[0m"
    echo -e "\033[1;32m------------------------------------\033[0m"
    echo ""
}

# Function to calculate the cubic slash rate
calc_cubic_slash_rate() {
    local window_width=$1
    local validator_voting_power=$2
    local total_voting_power=$3
    local fractional_voting_power
    local sum_fractional_voting_power=0

    # Calculate the fractional voting power of the validator
    fractional_voting_power=$(echo "scale=10; $validator_voting_power / $total_voting_power" | bc)

    # Sum the fractional voting powers over the window width
    # The window width can be positive or negative to simulate a sliding window
    for ((i = -window_width; i <= window_width; i++)); do
        sum_fractional_voting_power=$(echo "scale=10; $sum_fractional_voting_power + $fractional_voting_power" | bc)
    done

    # Calculate the cubic slash rate
    cubic_slash_rate=$(echo "scale=10; 9 * ($sum_fractional_voting_power ^ 2)" | bc)

    # Ensure the slash rate is at least 0.01 and at most 1.0
    cubic_slash_rate=$(echo "scale=2; if ($cubic_slash_rate < 0.01) 0.01 else if ($cubic_slash_rate > 1.0) 1.0 else $cubic_slash_rate" | bc)

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
        echo -e "\033[1;32mTotal Voting Power: $total_voting_power NAM\033[0m"
        echo -e "\033[1;32mPage $current_page of $total_pages\033[0m"
        echo ""
        echo -e "\033[1;34mValidator Name                      | Voting Power (NAM) | Voting Power (%) | CSR (NAM)       | CSR (%)\033[0m"
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
            printf "%-35s | %-17s | %-16s | %-17s | %-8s\n" "$name" "$voting_power" "$voting_power_percentage%" "$cubic_slash_rate_nam NAM" "$cubic_slash_rate_percentage%"
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
                    echo "You are already on the last page."
                    sleep 1
                fi
                ;;
            p)
                if [ $current_page -gt 1 ]; then
                    current_page=$((current_page - 1))
                else
                    echo "You are already on the first page."
                    sleep 1
                fi
                ;;
            j)
                read -p "Enter the page number to jump to: " jump_page
                if [[ $jump_page -ge 1 && $jump_page -le $total_pages ]]; then
                    current_page=$jump_page
                else
                    echo "Invalid page number. Please enter a valid page number."
                    sleep 1
                fi
                ;;
            q)
                echo "Exiting pagination..."
                break
                ;;
            b)
                echo "Returning to the main menu..."
                return
                ;;
            *)
                echo "Invalid command! Use [n], [p], [q], [j], or [b]."
                sleep 1
                ;;
        esac
    done
}

# Manual calculation function
manual_calculation() {
    echo "Enter the Voting Power (NAM):"
    read voting_power
    echo "Enter the Total Voting Power (NAM):"
    read total_voting_power
    echo "Enter the Window Width:"
    read window_width

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
    echo "Manual CSR Calculation"
    echo "-----------------------------"
    printf "%-20s | %-17s | %-16s | %-17s | %-7s\n" "Voting Power (NAM)" "Voting Power (%)" "CSR (NAM)" "CSR (%)"
    echo "-------------------------------------------------------------------------------------"
    printf "%-20s | %-17s | %-16s | %-17s | %-7s\n" "$voting_power" "$voting_power_percentage%" "$cubic_slash_rate_nam NAM" "$cubic_slash_rate_percentage%"
    echo "-------------------------------------------------------------------------------------"
    echo ""
}

# Main menu for the user to select
while true; do
    clear
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
            echo "Exiting the script. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            sleep 1
            ;;
    esac

    # Friendly reminder after they select an option
    echo -e "\033[1;33mRemember: Staking to smaller validators helps reduce Cubic Slashing and supports decentralization. A balanced network is a stronger network! ????\033[0m"
    read -p "Press Enter to return to the main menu..."
done
