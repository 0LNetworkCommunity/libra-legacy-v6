# Pull the project

Use git to clone the project onto your machine.

`git clone https://github.com/OLSF/libra.git`

# 0L Experimental Genesis

# Prep: Create a github API key.
These tools will be storing data to a github repository which coordinates files needed for genesis.
The repo is (temporarily): https://github.com/OLSF/test-genesis

To create a personal key follow these steps: https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token

This will be your `github_key`
You will now add this to a new file and folder at the project root `my_configs`:
```
cd libra/
mkdir my_configs
cd my_configs
echo "<github_key>" > myfile.txt
```

# Prep: Build the project
If you are starting a new server you will need the following dependencies (Ububtu instructions):

```
sudo apt-get update
sudo apt-get install build-essential cmake clang llvm libgmp-dev cargo
```

You will also need to make sure that rust is installed and that you are running rust NIGHTLY.

If you are going to do anything with cargo, install it:
`sudo apt install cargo`

On a machine you will use for validation, build the project from within the project root dir, with:

`cargo build --all --bins --exclude cluster-test`

# Layout File

Someone creates a layout file on the github backend.
A set-layout file needs to be created by ANY one of the participants.

This is done with:
```
libra/my_configs $

cargo run -p libra-management set-layout --backend 'backend=github;owner=OLSF;repository=test-genesis;token=<ABSOLUTE path to github_token>;namespace=common' --path <path to set_layout.toml, can be relative>
```



cargo run -p libra-management set-layout --backend 'backend=github;owner=OLSF;repository=test-genesis;token=./github_token;namespace=common' --path ./set_layout.toml

The set_layout.toml looks like this. Needs to include all the addresses as they appear in the storage of the github repo.

```
operators = ["zaki", "lucas", "sha", "keerthi"]
owners = ["zaki", "lucas", "sha", "keerthi"]
association = ["vm"]
```

# Mining
Your working directory is now:
`libra/ol-miner/`
TODO: How to call ol-miner from the my_configs path.

## Create and account and Mnemonic
In the ol-miner project create account credentials, which will be needed for mining, and also validation.
```
libra/ol-miner $
cargo run keygen
```
the response will be a print of the mnemonic, account address, and auth key.

DO NOT LOSE THE MNEMONIC. SAVE IT IN YOUR PASSWORD VAULT. WRITE IT ON PAPER NOW.

## Include account data in ol-miner.toml
There is a template for ol-miner.toml in /ol-miner/ update it with the auth key that you generated as part of the credentials in the previous step.

## Mine one proof, your miner's genesis proof.
This will take at least 10 minutes. The current version of the program will stop on its own when one block has been completed.

```
libra/ol-miner $
ol-miner/ cargo run start
```

You will be prompted to enter your mnemonic.

A file called `blocks/block_0.json` will be produced. You will need this for registering your validator for genesis.


# Genesis Ceremony Registration
A github repository will be used to collect credentials from participants.
Your working directory is now:
`libra/my_configs`
## Initialize with Mnemonic
This step initialized a local data store, which will have a number of private keys needed for future steps.
The namespace will identify your validator's data, locally but also in the remote Github repo which coordinates genesis info.

Using the mnemonic, and address from above steps, you will run:

NOTE: If there is a key_store.json present in your my_configs/ you will get an error that the file already exists.

TODO: Ask to overwrite the file, instead of fail on already exists.

```
libra/my_configs $
cargo run -p libra-management initialize --mnemonic '<mnemonic string, single quotes around>' --path=<path to my_configs> --namespace=<account address>
```

cargo run -p libra-management initialize --mnemonic 'average list time circle item couch resemble tool diamond spot winter pulse cloth laundry slice youth payment cage neutral bike armor balance way ice' --path ./ --namespace=zaki



## Add genesis proof from mining
Add the mining details to the REMOTE key_store.json.


```
libra/my_configs $
cargo run -p libra-management mining --path-to-genesis-pow <path to block_0.json, can be relative> --backend 'backend=github;owner=OLSF;repository=test-genesis;token=<ABSOLUTE path to token>github_token;namespace=<address>'
```

cargo run -p libra-management mining --path-to-genesis-pow block_0.json --backend 'backend=github;owner=OLSF;repository=test-genesis;token=github_token;namespace=zaki'

AUTH KEY:
200eaeef43a4e938bc6ff34318d2559d5e7891b719c305941e62867ffe730f48


## Operator key to remote storages
This step creates public keys and adds them to the github repo.

```
libra/my_configs $
cargo run -p libra-management operator-key --local 'backend=disk;path=<ABSOLUTE path to key_store.json>;namespace=<address>' --remote 'backend=github;owner=OLSF;repository=test-genesis;token=<ABSOLUTE path to token>;namespace=<address>'
```

