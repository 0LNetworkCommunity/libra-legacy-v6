#### VARIABLES ####
SHELL=/usr/bin/env bash
DATA_PATH = ${HOME}/.0L

# Chain settings
CHAIN_ID = 1

ifndef SOURCE
SOURCE=${HOME}/libra
endif

ifndef V
V=previous
endif

# Account settings
ifndef ACC
ACC=$(shell toml get ${DATA_PATH}/miner.toml profile.account | tr -d '"')
endif
IP=$(shell toml get ${DATA_PATH}/miner.toml profile.ip)

# Github settings
GITHUB_TOKEN = $(shell cat ${DATA_PATH}/github_token.txt || echo NOT FOUND)
REPO_ORG = OLSF

ifeq (${TEST}, y)
REPO_NAME = dev-genesis
MNEM = $(shell cat ol/fixtures/mnemonic/${NS}.mnem)
else
REPO_NAME = experimental-genesis
NODE_ENV = prod
endif

# Registration params
REMOTE = 'backend=github;repository_owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}/github_token.txt;namespace=${ACC}'
LOCAL = 'backend=disk;path=${DATA_PATH}/key_store.json;namespace=${ACC}'

##### DEPENDENCIES #####
deps:
	. ./util/setup.sh

bins:
# Build and install genesis tool, libra-node, and miner
	cargo run -p stdlib --release

# NOTE: stdlib is built for cli bindings
	cargo build -p libra-node -p miner -p backup-cli -p ol-cli -p txs --release

	sudo cp -f ${SOURCE}/target/release/miner /usr/local/bin/miner
	sudo cp -f ${SOURCE}/target/release/libra-node /usr/local/bin/libra-node
	sudo cp -f ${SOURCE}/target/release/db-restore /usr/local/bin/db-restore
	sudo cp -f ${SOURCE}/target/release/db-backup /usr/local/bin/db-backup
	sudo cp -f ${SOURCE}/target/release/ol_cli /usr/local/bin/ol
	sudo cp -f ${SOURCE}/target/release/txs /usr/local/bin/txs


#### GENESIS BACKEND SETUP ####
init-backend: 
	curl -X POST -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/orgs/${REPO_ORG}/repos -d '{"name":"${REPO_NAME}", "private": "true", "auto_init": "true"}'

layout:
	cargo run -p libra-genesis-tool --release -- set-layout \
	--shared-backend 'backend=github;repository_owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}/github_token.txt;namespace=common' \
	--path ./util/set_layout_${NODE_ENV}.toml

root:
		cargo run -p libra-genesis-tool --release -- libra-root-key \
		--validator-backend ${LOCAL} \
		--shared-backend ${REMOTE}

treasury:
		cargo run -p libra-genesis-tool --release --  treasury-compliance-key \
		--validator-backend ${LOCAL} \
		--shared-backend ${REMOTE}

#### GENESIS REGISTRATION ####
ceremony:
	export NODE_ENV=prod && miner ceremony

register:
# export ACC=$(shell toml get ${DATA_PATH}/miner.toml profile.account)
	@echo Initializing from ${DATA_PATH}/miner.toml with account:
	@echo ${ACC}
	make init

	@echo the OPER initializes local accounts and submit pubkeys to github
	ACC=${ACC}-oper make oper-key

	@echo The OWNERS initialize local accounts and submit pubkeys to github, and mining proofs
	make owner-key add-proofs

	@echo OWNER *assigns* an operator.
	OPER=${ACC}-oper make assign

	@echo OPER send signed transaction with configurations for *OWNER* account
	ACC=${ACC}-oper OWNER=${ACC} IP=${IP} make reg

init-test:
	echo ${MNEM} | head -c -1 | cargo run -p libra-genesis-tool --  init --path=${DATA_PATH} --namespace=${ACC}

init:
	cargo run -p libra-genesis-tool --release --  init --path=${DATA_PATH} --namespace=${ACC}
# OWNER does this
# Submits proofs to shared storage
add-proofs:
	cargo run -p libra-genesis-tool --release --  mining \
	--path-to-genesis-pow ${DATA_PATH}/blocks/block_0.json \
	--shared-backend ${REMOTE}

# OPER does this
# Submits operator key to github, and creates local OPERATOR_ACCOUNT
oper-key:
	cargo run -p libra-genesis-tool --release --  operator-key \
	--validator-backend ${LOCAL} \
	--shared-backend ${REMOTE}

# OWNER does this
# Submits operator key to github, does *NOT* create the OWNER_ACCOUNT locally
owner-key:
	cargo run -p libra-genesis-tool --release --  owner-key \
	--validator-backend ${LOCAL} \
	--shared-backend ${REMOTE}

