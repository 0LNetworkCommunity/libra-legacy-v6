SHELL=/usr/bin/env bash

DATA_PATH = ./
GITHUB_TOKEN = $(shell cat github_token.txt)


ifndef TEST
####################################
## GENESIS: UPDATE YOUR DATA HERE ##
# The permanent IP address of your validator.
IP = fill this in
# The 0L account, which will be your namespace for all data
# Also is last 16 digits of auth_key hex.
ACC = fill this in
######################################

NAMESPACE = $(ACC)
REPO_ORG = OLSF
REPO_NAME = experimental-genesis
# Don't put the MNEM here for production, add that by command line only.
else
HOST = $(shell hostname | cut -c4-10)
NAMESPACE = $(HOST)
REPO_ORG = OLSF
REPO_NAME = debug-genesis
endif

ifndef NODE_ENV
# Default to prod settings for genesis and mining. Pass with ENV=test for test values.
NODE_ENV=prod
endif

confirm:
	cd ~/libra/miner && ls
	@echo namespace: ${NAMESPACE}
	@echo github org: ${REPO_ORG}
	@echo github repo: ${REPO_NAME}
	@echo hostname: ${HOST}

######################################
## THIS IS TEST DATA NOT FOR GENESIS##

ifeq ($(NAMESPACE), alice)
NAMESPACE = alice
ACC = 402e9aaf54ca8c39bab641b0c9829070
AUTH = 3dfca19b9914d78ec0c3d04c486e7baa402e9aaf54ca8c39bab641b0c9829070
IP = 142.93.191.147
MNEM = average list time circle item couch resemble tool diamond spot winter pulse cloth laundry slice youth payment cage neutral bike armor balance way ice
endif

ifeq ($(NAMESPACE), bob)
ACC = 5e7891b719c305941e62867ffe730f48
AUTH = 200eaeef43a4e938bc6ff34318d2559d5e7891b719c305941e62867ffe730f48
IP = 167.71.84.248
MNEM = owner city siege lamp code utility humor inherit plug tuna orchard lion various hill arrow hold venture biology aisle talent desert expand nose city
endif

ifeq ($(NAMESPACE), carol)
ACC = b2f38139f75a271fd8f8fae4a87c2679
AUTH = 4b964ff86508164652cce32107cd7107b2f38139f75a271fd8f8fae4a87c2679
IP = 104.131.56.224
MNEM = motor employ crumble add original wealth spray lobster eyebrow title arrive hazard machine snake east dish alley drip mail erupt source dinner hobby day
endif

ifeq ($(NAMESPACE), dave)
ACC = 027c83aeb3b9c085f5a1506b418d08cf
AUTH = 54cf55ab1aff7b757af9a6b07dba6011027c83aeb3b9c085f5a1506b418d08cf
IP = 104.131.32.62
MNEM = advice organ wage sick travel brief leave renew utility host roast barely can noble cheap cancel rotate series method inside damage beach tomorrow power
endif

##########################


# set up the environment
install: deps compile
compile: stdlib bins
# pipelines for genesis ceremony
register: clear blocks init add-proofs keys register
# do genesis
genesis: build-genesis waypoint toml peers



deps:
	sudo apt-get update
	sudo apt-get -y install build-essential cmake clang llvm libgmp-dev zip secure-delete
		## TODO: Cargo is not getting set to path. This next line doesn't run.
	sudo curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y && source $$HOME/.cargo/env
	
stdlib:
	cd ~/libra/language/stdlib && cargo run --release

bins:
	cd ~/libra && cargo build -p libra-node --release
	cd ~/libra && cargo build -p libra-management --release
	cd ~/libra && cargo build -p miner --release
	sudo cp -f ~/libra/target/release/libra-management /usr/local/bin/libra-management
	sudo cp -f ~/libra/target/release/libra-node /usr/local/bin/libra-node
	sudo cp -f ~/libra/target/release/miner /usr/local/bin/miner

all-bins:
	cd ~/libra && cargo build --all --bins --release --exclude cluster-test

keygen:
	cd ~/libra/miner && miner keygen

miner-genesis:
	cd ~/libra/miner && NODE_ENV=${NODE_ENV} miner start
	cp -f ~/libra/miner/blocks/block_0.json ${DATA_PATH}

# CONFIGURE GITHUB FOR TEST
#Authorization: token be83c3cc74a3a9517e0685b76fe27b08ccec7a0e"

