#!/bin/bash

# Detect OS and version
OS_NAME=$(lsb_release -si)
OS_VERSION=$(lsb_release -sr)
SERVICE_NAME="namadad"

echo "Detected OS: $OS_NAME $OS_VERSION"

# Function to show method recommendations
recommend_method() {
    if [[ "$OS_NAME" == "Ubuntu" && "$OS_VERSION" == "22.04" ]]; then
        echo -e "\nRecommendation: Both methods work, but Method 1 (pre-built binary) is faster"
    elif [[ "$OS_NAME" == "Ubuntu" && $(echo "$OS_VERSION >= 22.04" | bc -l) -eq 1 ]]; then
        echo -e "\nRecommendation: Method 1 (pre-built binary) recommended"
    else
        echo -e "\nRecommendation: Method 2 (build from source) required"
    fi
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
    
    local version=$1
    local download_url=$2
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
    
    local version=$1
    
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
show_menu() {
    echo -e "\n\033[1mChoose installation method:\033[0m"
    echo "1) Pre-built binary (Ubuntu 22.04+ recommended)"
    echo "2) Build from source (other distributions)"
    echo "3) Exit"
    
    recommend_method
}

while true; do
    show_menu
    read -p "Enter your choice (1/2/3): " method_choice

    case $method_choice in
        1)
            version="v1.1.1"  # Update this for new versions
            url="https://github.com/anoma/namada/releases/download/$version"
            method1 "$version" "$url"
            break
            ;;
        2)
            version="v1.1.1"  # Update this for new versions
            method2 "$version"
            break
            ;;
        3)
            echo "Back to main menu"
            exit 0
            ;;
        *)
            echo "Invalid option, please try again"
            ;;
    esac
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
namada --version | grep "$version" && echo "Success!" || echo "Version mismatch detected!"

echo -e "\nService logs (Ctrl+C to exit):"
sudo journalctl -u $SERVICE_NAME -f --output cat