# OWNER does this
# Links to an operator on github, creates the OWNER_ACCOUNT locally
assign: 
	cargo run -p libra-genesis-tool --release --  set-operator \
	--operator-name ${OPER} \
	--shared-backend ${REMOTE}

# OPER does this
# Submits signed validator registration transaction to github.
reg:
	cargo run -p libra-genesis-tool --release --  validator-config \
	--owner-name ${OWNER} \
	--chain-id ${CHAIN_ID} \
	--validator-address "/ip4/${IP}/tcp/6180" \
	--fullnode-address "/ip4/${IP}/tcp/6179" \
	--validator-backend ${LOCAL} \
	--shared-backend ${REMOTE}
	

# Helpers to verify the local state.
verify:
	cargo run -p libra-genesis-tool --release --  verify \
	--validator-backend ${LOCAL}
# --genesis-path ${DATA_PATH}/genesis.blob

verify-gen:
	cargo run -p libra-genesis-tool --release --  verify \
	--validator-backend ${LOCAL} \
	--genesis-path ${DATA_PATH}/genesis.blob


#### GENESIS  ####
# build-gen:
# 	cargo run -p libra-genesis-tool --release -- genesis \
# 	--chain-id ${CHAIN_ID} \
# 	--shared-backend ${REMOTE} \
# 	--path ${DATA_PATH}/genesis.blob

genesis:
	cargo run -p libra-genesis-tool --release -- files \
	--chain-id ${CHAIN_ID} \
	--validator-backend ${LOCAL} \
	--data-path ${DATA_PATH} \
	--namespace ${ACC}-oper \
	--repo ${REPO_NAME} \
	--github-org ${REPO_ORG}


#### NODE MANAGEMENT ####
start:
# run in foreground. Only for testing, use a daemon for net.
	cargo run -p libra-node -- --config ${DATA_PATH}/validator.node.yaml

# Start a fullnode instead of a validator node
start-full:
	cargo run -p libra-node -- --config ${DATA_PATH}/fullnode.node.yaml

daemon:
# your node's custom libra-node.service lives in ~/.0L. Take the template from libra/util and edit for your needs.
	sudo cp -f ~/.0L/libra-node.service /lib/systemd/system/

	@if test -d ~/logs; then \
		echo "WIPING SYSTEMD LOGS"; \
		sudo rm -rf ~/logs*; \
	fi 

	sudo mkdir ~/logs
	sudo touch ~/logs/node.log
	sudo chmod 777 ~/logs
	sudo chmod 777 ~/logs/node.log

	sudo systemctl daemon-reload
	sudo systemctl stop libra-node.service
	sudo systemctl start libra-node.service
	sudo sleep 2
	sudo systemctl status libra-node.service &
	sudo tail -f ~/logs/node.log

#### TEST SETUP ####

