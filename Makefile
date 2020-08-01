SHELL=/usr/bin/env bash
DATA_PATH = ./

compile : all-bins

# pipelines for genesis ceremony
register: init mining keys register
# > make register MNEM= NAME= ACC= IP=
config: waypoint toml


# Add other binaries later.
install:
	cp -f target/release/ol_miner /usr/local/bin/ol_miner
	cp -f target/release/libra-management /usr/local/bin/libra-management

all-bins:
	cargo build --all --bins --release --exclude cluster-test

deps:
	sudo apt-get update
	sudo apt-get install build-essential cmake clang llvm libgmp-dev

#GENESIS CEREMONY
init:
	cargo run -p libra-management initialize \
	--mnemonic ${MNEM} \
	--path=${DATA_PATH} \
	--namespace=${NAME}

mining:
	cargo run -p libra-management mining \
	--path-to-genesis-pow ${DATA_PATH}block_0.json \
	--backend 'backend=github;owner=OLSF;repository=test-genesis;token=${DATA_PATH}github_token.txt;namespace=${NAME}'

keys:
	cargo run -p libra-management operator-key \
	--local 'backend=disk;path=${DATA_PATH}key_store.json;namespace=${NAME}' \
	--remote 'backend=github;owner=OLSF;repository=test-genesis;token=${DATA_PATH}github_token.txt;namespace=${NAME}'

register:
	cargo run -p libra-management validator-config \
	--owner-address ${ACC} \
	--validator-address "/ip4/${IP}/tcp/6180" \
	--fullnode-address "/ip4/${IP}/tcp/6179" \
	--local 'backend=disk;path=${DATA_PATH}key_store.json;namespace=${NAME}' \
	--remote 'backend=github;owner=OLSF;repository=test-genesis;token=${DATA_PATH}/github_token.txt;namespace=${NAME}'

genesis:
	cargo run -p libra-management genesis \
	--backend 'backend=github;owner=OLSF;repository=test-genesis;token=${DATA_PATH}github_token.txt' \
	--path ${DATA_PATH}

waypoint:
	cargo run -p libra-management create-waypoint \
	--remote 'backend=github;owner=OLSF;repository=test-genesis;token=${DATA_PATH}github_token.txt;namespace=common' \
	--local 'backend=disk;path=${DATA_PATH}key_store.json;namespace=${NAME}'

toml:
	cargo run -p libra-management config \
	--validator-address \
	"/ip4/${IP}/tcp/6180" \
	--validator-listen-address "/ip4/0.0.0.0/tcp/6180" \
	--backend 'backend=disk;path=${DATA_PATH}key_store.json;namespace=${NAME}' \
	--fullnode-address "/ip4/${IP}/tcp/6179" \
	--fullnode-listen-address "/ip4/0.0.0.0/tcp/6179"
