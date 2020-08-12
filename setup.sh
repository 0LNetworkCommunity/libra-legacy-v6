#!/bin/bash

# targeting ububtu
apt update
apt install -y git vim zip build-essential cmake clang llvm libgmp-dev secure-delete
curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y
source $HOME/.cargo/env

if test -d ~/my_configs/; then
    zip -r ~/my_configs_bak.zip ~/my_configs/*
else
    mkdir ~/my_configs;
    cp ~/libra/validator_utils/* ~/my_configs;
fi 



# echo "Enter ssh id_rsa key for github (ctrl+d when done)"
# private_key=$(cat)
# echo $private_key > ~/.ssh/id_rsa
# chmod 400 ~/.ssh/id_rsa
# ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub

# git clone git@github.com:OLSF/libra.git