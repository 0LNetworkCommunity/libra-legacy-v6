# 0L Experimental Genesis

#Create a github API key.
These tools will be storing data to a github repository which coordinates files needed for genesis.
The repo is (temporarily): https://github.com/OLSF/test-genesis

To create a personal key follow these steps: https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token

This will be your `github_key`
You will now add this to a new file and folder here:
```
cd libra/config/management
mkdir my_configs
cd my_configs
echo "<github_key>" > myfile.txt
```

# Build the project
On a machine you will use for validation, build the project the project root dir, with:

`libra/ cargo build --all --bins --exclude cluster-test`

If you are starting a new server you will need the following dependencies (Ububtu instructions):

sudo apt-get update
sudo apt-get install build-essential cmake clang llvm libgmp-dev

# Mining
Your working directory is now:
`libra/ol-miner/`
## Create and account and Mnemonic
In the ol-miner project create account credentials, which will be needed for mining, and also validation.
`ol-miner/ cargo run keygen`

the response will be a print of the mnemonic, account address, and auth key.

DO NOT LOSE THE MNEMONIC. SAVE IT IN YOUR PASSWORD VAULT. WRITE IT ON PAPER NOW.

## Include account data in ol-miner.toml
There is a template for ol-miner.toml in /ol-miner/ update it wieht the credentials.

## Mine one proof, your miner's genesis proof.
This will take at least 10 minutes.
A file called `blocks/block_0.json` will be produced. You will need this for registering your validator for genesis.

# Genesis Ceremony Registration
A github repository will be used to collect credentials from participants.
Your working directory is now:
`libra/config/management/`
## Initialize with Mnemonic
This step initialized a local data store, which will have a number of private keys needed for future steps.
The namespace will identify your validator's data, locally but also in the remote Github repo which coordinates genesis info.

Using the mnemonic, and address from above steps, you will run:

```
mkdir my_configs
cargo run initialize --mnemonic '<mnemonic string, single quotes around>' --path ./my_configs --namespace=<account address>
```

## Add genesis proof from mining
Add the mining details to the REMOTE key_store.json.

```
cargo run mining --path-to-genesis-pow ./test_fixtures/miner_1/block_0.json --backend 'backend=github;owner=OLSF;repository=test-genesis;token=./lucas_stuff/github_token;namespace=lucas'
```

## Operator key to remote storages
This step creates public keys and adds them to the github repo.

```
cargo run operator-key --local 'backend=disk;path=./my_configs/key_store.json;namespace=<address>' --remote 'backend=github;owner=OLSF;repository=test-genesis;token=./my_configs/github_token;namespace=<address>'
```


## Save the public key from response
The step above produces a key and an address. You will need these for the next step.

Key:
9336f9ff1d9ea89f6872517b1919fea147693aa1c2ccb3e32c2d9fe224faf1fc
Address
5e7891b719c305941e62867ffe730f48

## Generate Node config
Add IP addresses and the address above to a validator registration transactions, to be stored on github.

Note the IP address of your machine.

```
cargo run validator-config --owner-address <address> --validator-address "/ip4/104.131.20.59/tcp/6180" --fullnode-address "/ip4/104.131.20.59/tcp/6180" --local 'backend=disk;path=./my_configs/key_store.json;namespace=<address>' --remote 'backend=github;owner=OLSF;repository=test-genesis;token=./my_configs/github_token;namespace=<address>'
```

## Create Layout file.
A set-layout file needs to be created by any one of the participants.

This is done with:
```
cargo run set-layout --backend 'backend=github;owner=OLSF;repository=test-genesis;token=./my_configs/github_token;namespace=common' --path ./my_configs/set_layout.toml
```

The set_layout.toml looks like this. Needs to include all the addresses as they appear in the storage of the github repo.

```
[operator] = ["alice's address", "bob's address"]
[owner] = ["alice's address", "bob's address"]
[association] = ["vm"]
```

## Build Genesis from remote
Now each validator will build the genesis. The tool combines data from github and from the local data store.
```
 cargo run genesis --backend 'backend=github;owner=OLSF;repository=test;token=./my_configs/github_token' --path ./my_configs/genesis.blob
```

## Create waypoint
```
cargo run create-waypoint --remote 'backend=github;owner=OLSF;repository=test-genesis;token=./my_configs/github_token;namespace=common' --local 'backend=disk;path=./my_configs/key_store;namespace=<address>'
```

# WIP: Configure node.config.toml
All the information above in exists in my_configs/key_store.json, much of this needs to go into appropriate fiels in `node.config.toml` which is the file libra-node needs to be able to start.

TODO: help needed here. We need to place the above keys, and network data into the node.config.toml.
