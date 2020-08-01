SHELL=/usr/bin/env bash

###########################
## UPDATE YOUR DATA HERE ##
# Don't put the MNEM here for production, add that by command line only.
DATA_PATH = ./
# TODO: namespace and account will be the same data. Testing with human readable names.

ifeq ($(NAME), zaki)
ACC = 402e9aaf54ca8c39bab641b0c9829070
IP = 192.241.147.210
MNEM = average list time circle item couch resemble tool diamond spot winter pulse cloth laundry slice youth payment cage neutral bike armor balance way ice

endif

ifeq ($(NAME), lucas)
ACC = 5e7891b719c305941e62867ffe730f48
IP = 104.131.20.59
MNEM = owner city siege lamp code utility humor inherit plug tuna orchard lion various hill arrow hold venture biology aisle talent desert expand nose city
endif

ifeq ($(NAME), sha)
ACC = b2f38139f75a271fd8f8fae4a87c2679
IP = 64.227.20.31
MNEM = motor employ crumble add original wealth spray lobster eyebrow title arrive hazard machine snake east dish alley drip mail erupt source dinner hobby day

endif

ifeq ($(NAME), keerthi)
ACC = 027c83aeb3b9c085f5a1506b418d08cf
IP = 157.245.133.106
MNEM = advice organ wage sick travel brief leave renew utility host roast barely can noble cheap cancel rotate series method inside damage beach tomorrow power
endif

# set up the environment
install: deps bins
# pipelines for genesis ceremony
register: clear init mining keys register
# do genesis
genesis: build-genesis waypoint toml peers
# starts a node:
# >make start

# Add other binaries later

deps:
	sudo apt-get update
	sudo apt-get install build-essential cmake clang llvm libgmp-dev
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	source ~/.cargo/env
	rustup default nightly
	
bins:
	cd ../language/stdlib && cargo run --release
	cargo build -p libra-node --release
	cargo build -p libra-management --release
	cargo build -p miner --release
	cp -f ../target/release/libra-management /usr/local/bin/libra-management
	cp -f ../target/release/libra-node /usr/local/bin/libra-node

all-bins:
	cargo build --all --bins --release --exclude cluster-test

copy:
	#cp -f target/release/ol_miner /usr/local/bin/ol_miner
	cp -f ../target/release/libra-management /usr/local/bin/libra-management
	cp -f ../target/release/libra-node /usr/local/bin/libra-node



#GENESIS CEREMONY
stdlib:
	cd ../language/stdlib && cargo run --release

clear:
	rm -rf libradb *.seed_peers.toml block_0.json node.configs.toml genesis.blob key_store.json
	cp block_0.json.${NAME} block_0.json
init:
	libra-management initialize \
	--mnemonic '${MNEM}' \
	--path=${DATA_PATH} \
	--namespace=${NAME}
layout:
	libra-management set-layout \
	--backend 'backend=github;owner=OLSF;repository=test-genesis;token=${DATA_PATH}github_token.txt;namespace=common' \
	--path=set_layout.toml
mining:
	libra-management mining \
	--path-to-genesis-pow ${DATA_PATH}/block_0.json \
	--backend 'backend=github;owner=OLSF;repository=test-genesis;token=${DATA_PATH}github_token.txt;namespace=${NAME}'

keys:
	libra-management operator-key \
	--local 'backend=disk;path=${DATA_PATH}key_store.json;namespace=${NAME}' \
	--remote 'backend=github;owner=OLSF;repository=test-genesis;token=${DATA_PATH}github_token.txt;namespace=${NAME}'

register:
	libra-management validator-config \
	--owner-address ${ACC} \
	--validator-address "/ip4/${IP}/tcp/6180" \
	--fullnode-address "/ip4/${IP}/tcp/6179" \
	--local 'backend=disk;path=${DATA_PATH}key_store.json;namespace=${NAME}' \
	--remote 'backend=github;owner=OLSF;repository=test-genesis;token=${DATA_PATH}github_token.txt;namespace=${NAME}'

build-genesis:
	libra-management genesis \
	--backend 'backend=github;owner=OLSF;repository=test-genesis;token=${DATA_PATH}github_token.txt' \
	--path ${DATA_PATH}/genesis.blob

waypoint:
	libra-management create-waypoint \
	--remote 'backend=github;owner=OLSF;repository=test-genesis;token=${DATA_PATH}github_token.txt;namespace=common' \
	--local 'backend=disk;path=${DATA_PATH}key_store.json;namespace=${NAME}'

toml:
	libra-management config \
	--validator-address \
	"/ip4/${IP}/tcp/6180" \
	--validator-listen-address "/ip4/0.0.0.0/tcp/6180" \
	--backend 'backend=disk;path=${DATA_PATH}key_store.json;namespace=${NAME}' \
	--fullnode-address "/ip4/${IP}/tcp/6179" \
	--fullnode-listen-address "/ip4/0.0.0.0/tcp/6179"

peers:
	libra-management seeds --genesis-path genesis.blob
	cp seed_peers.toml 00000000000000000000000000000000.seed_peers.toml

start:
	# run in background and output logs
	libra-node --config ${DATA_PATH}node.configs.toml &> output.log &

daemon-init:
	cp libra_node.service /etc/systemd/system/
	touch /root/output-libra-node.log
	systemctl daemon-reload
	systemctl enable libra_node.service
	systemctl start libra_node.service

datadog:
	DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=bc1d4e1501b29ec31f0e131fda7ba440 DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"
	mkdir /etc/datadog-agent/conf.d/libra.d/
	cp datadog_config.yaml /etc/datadog-agent/conf.d/libra.d/conf.yaml
	datadog-agent start