clear:
ifeq (${TEST}, y)

	@if test -d ${DATA_PATH}; then \
		cd ${DATA_PATH} && rm -rf libradb *.yaml *.blob *.json db *.toml; \
	fi
	@if test -d ${DATA_PATH}/blocks; then \
		rm -f ${DATA_PATH}/blocks/*.json; \
	fi
endif


fixture-stdlib:
	make stdlib
	cp language/stdlib/staged/stdlib.mv ol/fixtures/stdlib/fresh_stdlib.mv

#### HELPERS ####
check:
	@echo data path: ${DATA_PATH}
	@echo account: ${ACC}
	@echo github_token: ${GITHUB_TOKEN}
	@echo ip: ${IP}
	@echo node path: ${DATA_PATH}
	@echo github_org: ${REPO_ORG}
	@echo github_repo: ${REPO_NAME}
	@echo env: ${NODE_ENV}
	@echo devnet mode: ${TEST}
	@echo devnet name: ${NS}
	@echo devnet mnem: ${MNEM}


fix:
ifdef TEST
	@echo NAMESPACE: ${NS}
	@echo GENESIS: ${V}
	@if test ! -d ${DATA_PATH}; then \
		echo Creating Directories \
		mkdir ${DATA_PATH}; \
		mkdir -p ${DATA_PATH}/blocks/; \
	fi

	@if test -f ${DATA_PATH}/blocks/block_0.json; then \
		rm ${DATA_PATH}/blocks/block_0.json; \
	fi 

	@if test -f ${DATA_PATH}/miner.toml; then \
		rm ${DATA_PATH}/miner.toml; \
	fi 

# skip  genesis files with fixtures, there may be no version
ifndef SKIP_BLOB
	cp ./ol/fixtures/genesis/${V}/genesis.blob ${DATA_PATH}/
	cp ./ol/fixtures/genesis/${V}/genesis_waypoint ${DATA_PATH}/
endif
# skip miner configuration with fixtures
	cp ./ol/fixtures/configs/${NS}.toml ${DATA_PATH}/miner.toml
# skip mining proof zero with fixtures
	cp ./ol/fixtures/blocks/${NODE_ENV}/${NS}/block_0.json ${DATA_PATH}/blocks/block_0.json
# place a dummy autopay.json in root
	cp ./ol/fixtures/autopay/autopay_batch.json ${DATA_PATH}/autopay.json

endif


#### HELPERS ####
set-waypoint:
	@if test -f ${DATA_PATH}/key_store.json; then \
		jq -r '. | with_entries(select(.key|match("-oper/waypoint";"i")))[].value' ${DATA_PATH}/key_store.json > ${DATA_PATH}/client_waypoint; \
		jq -r '. | with_entries(select(.key|match("-oper/genesis-waypoint";"i")))[].value' ${DATA_PATH}/key_store.json > ${DATA_PATH}/genesis_waypoint; \
	fi

	@echo client_waypoint:
	@cat ${DATA_PATH}/client_waypoint

client: set-waypoint
# ifeq (${TEST}, y)
# 	 echo ${MNEM} | cargo run -p cli -- -u http://localhost:8080 --waypoint $$(cat ${DATA_PATH}/client_waypoint) --chain-id ${CHAIN_ID}
# else
	cargo run -p cli -- -u http://localhost:8080 --waypoint $$(cat ${DATA_PATH}/client_waypoint) --chain-id ${CHAIN_ID}
# endif


stdlib:
	cargo run --release -p stdlib
	cargo run --release -p stdlib -- --create-upgrade-payload
	sha256sum language/stdlib/staged/stdlib.mv
  
keygen:
	cd ${DATA_PATH} && miner keygen

miner-genesis:
	cd ${DATA_PATH} && NODE_ENV=${NODE_ENV} miner genesis

reset: stop clear fixtures init keys genesis daemon

remove-keys:
	make stop
	jq 'del(.["${ACC}-oper/owner", "${ACC}-oper/operator"])' ${DATA_PATH}/key_store.json > ${DATA_PATH}/tmp
	mv ${DATA_PATH}/tmp ${DATA_PATH}/key_store.json

wipe: 
	history -c
	shred ~/.bash_history
	srm ~/.bash_history

stop:
	sudo service libra-node stop


##### DEVNET TESTS #####
# Quickly start a devnet with fixture files. To do a full devnet setup see 'devnet-reset' below

frozen: 
# A QUICK TEST FROM FIXTURES. ASSUMES EVERYTHING WAS SETUP: new genesis-blobs, and mock archive infrastructure. For this see `devnet-archive` below 

# runs a smoke test from fixtures. Uses genesis blob from fixtures, assumes 3 validators, and test settings.

# This will work for validator nodes alice, bob, carol. New onboarded "eve" needs to run devnet-onboard

	MNEM='${MNEM}' make stop clear fix dev-wizard start

dev-wizard:
# starts config for a new miner "eve", uses the devnet github repo for ceremony
# get genesis.blcok from MOCK genesis store OLSF/dev-genesis
	MNEM='${MNEM}' cargo run -p miner -- val-wizard --skip-mining --skip-fetch-genesis --chain-id 1 --github-org OLSF --repo dev-genesis


dev-join: clear fix dev-wizard
# REQUIRES MOCK GIT INFRASTRUCTURE: OLSF/dev-genesis OLSF/dev-epoch-archive
# see `devnet-archive` below 
# We want to simulate the onboarding/new validator fetching genesis files from the mock archive: dev-genesis-archive

# mock restore backups from dev-epoch-archive
	rm -rf ~/.0L/restore
# restore from MOCK archive OLSF/dev-epoch-archive
	cargo r -p ol-cli -- restore
# start a node with fullnode.node.yaml configs
	make start-full

### FULL DEVNET E2E ####

devnet:
	MNEM='${MNEM}' make genesis start

dev-register: clear fix
	echo ${MNEM} | head -c -1 | make register

#### PERSIST THE MOCK ARCHIVES TO DEVNET INFRASTRUCTURE ####

# usually do this on Alice, which has the dev-epoch-archive repo, and dev-genesis
dev-infra: dev-save-genesis dev-backup-archive

dev-save-genesis: set-waypoint
	rsync -a ${DATA_PATH}/genesis* ${SOURCE}/ol/fixtures/genesis/${V}/
	git add ${SOURCE}/ol/fixtures/genesis/${V}/
	git commit -a -m "save genesis fixtures to ${V}" | true
	git push | true

dev-backup-archive:
	cd ${HOME}/dev-epoch-archive && make devnet-backup

