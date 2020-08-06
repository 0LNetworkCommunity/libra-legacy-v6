#!/bin/bash

# targeting ububtu

apt update
apt install -y git nano build-essential cmake clang llvm libgmp-dev
curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y
source $HOME/.cargo/env

echo "Enter ssh key for github (ctrl+d when done)"
private_key=$(cat)
echo $private_key > ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519

# TODO: make the public key
# ssh-keygen -t ed25519 -y -f ~/.ssh/id_ed25519 > ~/.ssh/id_ed25519.pub

git clone git@github.com:OLSF/libra.git