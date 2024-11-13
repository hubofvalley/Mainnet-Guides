# Namada Protocol Testnet Guide

`will always update`

<p align="center">
  <img src="https://github.com/user-attachments/assets/2ac53a77-8eec-48be-9106-eb832ae5fee3" width="600" height="300">
</p>

## Namada Protocol

### What Is Namada?

Namada is a decentralized, permissionless, privacy-focused blockchain designed to facilitate the creation and management of decentralized applications (dApps) with built-in privacy features. It aims to provide a scalable and secure infrastructure for various use cases, including decentralized finance (DeFi), non-fungible tokens (NFTs), and more.

![image](https://github.com/user-attachments/assets/2ceec88b-8c84-4b48-a31d-e2c888c6b80d)

In the sections below, we will delve deeper into this architecture and explore the key use cases it unlocks.

### Namada’s Architecture

Namada Network is a purpose-built layer 1 blockchain that combines the advantages of EVM (Ethereum Virtual Machine) and Cosmos SDK. It is fully EVM-compatible and features deep execution layer optimizations to support complex data structures like IP quickly and cost-efficiently. Key features include:

1. **Precompiled Primitives**: These allow the system to traverse complex data structures like IP graphs within seconds at marginal costs, ensuring that the licensing process is both fast and affordable.

2. **Consensus Layer**: Based on the mature CometBFT stack, this layer ensures fast finality and cheap transactions, further enhancing the efficiency of the network.

The Proof-of-Creativity Protocol is a set of smart contracts natively deployed on Namada Network. It allows creators to register their IP as "IP Assets" (IPA) on the protocol.

#### Components

- **On-Chain NFT**: Represents the IP, which could be an existing NFT or a new NFT minted to represent off-chain IP.
- **IP Account**: A modified ERC-6551 (Token Bound Account) implementation that manages the IP.

#### Modules

- **Licensing Module**: Allows creators to set terms on their IP, such as whether derivative works can use the IP commercially.
- **Royalty Module**: Enables the creation of revenue streams from derivative works.
- **Dispute Module**: Facilitates the resolution of disputes.

### Programmable IP License (PIL)

The PIL is an off-chain legal contract that enforces the terms of IP Assets and License Tokens. It allows the redemption of tokenized IP into the off-chain legal system, outlining real legal terms for how creators can remix, monetize, and create derivatives of their IP.

### Namada Solving Target

The increasing need for greater efficiency in IP management has coincided with the rise of blockchain technology, which is essential for addressing the current system's challenges. Traditional methods of protecting and licensing IP are cumbersome and expensive, often requiring the involvement of lawyers. This makes the process inaccessible for many creators, particularly those without substantial resources.

Moreover, the current system relies on one-to-one licensing deals, which are not scalable. This leads to many potential licensing opportunities being missed, stifling creativity and innovation. Additionally, the rapid proliferation of AI-generated media has outpaced the current IP system, which was designed for physical replication. There is an urgent need to automate and optimize the licensing of IP to keep up with the digital age.

Namada offers a solution with a specialized layer 1 blockchain that combines the advantages of EVM and Cosmos SDK, providing the infrastructure needed for massive IP data scalability. Key applications of Namada include:

1. **Creators**: Namada enables creators to register their IP as IP Assets and set terms using the Programmable IP License (PIL).
2. **Derivative Works**: Creators of derivative works can license IP automatically through the blockchain, making the process efficient and scalable.
3. **AI-Generated Media**: Namada supports the efficient management of AI-generated content by automating the licensing process.
4. **Scalable Licensing**: Namada's approach to licensing ensures that all potential opportunities are captured, fostering creativity and collaboration.

### Example Use Case

Without Namada, creating a comic with multiple IPs (e.g., Azuki and Pudgy NFTs) would require extensive legal work, making it impractical. With Namada, IP holders can register their IP, set terms, and license their work automatically through the blockchain, making the process efficient and scalable.

### Conclusion

By leveraging blockchain technology, Namada is poised to revolutionize IP management, making it more efficient, scalable, and accessible for creators worldwide. It provides a scalable, low-cost, and fully programmable IP management solution essential for bringing vast amounts of IP on-chain.

For more detailed information, visit the [Namada Documentation](https://docs.namada.net/).

---

With Public Testnet, Namada's docs and code become public. Check them out below!

- [Namada Website](https://namada.net/)
- [Namada Twitter](https://twitter.com/NamadaNet)
- [Namada Discord](https://discord.gg/namada)
- [Namada Docs](https://docs.namada.net/)
- [Namada GitHub](https://github.com/anoma)
- [Namada Explorer](https://explorer.namada.net/)

## Grand Valley's Namada Protocol public endpoints:

- cosmos rpc: `https://lightnode-rpc-namada.grandvalleys.com`
- json-rpc: `https://lightnode-json-rpc-namada.grandvalleys.com`
- cosmos rest-api: `https://lightnode-api-namada.grandvalleys.com`
- cosmos ws: `wss://lightnode-rpc-namada.grandvalleys.com/websocket`
- evm ws: `wss://lightnode-wss-namada.grandvalleys.com`

## Valley Of Namada: Namada Protocol Tools Created by Grand Valley

![Valley of Namada Image 1](https://github.com/user-attachments/assets/5110da6d-4ec2-492d-86ea-887b34b279b4)
![Valley of Namada Image 2](https://github.com/user-attachments/assets/537ca1db-1a0c-4908-a733-3f45872dc8ca)

**Valley of Namada** by Grand Valley is an all-in-one infrastructure solution providing powerful tools for efficient node management and validator interactions within the **Namada Protocol** network. Designed for node runners in the **Namada Protocol** ecosystem, **Valley of Namada** offers an accessible, streamlined interface to manage nodes, maintain network participation, and perform validator functions effectively.

### Installation

Run the following command to install Valley of Namada:

```bash
bash <(curl -s https://raw.githubusercontent.com/hubofvalley/Testnet-Guides/main/Namada/resources/valleyofNamada.sh)
```

## 0G Validator Node Deployment Guide With Cosmovisor

### **System Requirements**

| Category  | Requirements                   |
| --------- | ------------------------------ |
| CPU       | 8 cores                        |
| RAM       | 64+ GB                         |
| Storage   | 1+ TB NVMe SSD                 |
| Bandwidth | 100 MBps for Download / Upload |

- guide's current binaries version: `v0.45.1 will automatically update to the latest version`
- service file name: `namadad.service`
- current chain : `namada-dryrun.abaaeaf7b78cb3ac`

## Validator Node Manual installation

### 1. Install dependencies for building from source

```bash
sudo apt update -y && sudo apt upgrade -y && \
sudo apt install -y curl git jq build-essential gcc unzip wget lz4 openssl \
libssl-dev pkg-config protobuf-compiler clang cmake llvm llvm-dev
```

### 2. install go

```bash
cd $HOME && ver="1.22.0" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bash_profile && \
source ~/.bash_profile && go version
```

### 3. install cosmovisor

```bash
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@latest
```

### 4. install rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
rustc --version
```

### 5. install cometbft

```bash
cd $HOME
rm -rf cometbft
git clone https://github.com/cometbft/cometbft.git
cd cometbft
git checkout v0.37.11
make build
sudo cp $HOME/cometbft/build/cometbft /usr/local/bin/
cometbft version
```

### 5. set vars

ENTER YOUR MONIKER & YOUR PREFERRED PORT NUMBER

```bash
read -p "Enter your moniker: " ALIAS && echo "Current moniker: $ALIAS"
read -p "Enter your 2 digits custom port: (leave empty to use default: 26) " NAMADA_PORT && echo "Current port number: ${NAMADA_PORT:-26}"
read -p "Enter your wallet name: " WALLET && echo "Current wallet name: $WALLET"

echo "export WALLET="$WALLET"" >> $HOME/.bash_profile
echo "export MONIKER="$ALIAS"" >> $HOME/.bash_profile
echo "export OG_CHAIN_ID="namada-dryrun.abaaeaf7b78cb3ac"" >> $HOME/.bash_profile
echo "export NAMADA_PORT="${NAMADA_PORT:-26}"" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

### 6. download binary

```bash
cd $HOME
wget https://github.com/anoma/namada/releases/download/v0.45.1/namada-v0.45.1-Linux-x86_64.tar.gz
tar -xvf namada-v0.45.1-Linux-x86_64.tar.gz
mv namad* /usr/local/bin/
```

### 7. join the network as post-genesis validator

```bash
namadac utils join-network --chain-id $CHAIN_ID
peers=$(curl -sS https://lightnode-rpc-mainnet-namada.grandvalleys.com/net_info | jq -r '.result.peers[] | "\(.node_info.id)@\(.remote_ip):\(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}' | paste -sd, -)
echo $peers
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/config.toml
```

### 8. set custom ports in config.toml file

```bash
sed -i.bak -e "/^\[p2p\]/,/^$/ s%laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${0G_PORT}656\"%g;
s%prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${0G_PORT}660\"%g;
s%proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NAMADA_PORT}658\"%g;
s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${0G_PORT}657\"%g;
s%^pprof_laddr = \"localhost:26060\"%pprof_laddr = \"localhost:${0G_PORT}060\"%g" $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/config.toml
```

### 9. disable indexer (optional) (if u want to run a full node, skip this step)

```bash
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/config.toml
```

### 10. initialize cosmovisor

```bash
echo "export DAEMON_NAME=namadan" >> $HOME/.bash_profile
echo "export DAEMON_HOME=$(find $HOME -type d -name "namada-dryrun.abaaeaf7b78cb3ac")" >> $HOME/.bash_profile
source $HOME/.bash_profile
cosmovisor init /usr/local/bin/namadan && \
mkdir -p $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/cosmovisor/upgrades && \
mkdir -p $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/cosmovisor/backup && \
mkdir -p $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/data
```

### 11. define the path of cosmovisor

```bash
input1=$(which cosmovisor)
input2=$(find $HOME -type d -name "namada-dryrun.abaaeaf7b78cb3ac")
input3=$(find $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/cosmovisor -type d -name "backup")
echo "export DAEMON_NAME=namadan" >> $HOME/.bash_profile
echo "export DAEMON_HOME=$input2" >> $HOME/.bash_profile
echo "export DAEMON_DATA_BACKUP_DIR=$(find $HOME/.local/share/namada/namada-dryrun.abaaeaf7b78cb3ac/cosmovisor -type d -name "backup")" >> $HOME/.bash_profile
source $HOME/.bash_profile
echo "input1. $input1"
echo "input2. $input2"
echo "input3. $input3"
```

#### save the results, they'll be used in the next step

#### this is an example of the result

![image](https://github.com/user-attachments/assets/af974b3d-f195-406f-9f97-c5b7c30cc88f)

### 12. create service file

```bash
sudo tee /etc/systemd/system/namadad.service > /dev/null <<EOF
[Unit]
Description=Cosmovisor Namada Mainnet Node
After=network.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$HOME/.local/share/namada
ExecStart=$input1 run ledger run
StandardOutput=journal
StandardError=journal
Restart=on-failure
RestartSec=5
LimitNOFILE=65536
LimitNPROC=65536
Environment=CMT_LOG_LEVEL=p2p:debug,pex:info
Environment=NAMADA_CMT_STDOUT=true
Environment="DAEMON_NAME=namadan"
Environment="DAEMON_HOME=$input2"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=true"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="DAEMON_DATA_BACKUP_DIR=$input3"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF
```

### 20. start the node

```bash
sudo systemctl daemon-reload && \
sudo systemctl enable namadad && \
sudo systemctl restart namadad && \
sudo journalctl -u namadad -fn 100
```

### this is an example of the node is running well

![alt text](resources/image.png)

### 21. check node version

```bash
cosmovisor run --version
```

## you can use any snapshots and no need to manually update the node version
