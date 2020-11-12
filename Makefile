#### VARIABLES ####
SHELL=/usr/bin/env bash
DATA_PATH = $$HOME/.0L

# Chain settings
CHAIN_ID = 7
ifndef NODE_ENV
NODE_ENV = test
endif

# Account settings
ifndef ACC
ACC=$(shell toml get ${DATA_PATH}/miner.toml profile.account | tr -d '"')
endif

ifndef IP
ifeq (TEST,y)
IP = 1.2.3.4
else
IP=$(shell toml get ${DATA_PATH}/miner.toml profile.ip)
endif
endif

# Github settings
GITHUB_TOKEN = $(shell cat ${DATA_PATH}/github_token.txt || echo NOT FOUND)
REPO_ORG = OLSF
REPO_NAME = dev-genesis
#experimental network is #7

# Registration params
REMOTE = 'backend=github;repository_owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}/github_token.txt;namespace=${ACC}'
LOCAL = 'backend=disk;path=${DATA_PATH}/key_store.json;namespace=${ACC}'

##### DEPENDENCIES #####
deps:
	#install rust
	curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable -y
	#target is Ubuntu
	sudo apt-get update
	sudo apt-get -y install build-essential cmake clang llvm libgmp-dev pkg-config libssl-dev


bins:
	#TOML cli
	cargo install toml-cli
	#Build and install genesis tool, libra-node, and miner
	cargo build -p libra-genesis-tool --release && sudo cp -f ~/libra/target/release/libra-genesis-tool /usr/local/bin/genesis
	cargo build -p miner --release && sudo cp -f ~/libra/target/release/miner /usr/local/bin/miner
	cargo build -p libra-node --release && sudo cp -f ~/libra/target/release/libra-node /usr/local/bin/libra-node

##### PIPELINES #####
# pipelines for genesis ceremony

#### GENESIS BACKEND SETUP ####
init-backend: 
	curl -X POST -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/orgs/${REPO_ORG}/repos -d '{"name":"${REPO_NAME}", "private": "true", "auto_init": "true"}'

layout:
	genesis set-layout \
	--shared-backend 'backend=github;repository_owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}/github_token.txt;namespace=common' \
	--path ./util/set_layout.toml

root:
		genesis libra-root-key \
		--validator-backend ${LOCAL} \
		--shared-backend ${REMOTE}

treasury:
		genesis treasury-compliance-key \
		--validator-backend ${LOCAL} \
		--shared-backend ${REMOTE}

#### GENESIS REGISTRATION ####
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
	echo ${MNEM} | head -c -1 | genesis init --path=${DATA_PATH} --namespace=${ACC}

init:
	@if test ! -d ${0L_PATH}/node; then \
		mkdir ${0L_PATH}/node; \
	fi 
	genesis init --path=${DATA_PATH} --namespace=${ACC}
# OWNER does this
# Submits proofs to shared storage
add-proofs:
	genesis mining \
	--path-to-genesis-pow ${DATA_PATH}/blocks/block_0.json \
	--shared-backend ${REMOTE}

# OPER does this
# Submits operator key to github, and creates local OPERATOR_ACCOUNT
oper-key:
	genesis operator-key \
	--validator-backend ${LOCAL} \
	--shared-backend ${REMOTE}

# OWNER does this
# Submits operator key to github, does *NOT* create the OWNER_ACCOUNT locally
owner-key:
	genesis owner-key \
	--validator-backend ${LOCAL} \
	--shared-backend ${REMOTE}

# OWNER does this
# Links to an operator on github, creates the OWNER_ACCOUNT locally
assign: 
	genesis set-operator \
	--operator-name ${OPER} \
	--shared-backend ${REMOTE}

# OPER does this
# Submits signed validator registration transaction to github.
reg:
	genesis validator-config \
	--owner-name ${OWNER} \
	--chain-id ${CHAIN_ID} \
	--validator-address "/ip4/${IP}/tcp/6180" \
	--fullnode-address "/ip4/${IP}/tcp/6179" \
	--validator-backend ${LOCAL} \
	--shared-backend ${REMOTE}
	

## Helpers to verify the local state.
verify:
	genesis verify \
	--validator-backend ${LOCAL}
	# --genesis-path ${DATA_PATH}/genesis.blob

verify-gen:
	genesis verify \
	--validator-backend ${LOCAL} \
	--genesis-path ${DATA_PATH}/genesis.blob


#### GENESIS  ####
genesis:
	genesis files \
	--validator-backend ${LOCAL} \
	--data-path ${DATA_PATH} \
	--namespace ${ACC}

#### NODE MANAGEMENT ####
start:
# run in foreground. Only for testing, use a daemon for net.
	cargo run -p libra-node -- --config ${DATA_PATH}/node.yaml

daemon:
# your node's custom libra-node.service lives in node_data. Take the template from libra/utils and edit for your needs.
	sudo cp -f ~/.0L/node/libra-node.service /lib/systemd/system/
# cp -f miner.service /lib/systemd/system/
	@if test -d ~/logs; then \
		echo "WIPING SYSTEMD LOGS"; \
		sudo rm -rf ~/logs*; \
	fi 

	sudo mkdir ~/logs
	sudo touch ~/logs/node.log
	sudo chmod 660 ~/logs
	sudo chmod 660 ~/logs/node.log

	sudo systemctl daemon-reload
	sudo systemctl stop libra-node.service
	sudo systemctl start libra-node.service
	sudo sleep 2
	sudo systemctl status libra-node.service &
	sudo tail -f ~/logs/node.log

#### TEST SETUP ####

