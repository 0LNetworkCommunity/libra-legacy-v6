#!/bin/bash

# targeting ububtu

apt update
apt install -y git nano build-essential cmake clang llvm libgmp-dev
curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y
source $HOME/.cargo/env

echo "Enter ssh id_rsa key for github (ctrl+d when done)"
private_key=$(cat)
echo $private_key > ~/.ssh/id_rsa
chmod 400 ~/.ssh/id_rsa
ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub

git clone git@github.com:OLSF/libra.git