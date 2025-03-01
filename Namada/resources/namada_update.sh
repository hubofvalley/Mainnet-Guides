#!/bin/bash

# Detect OS and version
source /etc/os-release
SERVICE_NAME="namadad"

echo "Detected OS: $NAME $VERSION_ID"

# Available versions and their details
declare -A versions=(
    ["v1.0.0"]="0-893999 https://github.com/anoma/namada/releases/download/v1.0.0"
    ["v1.1.1"]="894000-next https://github.com/anoma/namada/releases/download/v1.1.1"
    # Add new versions here in the format: ["version"]="block_height_range download_url"
    # ["v1.2.0"]="next-next https://github.com/anoma/namada/releases/download/v1.2.0"
)

# Function to show version options
show_version_options() {
    echo -e "\n\033[1mChoose the version to install:\033[0m"
    local index=1

    for version in "${!versions[@]}"; do
        details=(${versions[$version]})
        block_height_range=${details[0]}
        echo "$index. Namada $version (Block height: $block_height_range)"
        ((index++))
    done

    echo "$index. Exit"
}

# Method 1: Pre-built binary
method1() {
    echo -e "\n\033[1mMethod 1: Using pre-built binary\033[0m"
    echo "---------------------------------"
    echo "Pros:"
    echo "- Faster installation"
    echo "- Official signed binaries"
    echo "- No build dependencies needed"
    echo "Cons:"
    echo "- Limited to x86_64 architecture"
    echo "- Requires Ubuntu 22.04+"

    version=$1
    download_url=$2
    namada_file_name="namada-$version-Linux-x86_64"

    echo -e "\nStarting installation for version $version..."
    sudo systemctl stop $SERVICE_NAME

    # Create temporary directory
    temp_dir=$(mktemp -d -t namada-XXXXXX)

    if ! wget -P "$temp_dir" "$download_url/$namada_file_name.tar.gz"; then
        echo "Failed to download the binary. Exiting."
        exit 1
    fi

    tar -xvf "$temp_dir/$namada_file_name.tar.gz" -C "$temp_dir"
    sudo chmod +x "$temp_dir/$namada_file_name/namada"*

    # Move binaries
    sudo mv "$temp_dir/$namada_file_name/namada"* "/usr/local/bin/"

    # Cleanup
    rm -rf "$temp_dir"

    echo "Binary installed successfully"
}

# Method 2: Build from source
method2() {
    echo -e "\n\033[1mMethod 2: Building from source\033[0m"
    echo "---------------------------------"
    echo "Pros:"
    echo "- Works on any Linux distro"
    echo "- Allows custom modifications"
    echo "- Verifiable build process"
    echo "Cons:"
    echo "- Requires >=16GB RAM"
    echo "- Longer installation time"
    echo "- Needs build dependencies"

    version=$1

    echo -e "\nStarting source build for version $version..."
    sudo systemctl stop $SERVICE_NAME

    # Install dependencies
    sudo apt update -y
    sudo apt install -y libssl-dev pkg-config protobuf-compiler \
        clang cmake llvm llvm-dev libudev-dev git

    # Clone repository (if needed)
    if [ ! -d "$HOME/namada" ]; then
        git clone https://github.com/anoma/namada.git $HOME/namada
    fi

    cd $HOME/namada
    git fetch --all --tags
    git checkout "$version"

    # Build with optimized parameters
    cargo build --release

    # Install binaries
    sudo cp target/release/namada* /usr/local/bin/

    echo "Source build completed successfully"
}

# Main script
while true; do
    show_version_options
    read -p "Enter your choice: " version_choice

    if (( version_choice == ${#versions[@]} + 1 )); then
        echo "Exiting..."
        exit 0
    fi

    versions_array=("${!versions[@]}")
    selected_version=${versions_array[$version_choice-1]}

    if [[ -z $selected_version ]]; then
        echo "Invalid option, please try again"
        continue
    fi

    details=(${versions[$selected_version]})
    block_height_range=${details[0]}
    url=${details[1]}

    echo "Selected version: $selected_version (Block height: $block_height_range)"

    # Confirmation prompt
    read -p "Are you sure you want to proceed with this version? (yes/no): " confirm
    if [[ $confirm != "yes" ]]; then
        echo "Operation cancelled."
        exit 0
    fi

    if [ "$VERSION_ID" = "22.04" ]; then
        method2 "$selected_version"
    elif dpkg --compare-versions "$VERSION_ID" "gt" "22.04"; then
        method1 "$selected_version" "$url"
    else
        echo "Error: Unsupported Ubuntu version. Only Ubuntu 22.04 and newer are supported."
        exit 1
    fi
    break
done

# Final steps common to both methods
echo -e "\n\033[1mFinalizing installation...\033[0m"
sudo chown -R $USER:$USER /usr/local/bin/namada*
sudo chmod +x /usr/local/bin/namada*

# Restart service with error checking
echo -e "\nRestarting $SERVICE_NAME service..."
if ! sudo systemctl daemon-reload && sudo systemctl restart $SERVICE_NAME; then
    echo "Service restart failed! Check configuration."
    exit 1
fi

# Verification
echo -e "\nVerifying installation..."
namada --version | grep "$selected_version" && echo "Success!" || echo "Version mismatch detected!"
