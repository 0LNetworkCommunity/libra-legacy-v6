#!/bin/bash

# targeting ububtu

apt update
apt install -y git cmake
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs --output rust_setup.sh
bash rust_setup.sh --default-toolchain nightly -y
source $HOME/.cargo/env

echo "Enter ssh key for github (ctrl+d when done)"
private_key=$(cat)
echo $private_key > ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519
ssh-keygen -y -f ~/.ssh/id_ed25519 > ~/.ssh/id_ed25519.pub

git clone git@github.com:OLSF/libra.git