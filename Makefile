#### VARIABLES ####
SHELL=/usr/bin/env bash
DATA_PATH = ${HOME}/.0L
USER_BIN_PATH = ${HOME}/bin

# Chain settings
CHAIN_ID = 1

ifndef SOURCE
MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR := $(dir $(MAKEFILE_PATH))
SOURCE=${MAKEFILE_DIR}
endif

ifndef V
V=previous
endif

# Account settings
ifndef ACC
ACC=$(shell toml get ${DATA_PATH}/0L.toml profile.account | tr -d '"')
endif
IP=$(shell toml get ${DATA_PATH}/0L.toml profile.ip)

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

RELEASE_URL=https://github.com/OLSF/libra/releases/download

ifndef RELEASE
RELEASE=$(shell curl -sL https://api.github.com/repos/OLSF/libra/releases/latest | jq -r '.assets[].browser_download_url')
endif

BINS= db-backup db-backup-verify db-restore libra-node miner ol txs stdlib



##### DEPENDENCIES #####
deps:
	. ./ol/util/setup.sh

download: web-files
	@for b in ${RELEASE} ; do \
		echo $$b | rev | cut -d"/" -f1 | rev ; \
		curl  --progress-bar --create-dirs -o ${USER_BIN_PATH}/$$(echo $$b | rev | cut -d"/" -f1 | rev) -L $$b ; \
		echo 'downloaded to ${USER_BIN_PATH}' ; \
		chmod 744 ${USER_BIN_PATH}/$$(echo $$b | rev | cut -d"/" -f1 | rev) ;\
	done

web-files: 
	curl -L --progress-bar --create-dirs -o ${DATA_PATH}/web-monitor.tar.gz https://github.com/OLSF/libra/releases/latest/download/web-monitor.tar.gz
	mkdir ${DATA_PATH}/web-monitor | true
	tar -xf ${DATA_PATH}/web-monitor.tar.gz --directory ${DATA_PATH}/web-monitor

download-release:
	@for b in ${BINS} ; do \
		echo $$b ; \
		curl --create-dirs -o ${DATA_PATH}/release-${RELEASE}/$$b -L ${RELEASE_URL}/${RELEASE}/$$b ; \
		chmod 744 ${DATA_PATH}/release-${RELEASE}/$$b ; \
		cp ${DATA_PATH}/release-${RELEASE}/$$b  ${USER_BIN_PATH}/$$b ; \
	done

uninstall:
	@for b in ${BINS} ; do \
		rm ${USER_BIN_PATH}/$$b ; \
	done

bins: stdlib
# Build and install genesis tool, libra-node, and miner
# NOTE: stdlib is built for cli bindings

	cargo build -p libra-node -p miner -p backup-cli -p ol -p txs -p onboard --release

stdlib:
	cargo run --release -p stdlib
	cargo run --release -p stdlib -- --create-upgrade-payload
	sha256sum language/stdlib/staged/stdlib.mv
  

install:
	mkdir ${USER_BIN_PATH} | true

	sudo cp -f ${SOURCE}/target/release/miner ${USER_BIN_PATH}/miner
	sudo cp -f ${SOURCE}/target/release/libra-node ${USER_BIN_PATH}/libra-node
	sudo cp -f ${SOURCE}/target/release/db-restore ${USER_BIN_PATH}/db-restore
	sudo cp -f ${SOURCE}/target/release/db-backup ${USER_BIN_PATH}/db-backup
	sudo cp -f ${SOURCE}/target/release/db-backup-verify ${USER_BIN_PATH}/db-backup-verify
	sudo cp -f ${SOURCE}/target/release/ol ${USER_BIN_PATH}/ol
	sudo cp -f ${SOURCE}/target/release/txs ${USER_BIN_PATH}/txs
	sudo cp -f ${SOURCE}/target/release/onboard ${USER_BIN_PATH}/onboard

## Do below as user: val
path:
	@if (cat ~/.bashrc | grep '~/bin:') ; then \
		echo PATH already contains ~/bin ; \
	else \
		echo adding to PATH ; \
		echo PATH=~/bin:$$PATH >> ~/.bashrc ; \
	fi

mv-bin:
	@if which ol | grep /usr/local/bin/ ; then \
		echo copy all bins ; \
		mkdir ~/bin/ | true ; \
		mv /usr/local/bin/* ~/bin/ ; \
	fi

reset:
	onboard val --skip-mining --upstream-peer http://167.172.248.37/ --source-path ~/libra


backup:
	cd ~ && rsync -av --exclude db/ --exclude logs/ ~/.0L ~/0L_backup_$(shell date +"%m-%d-%y")

#### GENESIS BACKEND SETUP ####
init-backend: 
	curl -X POST -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/orgs/${REPO_ORG}/repos -d '{"name":"${REPO_NAME}", "private": "true", "auto_init": "true"}'

layout:
	cargo run -p libra-genesis-tool --release -- set-layout \
	--shared-backend 'backend=github;repository_owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}/github_token.txt;namespace=common' \
	--path ./ol/util/set_layout_${NODE_ENV}.toml

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
# export ACC=$(shell toml get ${DATA_PATH}/0L.toml profile.account)
	@echo Initializing from ${DATA_PATH}/0L.toml with account:
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

	@if test -f ${DATA_PATH}/0L.toml; then \
		rm ${DATA_PATH}/0L.toml; \
	fi 

# skip miner configuration with fixtures
	cp ./ol/fixtures/configs/${NS}.toml ${DATA_PATH}/0L.toml
# skip mining proof zero with fixtures
	cp ./ol/fixtures/blocks/${NODE_ENV}/${NS}/block_0.json ${DATA_PATH}/blocks/block_0.json
# place a mock autopay.json in root
	cp ./ol/fixtures/autopay/${NS}.autopay_batch.json ${DATA_PATH}/autopay_batch.json
# place a mock account.json in root, used as template for onboarding
	cp ./ol/fixtures/account/${NS}.account.json ${DATA_PATH}/account.json
endif

fix-genesis:
	cp ./ol/devnet/genesis/${V}/genesis.blob ${DATA_PATH}/
	cp ./ol/devnet/genesis/${V}/genesis_waypoint ${DATA_PATH}/


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



keygen:
	cd ${DATA_PATH} && miner keygen

# miner-genesis:
# 	cd ${DATA_PATH} && NODE_ENV=${NODE_ENV} miner genesis

# reset: stop clear fixtures init keys  daemon

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

debug:
	make smoke-onboard <<< $$'${MNEM}'
 

##### DEVNET TESTS #####

devnet: clear fix fix-genesis dev-wizard start
# runs a smoke test from fixtures. 
# Uses genesis blob from fixtures, assumes 3 validators, and test settings.
# This will work for validator nodes alice, bob, carol, and any fullnodes; 'eve'

dev-join: clear fix fix-genesis dev-wizard
# REQUIRES MOCK GIT INFRASTRUCTURE: OLSF/dev-genesis OLSF/dev-epoch-archive
# see `devnet-archive` below 
# We want to simulate the onboarding/new validator fetching genesis files from the mock archive: dev-genesis-archive

# mock restore backups from dev-epoch-archive
	rm -rf ~/.0L/restore
# restore from MOCK archive OLSF/dev-epoch-archive
	cargo r -p ol -- restore
# start a node with fullnode.node.yaml configs
	make start-full

dev-wizard:
#  REQUIRES there is a genesis.blob in the fixtures/genesis/<version> you are testing
	MNEM='${MNEM}' cargo run -p onboard -- val --skip-mining --skip-fetch-genesis --chain-id 1 --github-org OLSF --repo dev-genesis --upstream-peer http://161.35.13.169:8080

#### DEVNET INFRASTRUCTURE ####
# usually do this on Alice, which has the dev-epoch-archive repo, and dev-genesis

# Do the ceremony: and also save the genesis fixtures, needs to happen before fix.
dev-register: clear fix register
# Do a dev genesis on each node after EVERY NODE COMPLETED registration.
dev-genesis: genesis dev-save-genesis fix-genesis

# Save the files to mock infrastructure i.e. devnet github
dev-infra: dev-backup-archive dev-commit

dev-save-genesis: set-waypoint
	rsync -a ${DATA_PATH}/genesis* ${SOURCE}/ol/devnet/genesis/${V}/
	git add ${SOURCE}/ol/devnet/genesis/${V}/

dev-backup-archive:
	cd ${HOME}/dev-epoch-archive && make devnet-backup

dev-commit:
	git commit -a -m "save genesis fixtures to ${V}" | true
	git push | true


TAG=$(shell git tag -l "previous")
clean-tags:
	git push origin --delete ${TAG}
	git tag -d ${TAG}
	