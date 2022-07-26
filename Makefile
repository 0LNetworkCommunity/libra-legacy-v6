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

# Account settings
ifndef ACC
ACC=$(shell toml get ${DATA_PATH}/0L.toml profile.account | tr -d '"')
endif
IP=$(shell toml get ${DATA_PATH}/0L.toml profile.ip)

# Github settings
GITHUB_TOKEN = $(shell cat ${DATA_PATH}/github_token.txt || echo NOT FOUND)

REPO_ORG = OLSF
REPO_NAME = genesis-registration
CARGO_ARGS = --release

# testnet automation settings
ifeq (${TEST}, y)
REPO_NAME = dev-genesis
MNEM = $(shell cat ol/fixtures/mnemonic/${NS}.mnem)
CARGO_ARGS = --locked # just keeping this from doing --release mode, while in testnet mode.
GITHUB_USER = OLSF
endif

# Registration params
REMOTE = 'backend=github;repository_owner=${GITHUB_USER};repository=${REPO_NAME};token=${DATA_PATH}/github_token.txt;namespace=${ACC}'

GENESIS_REMOTE = 'backend=github;repository_owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}/github_token.txt;namespace=${ACC};branch=master'

LOCAL = 'backend=disk;path=${DATA_PATH}/key_store.json;namespace=${ACC}'

RELEASE_URL=https://github.com/OLSF/libra/releases/download

