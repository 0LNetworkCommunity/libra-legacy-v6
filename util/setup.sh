#!/bin/bash

# targeting ububtu
export NODE_ENV=prod
apt update
apt install -y git vim zip jq build-essential cmake clang llvm libgmp-dev secure-delete
curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y
export "$HOME/.cargo/bin:$PATH"
#record-query, tool for parsing config files like TOML and JSON
curl -LSfs https://japaric.github.io/trust/install.sh | sh -s -- --git dflemstr/rq


mkdir ~/node_data;
mkdir ~/node_data/blocks;

echo "Enter ssh id_rsa key for github (ctrl+d when done)"
private_key=$(cat)
echo "$private_key" > ~/.ssh/id_rsa
chmod 400 ~/.ssh/id_rsa
ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub

git clone git@github.com:OLSF/libra.git