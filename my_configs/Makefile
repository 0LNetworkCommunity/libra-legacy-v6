SHELL=/usr/bin/env bash

###########################
## UPDATE YOUR DATA HERE ##
# Don't put the MNEM here for production, add that by command line only.
DATA_PATH = ./
# TODO: namespace and account will be the same data. Testing with human readable names.
REPO_ORG = lpgeiger
REPO_NAME = debug-genesis
GITHUB_TOKEN = $(shell cat github_token.txt)

ifeq ($(NAME), zaki)
ACC = 402e9aaf54ca8c39bab641b0c9829070
AUTH = 3dfca19b9914d78ec0c3d04c486e7baa402e9aaf54ca8c39bab641b0c9829070
IP = 192.241.147.210
MNEM = average list time circle item couch resemble tool diamond spot winter pulse cloth laundry slice youth payment cage neutral bike armor balance way ice
endif

ifeq ($(NAME), lucas)
ACC = 5e7891b719c305941e62867ffe730f48
AUTH = 200eaeef43a4e938bc6ff34318d2559d5e7891b719c305941e62867ffe730f48
IP = 104.131.20.59
MNEM = owner city siege lamp code utility humor inherit plug tuna orchard lion various hill arrow hold venture biology aisle talent desert expand nose city
endif

ifeq ($(NAME), sha)
ACC = b2f38139f75a271fd8f8fae4a87c2679
AUTH = 4b964ff86508164652cce32107cd7107b2f38139f75a271fd8f8fae4a87c2679
IP = 64.227.20.31
MNEM = motor employ crumble add original wealth spray lobster eyebrow title arrive hazard machine snake east dish alley drip mail erupt source dinner hobby day
endif

ifeq ($(NAME), keerthi)
ACC = 027c83aeb3b9c085f5a1506b418d08cf
AUTH = 54cf55ab1aff7b757af9a6b07dba6011027c83aeb3b9c085f5a1506b418d08cf
IP = 157.245.133.106
MNEM = advice organ wage sick travel brief leave renew utility host roast barely can noble cheap cancel rotate series method inside damage beach tomorrow power
endif

# set up the environment
install: deps rust stdlib bins
# pipelines for genesis ceremony
register: clear init mining keys register
# do genesis
genesis: build-genesis waypoint toml peers

deps:
	sudo apt-get update
	sudo apt-get -y install build-essential cmake clang llvm libgmp-dev
	sudo curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	# s

rust:
	## TODO: Cargo is not getting set to path. This next line doesn't run.
	source ~/.cargo/env 
	rustup default nightly
	
stdlib:
	cd ../language/stdlib && cargo run --release

bins:
	cargo build -p libra-node --release
	cargo build -p libra-management --release
	cargo build -p miner --release
	cp -f ../target/release/libra-management /usr/local/bin/libra-management
	cp -f ../target/release/libra-node /usr/local/bin/libra-node



all-bins:
	cargo build --all --bins --release --exclude cluster-test


# CONFIGURE GITHUB FOR TEST
#Authorization: token be83c3cc74a3a9517e0685b76fe27b08ccec7a0e"

github: 
	curl -X POST -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/user/repos -d '{"name":"${REPO_NAME}", "private": "true", "auto_init": "true"}'

#GENESIS CEREMONY

clear:
	rm -rf libradb *.seed_peers.toml block_0.json node.configs.toml genesis.blob key_store.json
	cp block_0.json.hard.${NAME} block_0.json

init:
	libra-management initialize \
	--mnemonic '${MNEM}' \
	--path=${DATA_PATH} \
	--namespace=${NAME}

layout:
	libra-management set-layout \
	--backend 'backend=github;owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}github_token.txt;namespace=common' \
	--path=set_layout.toml

mining:
	libra-management mining \
	--path-to-genesis-pow ${DATA_PATH}/block_0.json \
	--backend 'backend=github;owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}github_token.txt;namespace=${NAME}'

keys:
	libra-management operator-key \
	--local 'backend=disk;path=${DATA_PATH}key_store.json;namespace=${NAME}' \
	--remote 'backend=github;owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}github_token.txt;namespace=${NAME}'

register:
	libra-management validator-config \
	--owner-address ${ACC} \
	--validator-address "/ip4/${IP}/tcp/6180" \
	--fullnode-address "/ip4/${IP}/tcp/6179" \
	--local 'backend=disk;path=${DATA_PATH}key_store.json;namespace=${NAME}' \
	--remote 'backend=github;owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}github_token.txt;namespace=${NAME}'

build-genesis:
	NODE_ENV='prod' cargo run -p libra-management genesis \
	--backend 'backend=github;owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}github_token.txt' \
	--path ${DATA_PATH}/genesis.blob

waypoint:
	NODE_ENV='prod' libra-management create-waypoint \
	--remote 'backend=github;owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}github_token.txt;namespace=common' \
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
	NODE_ENV='prod'
	libra-node --config ${DATA_PATH}node.configs.toml

start-bg:
	# run in background and output logs
	libra-node --config ${DATA_PATH}node.configs.toml &> output.log &



daemon:
	cp libra-node.service /lib/systemd/system/
	touch /root/libra/output-libra-node.log
	chmod 655 /root/libra
	chmod 655 /root/libra/output-libra-node.log
	systemctl daemon-reload
	systemctl enable libra-node.service
	systemctl start libra-node.service

datadog:
	DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=bc1d4e1501b29ec31f0e131fda7ba440 DD_SITE="datadoghq.com" bash -c \"$$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)\"
	# mkdir /etc/datadog-agent/conf.d/libra.d/
	cp datadog_config.yaml /etc/datadog-agent/conf.d/libra.d/conf.yaml
	service datadog-agent start