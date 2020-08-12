#!/bin/bash

# targeting ububtu
export NODE_ENV=prod
apt update
apt install -y git vim zip build-essential cmake clang llvm libgmp-dev secure-delete
curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y
source $HOME/.cargo/env

if test -d ~/node_data/; then
    zip -r ~/node_data.bak.zip ~/node_data/*
else
    mkdir ~/node_data;
    cp ~/libra/validator_utils/* ~/node_data;
fi 



# echo "Enter ssh id_rsa key for github (ctrl+d when done)"
# private_key=$(cat)
# echo $private_key > ~/.ssh/id_rsa
# chmod 400 ~/.ssh/id_rsa
# ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub

# git clone git@github.com:OLSF/libra.git