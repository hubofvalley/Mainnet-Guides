#!/bin/bash

LOGO="
 __                                   
/__ ._ _. ._   _|   \  / _. | |  _    
\_| | (_| | | (_|    \/ (_| | | (/_ \/
                                    /
"

echo "$LOGO"

# Stop and remove existing Namada node
sudo systemctl daemon-reload
sudo systemctl stop namadad
sudo systemctl disable namadad
sudo rm -rf /etc/systemd/system/namadad.service
sudo rm -r namada
sudo rm -rf $HOME/.local/share/namada
sed -i "/NAMADA_/d" $HOME/.bash_profile

# Prompt for MONIKER, NAMADA_PORT, and Indexer option
read -p "Enter your moniker: " MONIKER
read -p "Enter your preferred port number: (leave empty to use default: 26)" NAMADA_PORT
if [ -z "$NAMADA_PORT" ]; then
    NAMADA_PORT=26
fi
read -p "Enter your wallet name: " WALLET
read -p "Do you want to enable the indexer? (yes/no): " ENABLE_INDEXER

# 1. Install dependencies for building from source
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y curl git jq build-essential gcc unzip wget lz4 openssl libssl-dev pkg-config protobuf-compiler clang cmake llvm llvm-dev

# 2. Install Go
cd $HOME && ver="1.22.0"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bash_profile
source ~/.bash_profile
go version

# 3. install rust

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
rustc --version

# 4. install cometbft

cd $HOME
rm -rf cometbft
git clone https://github.com/cometbft/cometbft.git
cd cometbft
git checkout v0.37.11
make build
sudo cp $HOME/cometbft/build/cometbft /usr/local/bin/
cometbft version

# 5. Set environment variables
echo "export MONIKER=\"$MONIKER\"" >> $HOME/.bash_profile
echo "export WALLET="$WALLET"" >> $HOME/.bash_profile
echo "export NAMADA_CHAIN_ID=\"namada-dryrun.abaaeaf7b78cb3ac\"" >> $HOME/.bash_profile
echo "export NAMADA_PORT=\"$NAMADA_PORT\"" >> $HOME/.bash_profile
echo "export BASE_DIR=\"$HOME/.local/share/namada\"" >> $HOME/.bash_profile
export NAMADA_NETWORK_CONFIGS_SERVER="https://testnet.namada-dryrun.tududes.com/configs"
source $HOME/.bash_profile

# 6. Download Namada binaries
cd $HOME
wget https://github.com/anoma/namada/releases/download/v0.45.1/namada-v0.45.1-Linux-x86_64.tar.gz
tar -xvf namada-v0.45.1-Linux-x86_64.tar.gz
cd namada-v0.45.1-Linux-x86_64
mv namad* /usr/local/bin/

# 7. Initialize the app
namadac utils join-network --chain-id $NAMADA_CHAIN_ID
peers="tcp://5c2fffc93c7e626ed794e0fab7e2fe5ea182f0a5@namada-mainnet-peer.itrocket.net:14656,tcp://bab35c72f4134a03a53cae96bb2992cd155ac1d7@185.16.39.116:26656,tcp://532abcbee988a7704bcfc16d9cbca622ca218fba@176.9.50.55:26656,tcp://f6e089169b9085164e7cf41ab72c3a4c4f3f4364@146.59.54.35:26656,tcp://bdc23b0df729a0f9346d916df09488b1d571cd9e@193.35.50.208:26656,tcp://e5182b9bfa6f66c9483e726c2f659f4bce352a8a@213.133.103.17:26656,tcp://ed3eb21ff431bc25dd45e08ebf97d2b6f9200bcf@188.214.130.149:26656,tcp://d4a187ad131d384e802ef1d61ebac2c2cc5f0b05@185.198.49.133:46656,tcp://cd580833c8f9f10dfde516a4dde84bb2bbcd449c@65.109.158.190:26656,tcp://3eb52b18e1ccfd787d558ff8a1444b39ca57575e@65.108.227.114:31656,tcp://d882a10dec0da40b045aeb13175a6d4f97194888@62.3.101.89:26656,tcp://a7afea109743747962849bb81fcb20ecdd7bda38@62.3.101.91:26656,tcp://bc1c47ad19c61c24a28ba408a0b6aac9b4b40066@78.144.78.1:46656,tcp://08771d75bf7f4421ce6e22c8742101c337e34eec@135.181.5.27:34200,tcp://d066462f86cf4b7ea7c83140ed2debf6c74966d6@109.123.242.26:26656,tcp://d01fe71ab8529f920ad7100c873e55825d3ecafa@195.3.221.249:26656,tcp://58b33cc023ed30d8f2e5249ea75184bebe6fa05a@126.26.36.229:26656,tcp://fe7967decf7aedafc2c1278fea5ae3f6a7395117@75.119.159.247:26656,tcp://05309c2cce2d163027a47c662066907e89cd6b99@74.50.93.254:14656,tcp://2bf5cdd25975c239e8feb68153d69c5eec004fdb@64.118.250.82:46656,tcp://abcf5f7802dffff5f146edb574f070ab684576a7@176.9.24.46:14656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/config.toml

# 8. Set custom ports in config.toml
sed -i.bak -e "s%laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${NAMADA_PORT}656\"%;
s%prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${NAMADA_PORT}660\"%g;
s%proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NAMADA_PORT}658\"%g;
s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${NAMADA_PORT}657\"%g;
s%^pprof_laddr = \"localhost:26060\"%pprof_laddr = \"localhost:${NAMADA_PORT}060\"%g" $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/config.toml

# 9. Enable or disable indexer based on user input
if [ "$ENABLE_INDEXER" = "yes" ]; then
    sed -i -e 's/^indexer = "null"/indexer = "kv"/' $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/config.toml
    echo "Indexer enabled."
else
    sed -i -e 's/^indexer = "kv"/indexer = "null"/' $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/config.toml
    echo "Indexer disabled."
fi

# 10. Create systemd service files for the namada validator node

# Consensus service file
sudo tee /etc/systemd/system/namadad.service > /dev/null <<EOF
[Unit]
Description=Namada Mainnet Node
After=network.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$HOME/.local/share/namada
ExecStart=namadan ledger run
StandardOutput=journal
StandardError=journal
Restart=on-failure
RestartSec=5
LimitNOFILE=65536
LimitNPROC=65536
Environment=CMT_LOG_LEVEL=p2p:debug,pex:info
Environment=NAMADA_CMT_STDOUT=true

[Install]
WantedBy=multi-user.target
EOF

# 11. Start the node
sudo systemctl daemon-reload
sudo systemctl enable namadad
sudo systemctl restart namadad

# 12. Confirmation message for installation completion
if systemctl is-active --quiet namadad; then
    echo "Node installation and services started successfully!"
else
    echo "Node installation failed. Please check the logs for more information."
fi

# show the full logs
echo "sudo journalctl -u namadad -fn 100"