ifndef RELEASE
RELEASE=$(shell curl -sL https://api.github.com/repos/OLSF/libra/releases/latest | jq -r '.assets[].browser_download_url')
endif

BINS=db-backup db-backup-verify db-restore diem-node tower ol txs stdlib

ifndef V
V=previous
endif


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
# Build and install genesis tool, diem-node, and tower
# NOTE: stdlib is built for cli bindings

	cargo build -p diem-node -p tower -p backup-cli -p ol -p txs -p onboard ${CARGO_ARGS}

stdlib:
# cargo run ${CARGO_ARGS} -p diem-framework
	cargo run ${CARGO_ARGS} -p diem-framework -- --create-upgrade-payload
	sha256sum language/diem-framework/staged/stdlib.mv
  

install: mv-bin bin-path
	mkdir ${USER_BIN_PATH} | true

	cp -f ${SOURCE}/target/release/tower ${USER_BIN_PATH}/tower
	cp -f ${SOURCE}/target/release/diem-node ${USER_BIN_PATH}/diem-node
	cp -f ${SOURCE}/target/release/db-restore ${USER_BIN_PATH}/db-restore
	cp -f ${SOURCE}/target/release/db-backup ${USER_BIN_PATH}/db-backup
	cp -f ${SOURCE}/target/release/db-backup-verify ${USER_BIN_PATH}/db-backup-verify
	cp -f ${SOURCE}/target/release/ol ${USER_BIN_PATH}/ol
	cp -f ${SOURCE}/target/release/txs ${USER_BIN_PATH}/txs
	cp -f ${SOURCE}/target/release/onboard ${USER_BIN_PATH}/onboard

bin-path:
	@if (cat ~/.bashrc | grep ${USER_BIN_PATH}) ; then \
		echo "OK .bashrc correctly configured with PATH=~/bin" ; \
	else \
		echo -n "WARN Your .bashrc doesn't seem to have ~/bin as a search path. Append .bashrc with PATH=~/bin:$$PATH ? (y/n) " ; \
		read answer ; \
		if [ "$$answer" != "$${answer#[Yy]}" ] ; then \
			echo adding to PATH ; \
			echo PATH=~/bin:$$PATH >> ~/.bashrc ; \
		fi ; \
	fi

mv-bin:
	@if which ol | grep /usr/local/bin  ; then \
		echo -n "You have executables in a deprecated location. Move the executables from /usr/local/bin to ~/bin? (y/n) " ; \
		read answer ; \
		if [ "$$answer" != "$${answer#[Yy]}" ] ; then \
			echo copy all bins ; \
			mkdir ~/bin/ | true ; \
			mv /usr/local/bin/* ${USER_BIN_PATH} ; \
		fi ; \
	fi

reset:
	onboard val --skip-mining --upstream-peer http://167.172.248.37/ --source-path ~/libra

backup:
	cd ~ && rsync -av --exclude db/ --exclude logs/ ~/.0L/* ~/0L_backup_$(shell date +"%m-%d-%y-%T")

confirm:
	@read -p "Continue (y/n)?" CONT; \
	if [ "$$CONT" = "y" ]; then \
		echo "deleting...."; \
	else \
		exit 1; \
	fi \


danger-restore:
	cp ${HOME}/0L_backup/github_token.txt ${HOME}/.0L/ | true
	cp ${HOME}/0L_backup/autopay_batch.json ${HOME}/.0L/ | true
	rsync -rtv ${HOME}/0L_backup/blocks/ ${HOME}/.0L/blocks | true
	rsync -rtv ${HOME}/0L_backup/vdf_proofs/ ${HOME}/.0L/vdf_proofs | true
	rsync -rtv ${HOME}/0L_backup/set_layout.toml ${HOME}/.0L/ | true


	


clear-prod-db:
	@echo WIPING DB
	make confirm
	rm -rf ${DATA_PATH}/db | true

reset-safety:
	@echo CLEARING SAFETY RULES IN KEY_STORE.JSON
	jq -r '.["${ACC}-oper/safety_data"].value = { "epoch": 0, "last_voted_round": 0, "preferred_round": 0, "last_vote": null }' ${DATA_PATH}/key_store.json > ${DATA_PATH}/temp_key_store && mv ${DATA_PATH}/temp_key_store ${DATA_PATH}/key_store.json
	

move-test:
	cd language/move-lang/functional-tests/ && cargo t 0L
#### GENESIS BACKEND SETUP ####
init-backend: 
	curl -X POST -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/orgs/${REPO_ORG}/repos -d '{"name":"${REPO_NAME}", "private": "true", "auto_init": "true"}'

layout:
	cargo run -p diem-genesis-tool ${CARGO_ARGS} -- set-layout \
	--shared-backend 'backend=github;repository_owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}/github_token.txt;namespace=common' \
	--path ./ol/devnet/set_layout_${NODE_ENV}.toml

root:
		cargo run -p diem-genesis-tool ${CARGO_ARGS} -- diem-root-key \
		--validator-backend ${LOCAL} \
		--shared-backend ${REMOTE}

treasury:
		cargo run -p diem-genesis-tool ${CARGO_ARGS} --  treasury-compliance-key \
		--validator-backend ${LOCAL} \
		--shared-backend ${REMOTE}


#### GENESIS REGISTRATION ####
gen-fork-repo:
	cargo run -p diem-genesis-tool ${CARGO_ARGS} -- create-repo \
	--repo-name ${REPO_NAME} \
	--repo-owner ${REPO_ORG} \
	--shared-backend ${REMOTE}

gen-make-pull:
	cargo run -p diem-genesis-tool ${CARGO_ARGS} -- create-repo \
	--repo-name ${REPO_NAME} \
	--repo-owner ${REPO_ORG} \
	--shared-backend ${GENESIS_REMOTE} \
	--pull-request-user ${GITHUB_USER}

gen-delete-fork:
	cargo run -p diem-genesis-tool ${CARGO_ARGS} -- create-repo \
	--repo-name ${REPO_NAME} \
	--repo-owner ${REPO_ORG} \
	--shared-backend ${GENESIS_REMOTE} \
	--delete-repo-user ${GITHUB_USER}

gen-onboard:
	cargo run -p onboard ${CARGO_ARGS} -- val --genesis-ceremony

gen-reset:
	cargo run -p onboard ${CARGO_ARGS} -- val --genesis-ceremony --skip-mining

gen-register:

	@echo the OPER initializes local accounts and submit pubkeys to github
	ACC=${ACC}-oper make oper-key

	@echo The OWNERS initialize local accounts and submit pubkeys to github, and mining proofs
	make owner-key add-proofs

	@echo OWNER *assigns* an operator.
	OPER=${ACC}-oper make assign

	@echo OPER send signed transaction with configurations for *OWNER* account
	ACC=${ACC}-oper OWNER=${ACC} IP=${IP} make reg

# TODO: implement the forking workflow for dev genesis?
# @echo Making pull request to genesis coordination repo
# make gen-make-pull

init-test:
	echo ${MNEM} | head -c -1 | cargo run -p diem-genesis-tool --  init --path=${DATA_PATH} --namespace=${ACC}

init:
	cargo run -p diem-genesis-tool ${CARGO_ARGS} -- init --path=${DATA_PATH} --namespace=${ACC}
# OWNER does this
# Submits proofs to shared storage
add-proofs:
	cargo run -p diem-genesis-tool ${CARGO_ARGS} -- mining \
	--path-to-genesis-pow ${DATA_PATH}/vdf_proofs/proof_0.json \
  --path-to-account-json ${DATA_PATH}/account.json \
	--shared-backend ${REMOTE}

# OPER does this
# Submits operator key to github, and creates local OPERATOR_ACCOUNT
oper-key:
	cargo run -p diem-genesis-tool ${CARGO_ARGS} -- operator-key \
	--validator-backend ${LOCAL} \
	--shared-backend ${REMOTE}

# OWNER does this
# Submits operator key to github, does *NOT* create the OWNER_ACCOUNT locally
owner-key:
	cargo run -p diem-genesis-tool ${CARGO_ARGS} --  owner-key \
	--validator-backend ${LOCAL} \
	--shared-backend ${REMOTE}

# OWNER does this
# Links to an operator on github, creates the OWNER_ACCOUNT locally
assign: 
	cargo run -p diem-genesis-tool ${CARGO_ARGS} --  set-operator \
	--operator-name ${OPER} \
	--shared-backend ${REMOTE}

# OPER does this
# Submits signed validator registration transaction to github.
reg:
	cargo run -p diem-genesis-tool ${CARGO_ARGS} --  validator-config \
	--owner-name ${OWNER} \
	--chain-id ${CHAIN_ID} \
	--validator-address "/ip4/${IP}/tcp/6180" \
	--fullnode-address "/ip4/${IP}/tcp/6179" \
	--validator-backend ${LOCAL} \
	--shared-backend ${REMOTE}
	

# Helpers to verify the local state.
verify:
	cargo run -p diem-genesis-tool ${CARGO_ARGS} --  verify \
	--validator-backend ${LOCAL}
# --genesis-path ${DATA_PATH}/genesis.blob

verify-gen:
	cargo run -p diem-genesis-tool ${CARGO_ARGS} --  verify \
	--validator-backend ${LOCAL} \
	--genesis-path ${DATA_PATH}/genesis.blob

genesis: stdlib
	cargo run -p diem-genesis-tool ${CARGO_ARGS} -- files \
	--chain-id ${CHAIN_ID} \
	--validator-backend ${LOCAL} \
	--data-path ${DATA_PATH} \
	--namespace ${ACC}-oper \
	--repo ${REPO_NAME} \
	--github-org ${REPO_ORG} \
  --layout-path ${DATA_PATH}/set_layout.toml \
	--val-ip-address ${IP}


	sha256sum ${DATA_PATH}/genesis.blob

#### NODE MANAGEMENT ####
start:
# run in foreground. Only for testing, use a daemon for net.
	RUST_LOG=error cargo run -p diem-node -- --config ${DATA_PATH}/validator.node.yaml

daemon:
	mkdir -p ~/.config/systemd/user/
	cp ./ol/util/diem-node.service ~/.config/systemd/user/

	@if test -d ~/logs; then \
		echo "WIPING SYSTEMD LOGS"; \
		rm -rf ~/logs*; \
	fi 

	mkdir ~/logs
	touch ~/logs/node.log

	systemctl --user daemon-reload
	systemctl --user stop diem-node.service
	systemctl --user start diem-node.service
	sleep 2
	
	systemctl --user status diem-node.service &
	tail -f ~/logs/node.log

#### TEST SETUP ####

clear:
ifeq (${TEST}, y)

	@if test -d ${DATA_PATH}; then \
		cd ${DATA_PATH} && rm -rf libradb *.yaml *.blob *.json db *.toml; \
	fi
	@if test -d ${DATA_PATH}/vdf_proofs; then \
		rm -f ${DATA_PATH}/vdf_proofs/*.json; \
	fi
endif


fixture-stdlib:
	make stdlib
	cp language/diem-framework/staged/stdlib.mv ol/fixtures/stdlib/fresh_stdlib.mv

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
		echo Creating Directories; \
		mkdir ${DATA_PATH}; \
		mkdir -p ${DATA_PATH}/vdf_proofs/; \
	fi

	@if test ! -d ${DATA_PATH}/vdf_proofs; then \
		echo Creating Directories; \
		mkdir -p ${DATA_PATH}/vdf_proofs/; \
	fi

	@if test -f ${DATA_PATH}/vdf_proofs/proof_0.json; then \
		rm ${DATA_PATH}/vdf_proofs/proof_0.json; \
	fi 

	@if test -f ${DATA_PATH}/0L.toml; then \
		rm ${DATA_PATH}/0L.toml; \
	fi 

# skip miner configuration with fixtures
	cp ./ol/fixtures/configs/${NS}.toml ${DATA_PATH}/0L.toml
# skip mining proof zero with fixtures
	cp ./ol/fixtures/vdf_proofs/${NODE_ENV}/${NS}/proof_0.json ${DATA_PATH}/vdf_proofs/proof_0.json
# place a mock autopay.json in root
	cp ./ol/fixtures/autopay/${NS}.autopay_batch.json ${DATA_PATH}/autopay_batch.json
# place a mock account.json in root, used as template for onboarding
	cp ./ol/fixtures/account/${NS}.account.json ${DATA_PATH}/account.json
# replace the set_layout
	cp ./ol/devnet/set_layout_test.toml ${DATA_PATH}/set_layout.toml
endif


#### HELPERS ####
set-waypoint:
	@if test -f ${DATA_PATH}/key_store.json; then \
		jq -r '. | with_entries(select(.key|match("-oper/waypoint";"i")))[].value' ${DATA_PATH}/key_store.json > ${DATA_PATH}/client_waypoint; \
		jq -r '. | with_entries(select(.key|match("-oper/genesis-waypoint";"i")))[].value' ${DATA_PATH}/key_store.json > ${DATA_PATH}/genesis_waypoint.txt; \
	fi

	cargo r -p ol -- init --update-waypoint --waypoint $(shell cat ${DATA_PATH}/client_waypoint)

	@echo client_waypoint:
	@cat ${DATA_PATH}/client_waypoint

client: set-waypoint
# ifeq (${TEST}, y)
# 	 echo ${MNEM} | cargo run -p cli -- -u http://localhost:8080 --waypoint $$(cat ${DATA_PATH}/client_waypoint) --chain-id ${CHAIN_ID}
# else
	cargo run -p cli -- -u http://localhost:8080 --waypoint $$(cat ${DATA_PATH}/client_waypoint) --chain-id ${CHAIN_ID}
# endif



keygen:
	cd ${DATA_PATH} && onboard keygen

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
	systemctl --user stop diem-node.service

debug:
	make smoke-onboard <<< $$'${MNEM}'
 

#### TESTNET #####
# The testnet is started using the same tools as genesis to have a faithful reproduction of a network from a clean slate.

# 1. The first thing necessary is initializing testnet genesis validators. All genesis nodes need to set up environment variables for their namespace/personas e.g. NS=alice. Also the TEST=y mode must be set, as well as a chain environment e.g. NODE_ENV=test. These settings must be done manually, preferably in .bashrc

# 2. Next those validators will register config data to a github repo OLSD/dev-genesis. Note: there could be github http errors, if validators attempt to write the same resource simultaneously

# THESE STEPS ARE ACHIEVED WITH `make testnet-register`

# 3. Wait. All genesis nodes need to complete registration. Otherwise buidling a genesis.blob (the first block), will fail.
# 4. Each genesis node builds the genesis file locally, and submits to the github repo. (this remote genesis file is what subsequent non-genesis validators will use to bootstrap their db).
# 5. Genesis validators can start their nodes.

# THESE STEPS ARE ACHIEVED WITH  `make testnet`


# 6. Assuming there is progress in the block production, subsequent validators can join.

# THIS IS ACHIEVED WITH: testnet-onboard


#### 1. TESTNET SETUP ####

testnet-init: clear fix
#  REQUIRES there is a genesis.blob in the fixtures/genesis/<version> you are testing
	MNEM='${MNEM}' cargo run -p onboard -- val --skip-mining --chain-id 1 --genesis-ceremony

# Do the genesis ceremony registration, this includes the step testnet-validator-init-wizard
testnet-register:  testnet-init gen-register
# Do a dev genesis on each node after EVERY NODE COMPLETED registration.

# Makes the gensis file on each genesis validator, AND SAVES TO GITHUB so that other validators can be onboarded after genesis.
testnet-genesis: genesis set-waypoint
	cargo run -p diem-genesis-tool ${CARGO_ARGS} -- create-repo \
	--publish-genesis ${DATA_PATH}/genesis.blob \
	--shared-backend ${GENESIS_REMOTE}

	cargo run -p diem-genesis-tool ${CARGO_ARGS} -- create-repo \
	--publish-genesis ${DATA_PATH}/genesis_waypoint.txt \
	--shared-backend ${GENESIS_REMOTE}

#### 2. TESTNET START ####

# Do this to restart the network with new code. Assumes a registration has been completed, and the genesis validators are unchanged. If new IP addresses or number of genesis nodes changed, you must RERUN SETUP below.
# - builds stdlib from source
# - clears many of the home files
# - adds fixtures
# - initializes node configs
# - rebuids genesis files and shares to github genesis repo
# - starts node in validator mode
testnet: clear fix testnet-init testnet-genesis start

# For subsequent validators joining the testnet. This will fetch the genesis information saved
testnet-onboard: clear fix
	MNEM='${MNEM}' cargo run -p onboard -- val --github-org OLSF --repo dev-genesis --chain-id 1
# start a node with fullnode.node.yaml configs
	cargo r -p diem-node -- -f ~/.0L/fullnode.node.yaml



####### SWARM ########

sw: sw-build sw-start sw-init

## Build
sw-stdlib:
	cd ${SOURCE} && cargo run -p diem-framework ${CARGO_ARGS}

sw-build:
	cargo build -p diem-node -p diem-swarm -p cli ${CARGO_ARGS}

## Swarm
sw-start:
	cd ${SOURCE} && cargo run ${CARGO_ARGS} -p diem-swarm -- --diem-node target/debug/diem-node -c ${DATA_PATH}/swarm_temp -n 1 -s --cli-path ${SOURCE}/target/debug/cli

sw-init:
	cd ${SOURCE} && cargo r ${CARGO_ARGS} -p ol -- --swarm-path ${DATA_PATH}/swarm_temp/ --swarm-persona alice init --source-path ~/libra

sw-miner:
		cd ${SOURCE} && cargo r -p tower -- --swarm-path ${DATA_PATH}/swarm_temp --swarm-persona alice start

sw-query:
		cd ${SOURCE} && cargo r -p ol -- --swarm-path ${DATA_PATH}/swarm_temp --swarm-persona alice query --txs
sw-tx:
		cd ${SOURCE} && cargo r -p txs -- --swarm-path ${DATA_PATH}/swarm_temp --swarm-persona alice wallet -s


##### FORK TESTS #####

fork: stdlib fork-genesis fork-config fork-start

EPOCH_HEIGHT = $(shell cargo r -p ol -- query --epoch | cut -d ":" -f 2)

epoch:
	cargo r -p ol -- query --epoch
	echo ${EPOCH_HEIGHT}

fork-backup:
		rm -rf ${SOURCE}/ol/devnet/snapshot/*
		cargo run -p backup-cli --bin db-backup -- one-shot backup --backup-service-address http://localhost:6186 state-snapshot --state-version ${EPOCH_HEIGHT} local-fs --dir ${SOURCE}/ol/devnet/snapshot/

# Make genesis file
fork-genesis:
		cargo run -p ol-genesis-tools -- --genesis ${DATA_PATH}/genesis_from_snapshot.blob --snapshot ${SOURCE}/ol/devnet/snapshot/state_ver*

# Use onboard to create all node files
fork-config:
	cargo run -p onboard -- fork -u http://167.172.248.37 --prebuilt-genesis ${DATA_PATH}/genesis_from_snapshot.blob

# start node from files
fork-start:
	rm -rf ~/.0L/db
	cargo run -p libra-node -- --config ~/.0L/validator.node.yaml

##### UTIL #####
TAG=$(shell git tag -l "previous")
clean-tags:
	git push origin --delete ${TAG}
	git tag -d ${TAG}
	