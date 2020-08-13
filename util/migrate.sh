#!/bin/bash

# targeting ububtu
export NODE_ENV=prod
sudo apt update
sudo apt install -y zip

if test -d ~/node_data/; then
    zip -r ~/node_data_bak.zip ~/node_data/*
fi

mkdir ~/node_data
# cp ~/libra/my_configs/* ~/node_data/;
cp ~/libra/my_configs/github_token.txt ~/node_data/
cp ~/libra/my_configs/key_store.json ~/node_data/
cp ~/libra/miner/miner.toml.json ~/node_data/


cp ~/libra/validator_utils/Makefile ~/node_data/
mkdir ~/node_data/blocks
cp ~/node_data/block_0.json ~/node_data/blocks/
mv ~/node_data/block_0.json ~/node_data/block_0.json.genesis.bak




# echo "Enter ssh id_rsa key for github (ctrl+d when done)"
# private_key=$(cat)
# echo $private_key > ~/.ssh/id_rsa
# chmod 400 ~/.ssh/id_rsa
# ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub

# git clone git@github.com:OLSF/libra.git