cargo run -p libra-management operator-key --local 'backend=disk;path=key_store.json;namespace=zaki' --remote 'backend=github;owner=OLSF;repository=test-genesis;token=github_token;namespace=zaki'


## Save the public key from response
The step above produces a key and an address. You will need these for the next step.

TODO: Output to file

## Generate Node config
Add IP addresses and the address above to a validator registration transactions, to be stored on github.

Note the IP address of your machine.

```
libra/my_configs $

cargo run -p libra-management validator-config \
--owner-address <address> \
--validator-address "/ip4/104.131.20.59/tcp/6180" \
--fullnode-address "/ip4/104.131.20.59/tcp/6180" \
--local 'backend=disk;path=<ABSOLUTE path to key_store.json>;namespace=<address>' \
--remote 'backend=github;owner=OLSF;repository=test-genesis;token=<ABSOLUTE path to github_token>;namespace=<address>'
```

cargo run -p libra-management validator-config \
--owner-address 027c83aeb3b9c085f5a1506b418d08cf \
--validator-address "/ip4/64.227.28.81/tcp/6180" \
--fullnode-address "/ip4/64.227.28.81/tcp/6180" \
--local 'backend=disk;path=key_store.json;namespace=keerthi' \
--remote 'backend=github;owner=OLSF;repository=test-genesis;token=github_token;namespace=keerthi'



## Build Genesis from remote
Now each validator will build the genesis. The tool combines data from github and from the local data store.
```
libra/my_configs $

cargo run -p libra-management genesis --backend 'backend=github;owner=OLSF;repository=test-genesis;token=<ABSOLUTE path to github_token>' --path <path to genesis.blob, can be relative>
```

cargo run -p libra-management genesis --backend 'backend=github;owner=OLSF;repository=test-genesis;token=./github_token' --path ./genesis.blob


## Create waypoint

TODO:
- key_store.json (bug, it's not doing this) Note: in the next step (config) this needs to appear in node.config.toml.

```
libra/my_configs $

cargo run -p libra-management create-waypoint --remote 'backend=github;owner=OLSF;repository=test-genesis;token=<ABSOLUTE path to github_token>;namespace=common' --local 'backend=disk;path=<ABSOLUTE path to key_store.json>;namespace=<address>'
```



cargo run -p libra-management create-waypoint --remote 'backend=github;owner=OLSF;repository=test-genesis;token=github_token;namespace=common' --local 'backend=disk;path=key_store.json;namespace=zaki'

TODO: output waypoint to a file.

DEBUG DATA:
Waypoint
0:b585a31469dad89c818f41ba3238afedb524c238f9f1500dc051413f13c683b5



# WIP: Configure node.config.toml

TODO for node.config.toml:
- data_dir = "./"
- genesis_file_location = "genesis.blob"
- base.waypoint & base.waypoint.waypoint. include from key_store.json.
- MAYBE? Seed peers file and configs.
- remove, cleanup all data for full_node_networks
- consensus.safety_rules.backend, Review to see how libra_swarm does it, we are doing it with a on_disk backend. But swarm does in memory.


```
libra/my_configs $

cargo run -p libra-management config \
--validator-address \
"/ip4/104.131.20.59/tcp/6180" \
--validator-listen-address "/ip4/0.0.0.0/tcp/6180" \
--backend 'backend=disk;path=<ABSOLUTE path to key_store.json>;namespace=<address>' \
--fullnode-address "/ip4/104.131.20.59/tcp/6179" \
--fullnode-listen-address "/ip4/0.0.0.0/tcp/6179"
```

cargo run -p libra-management config \
--validator-address \
"/ip4/192.241.147.210/tcp/6180" \
--validator-listen-address "/ip4/0.0.0.0/tcp/6180" \
--backend 'backend=disk;path=key_store.json;namespace=zaki' \
--fullnode-address "/ip4/192.241.147.210/tcp/6179" \
--fullnode-listen-address "/ip4/0.0.0.0/tcp/6179"

All the information above in exists in my_configs/key_store.json, much of this needs to go into appropriate fiels in `node.config.toml` which is the file libra-node needs to be able to start.

# Start a libra node

From the `my_configs` directory, start a libra node with the following command.

```
my_configs/

# Run libra-node with the config file, and output stdout/err logs to output.log
cargo run -p libra-node -- --config node.configs.toml &> output.log

```
Open firewall ports. Ubuntu instructions:
```
sudo ufw allow 6180/tcp
sudo ufw allow 6179/tcp
sudo ufw enable
```