clear:
	if test ${DATA_PATH}/key_store.json; then \
		cd ${DATA_PATH} && rm -rf libradb *.yaml *.blob *.json db; \
	fi

#### HELPERS ####
check:
	@echo account: ${ACC}
	@echo github_token: ${GITHUB_TOKEN}
	@echo ip: ${IP}
	@echo node path: ${DATA_PATH}
	@echo github_org: ${REPO_ORG}
	@echo github_repo: ${REPO_NAME}
	@echo env: ${NODE_ENV}
	@echo test mode: ${TEST}


fix:
ifdef TEST
	echo ${ACC}
	@if test ! -d ${0L_PATH}; then \
		mkdir ${0L_PATH}; \
		mkdir ${DATA_PATH}; \
	fi

	mkdir -p ${DATA_PATH}/blocks/

	@if test -f ${DATA_PATH}/blocks/block_0.json; then \
		rm ${DATA_PATH}/blocks/block_0.json; \
	fi 

	@if test -f ${DATA_PATH}/miner.toml; then \
		rm ${DATA_PATH}/miner.toml; \
	fi 

	cp ./fixtures/miner.toml.${ACC} ${DATA_PATH}/miner.toml

	cp ./fixtures/block_0.json.${NODE_ENV}.${ACC} ${DATA_PATH}/blocks/block_0.json

endif

#### HELPERS ####
get_waypoint:
	$(eval export WAY = $(shell jq -r '. | with_entries(select(.key|match("genesis-waypoint";"i")))[].value' ~/node_data/key_store.json))
  
	echo $$WAY

client: get_waypoint
	cargo run -p cli -- -u http://localhost:8080 --waypoint $$WAY --chain-id 1

compress: 
	tar -C ~/libra/target/release/ -czvf test_net_bins.tar.gz libra-node miner
  
keygen:
	cd ${DATA_PATH} && miner keygen

miner-genesis:
	cd ${DATA_PATH} && NODE_ENV=${NODE_ENV} miner genesis

reset: stop clear fixtures init keys genesis daemon

wipe: 
	history -c
	shred ~/.bash_history
	srm ~/.bash_history

stop:
	sudo service libra-node stop


##### SMOKE TEST #####
smoke-root:
# root is the "association", set up the keys
	ACC=root make root treasury layout

smoke-reg:
# note: this uses the ACC in local env to create files i.e. alice or bob

# as a operator/owner pair.
	make clear fix
#initialize the OWNER account
	ACC=${ACC} make init-test
# The OPERs initialize local accounts and submit pubkeys to github
	ACC=${ACC}-oper make oper-key
# The OWNERS initialize local accounts and submit pubkeys to github, and mining proofs
	ACC=${ACC} make owner-key add-proofs
# OWNER *assign* an operator.
	ACC=${ACC} OPER=${ACC}-oper make assign
# OPERs send signed transaction with configurations for *OWNER* account
	ACC=${ACC}-oper OWNER=${ACC} IP=${IP} make reg
smoke-gen:
	ACC=${ACC}-oper make genesis start
smoke:
	make smoke-reg
# Create configs and start
	make smoke-gen


######################################
## TEST FIXTURES -- NOT FOR GENESIS ##

ifeq ($(ACC), alice)
ACC = alice
ACC = f094dfc3d134331d5410a23f795117b8
AUTH = f0dc83910c2263e5301431114c5c6d12f094dfc3d134331d5410a23f795117b8
IP = 142.93.191.147
MNEM = reunion liberty page dentist rule step negative erosion robot truth paddle image purpose patient work normal wet fruit toward embark speak rail endless final
endif

ifeq ($(ACC), alice-oper)
IP = 142.93.191.147
endif

ifeq ($(ACC), bob)
ACC = 5831d5f6cb6c0c5c576c186f9c4efb63
AUTH = b28f75b8cdd27913ac785d38161501665831d5f6cb6c0c5c576c186f9c4efb63
IP = 167.71.84.248
MNEM = soldier call yellow stone share tortoise jewel gentle margin knock dismiss hurdle cable will surround october fringe input guess snap reveal excite mutual curve
endif

ifeq ($(ACC), bob-oper)
IP = 167.71.84.248
endif

ifeq ($(ACC), carol)
ACC = 07dcd9c8d1dbaaa1611880cbe4ee9691
AUTH = 89d1026ea2e6dd5a0366f96e773dec0b07dcd9c8d1dbaaa1611880cbe4ee9691
IP = 104.131.56.224
MNEM = open neither replace gym pact happy net receive alpha door purse armor chase document forum into tube cherry step kitchen portion army praise keep
endif

ifeq ($(ACC), carol-oper)
IP = 104.131.56.224
endif

ifeq ($(ACC), dave)
ACC = 4a6dcca79b3828fc665fca5c6218d793
AUTH = 4a62540137e5f3b05c6ea608e37b3ab74a6dcca79b3828fc665fca5c6218d793
IP = 104.131.32.62
MNEM = word rival cabin stay enroll swarm shop stuff cruel disorder custom wet awful winter erosion card fantasy member budget aerobic warfare shove embody armor
endif

ifeq ($(ACC), dave-oper)
IP = 104.131.32.62
endif

ifeq ($(ACC), eve)
ACC = e9fbaf07795acc2e675961eb7649acdf
AUTH = a34b9c1580fe7f7c518dac7ed9ddba0be9fbaf07795acc2e675961eb7649acdf
IP = 134.122.115.12
MNEM = dry omit trade angry ahead edge remember stock ordinary elite scare gossip staff help exile minor swift crucial shrug boring stock believe violin vendor
endif

ifeq ($(ACC), eve-oper)
IP = 134.122.115.12
endif

##########################