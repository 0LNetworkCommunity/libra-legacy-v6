#!/bin/bash

# Environment Variable
# Please add bins into your path manually, or edit the following lines.
# BIN_PATH=/Users/ping/workspace/libra/target/release
# export PATH=$PATH:$BIN_PATH

# Node Variable
ADDRESS="c9c299f64e483986d4434e3527bffb3f"
AUTHKEY="faf053a638b9bf31a39568d2c287bcb3c9c299f64e483986d4434e3527bffb3f"
NODE_IP="64.227.30.144"
# Remote Sharing Setting
REMOTES="backend=github;owner=OLSF;repository=test-genesis;token=github.key"
LOCAL="backend=disk;path=key_store.json;namespace=$ADDRESS"

echo -n "Enter your mnemonic: > "
read mnemonic
# echo "You entered: $mnemonic"

FILE=./blocks/block_0.json
if [ ! -f "$FILE" ]; then
    echo "It will take about 10~20 minutes to finished this step."
    # generate block 0 for given mnemonic
    echo $mnemonic | miner start
fi

echo "initializing..."
libra-management initialize --mnemonic="$mnemonic" --path="./" --namespace="$ADDRESS"
echo "mining..."
libra-management mining --path-to-genesis-pow="./blocks/block_0.json" --backend="$REMOTES;namespace=$ADDRESS"
echo "generating operator keys..."
libra-management operator-key --local="$LOCAL" --remote="$REMOTES;namespace=$ADDRESS"
echo "setup validator config..."
libra-management validator-config --owner-address $ADDRESS --validator-address "/ip4/$NODE_IP/tcp/6180"  \
              --fullnode-address "/ip4/$NODE_IP/tcp/6180" --local $LOCAL --remote="$REMOTES;namespace=$ADDRESS"
echo "setting layout..."
libra-management set-layout --backend "$REMOTES;namespace=common" --path=set_layout.toml
echo "fetching genesis..."
libra-management genesis --backend="$REMOTES" --path=genesis.blob
echo "producing node.config.toml"
libra-management config --validator-address "/ip4/$NODE_IP/tcp/6180" \
              --validator-listen-address "/ip4/0.0.0.0/tcp/6180" \
              --backend "$LOCAL" \
              --fullnode-address "/ip4/$NODE_IP/tcp/6179" \
              --fullnode-listen-address "/ip4/0.0.0.0/tcp/6179"