github: 
	curl -X POST -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/orgs/${REPO_ORG}/repos -d '{"name":"${REPO_NAME}", "private": "true", "auto_init": "true"}'

#GENESIS CEREMONY

clear:
ifdef TEST
	rm -rf libradb *.seed_peers.toml node.configs.toml genesis.blob key_store.json
endif

blocks:
	@echo fixtures
ifdef TEST
	echo ${NAMESPACE}
	if test -f ${DATA_PATH}/blocks/block_0.json; then \
		rm block_0.json; \
	fi 
	cp ~/libra/fixtures/miner.toml.${NAMESPACE} ${DATA_PATH}/miner.toml

ifeq (${NODE_ENV}, test)
	cp ~/libra/fixtures/block_0.json.test.${NAMESPACE} ${DATA_PATH}/blocks/block_0.json
else
	cp ~/libra/fixtures/block_0.json.prod.${NAMESPACE} ${DATA_PATH}/blocks/block_0.json
endif
endif

init:
	libra-management initialize \
	--path=${DATA_PATH} \
	--namespace=${NAMESPACE}

layout:
	libra-management set-layout \
	--backend 'backend=github;owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}github_token.txt;namespace=common' \
	--path=set_layout_prod.toml

add-proofs:
	libra-management mining \
	--path-to-genesis-pow ${DATA_PATH}blocks/block_0.json \
	--backend 'backend=github;owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}github_token.txt;namespace=${NAMESPACE}'

keys:
	libra-management operator-key \
	--local 'backend=disk;path=${DATA_PATH}key_store.json;namespace=${NAMESPACE}' \
	--remote 'backend=github;owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}github_token.txt;namespace=${NAMESPACE}'

register:
	libra-management validator-config \
	--owner-address ${ACC} \
	--validator-address "/ip4/${IP}/tcp/6180" \
	--fullnode-address "/ip4/${IP}/tcp/6179" \
	--local 'backend=disk;path=${DATA_PATH}key_store.json;namespace=${NAMESPACE}' \
	--remote 'backend=github;owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}github_token.txt;namespace=${NAMESPACE}'

build-genesis:
	NODE_ENV='${NODE_ENV}' libra-management genesis \
	--backend 'backend=github;owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}github_token.txt' \
	--path ${DATA_PATH}genesis.blob

waypoint:
	NODE_ENV='${NODE_ENV}' libra-management create-waypoint \
	--remote 'backend=github;owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}github_token.txt;namespace=common' \
	--local 'backend=disk;path=${DATA_PATH}key_store.json;namespace=${NAMESPACE}'

toml:
	libra-management config \
	--validator-address "/ip4/${IP}/tcp/6180" \
	--validator-listen-address "/ip4/0.0.0.0/tcp/6180" \
	--backend 'backend=disk;path=${DATA_PATH}key_store.json;namespace=${NAMESPACE}' \
	--fullnode-address "/ip4/${IP}/tcp/6179" \
	--fullnode-listen-address "/ip4/0.0.0.0/tcp/6179"

peers:
	cp -f seed_peers.toml backup.seed_peers.toml
	libra-management seeds --genesis-path genesis.blob

start:
	# run in foreground. Only for testing, use a daemon for net.
	libra-node --config ${DATA_PATH}node.configs.toml

daemon:
	sudo cp -f ~/libra/validator_utils/libra-node.service /lib/systemd/system/
	# cp -f miner.service /lib/systemd/system/
	if test -d ~/logs; then \
		echo "WIPING SYSTEMD LOGS"; \
		rm -rf ~/logs*; \
	fi 

	sudo mkdir ~/logs
	sudo touch ~/logs/output.log
	sudo chmod 777 ~/logs
	sudo chmod 777 ~/logs/output.log


	sudo systemctl daemon-reload
	sudo systemctl stop libra-node.service
	sudo systemctl start libra-node.service
	sudo sleep 2
	sudo systemctl status libra-node.service &
	sudo tail -f ~/logs/output.log


wipe: 
	shred ~/.bash_history
	srm ~/.bash_history
	history -c
	smem
	sswap
	# sfill <mountpoint>


# datadog:
# 	DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=xxxxxxxxxx DD_SITE="datadoghq.com" bash -c \"$$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)\"
# 	# mkdir /etc/datadog-agent/conf.d/libra.d/
# 	cp datadog_config.yaml /etc/datadog-agent/conf.d/libra.d/conf.yaml
# 	service datadog-agent start
