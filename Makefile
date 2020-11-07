#### VARIABLES ####
SHELL=/usr/bin/env bash
DATA_PATH = /root/node_data
IP = 1.2.3.4
GITHUB_TOKEN = $(shell cat ${DATA_PATH}/github_token.txt)
# # ACC = alice
# NS = $(ACC)
REPO_ORG = OLSF
REPO_NAME = dev-genesis
CHAIN_ID = "1"
ifndef NODE_ENV
NODE_ENV = stage
endif

REMOTE = 'backend=github;repository_owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}/github_token.txt;namespace=${NS}'
LOCAL = 'backend=disk;path=${DATA_PATH}/key_store.json;namespace=${NS}'

ifndef OWNER
OWNER = alice
endif

ifndef OPER
OPER = bob
endif

##### PIPELINES #####
# pipelines for genesis ceremony
oper: init oper-init
# configs the operator
owner: init owner-init assign

# for testing
smoke-init:
# root is the "association", set up the keys
	NS=root make root treasury layout
smoke-reg:
# note: this uses the NS in local env to create files i.e. alice or bob

# as a operator/owner pair.
	make clear
#initialize the OWNER account
	NS=${NS} make init
# The OPERs initialize local accounts and submit pubkeys to github
	NS=${NS}-oper make oper-init
# The OWNERS initialize local accounts and submit pubkeys to github, and mining proofs
	NS=${NS} make owner-init add-proofs
# OWNER *assign* an operator.
	NS=${NS} OPER=${NS}-oper make assign
# OPERs send signed transaction with configurations for *OWNER* account
	NS=${NS}-oper OWNER=${NS} IP=${IP} make reg
smoke-gen:
	NS=${NS}-oper make genesis start
smoke:
	make smoke-reg
# Create configs and start
	make smoke-gen

#### GENESIS BACKEND SETUP ####
init-backend: 
	curl -X POST -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/orgs/${REPO_ORG}/repos -d '{"name":"${REPO_NAME}", "private": "true", "auto_init": "true"}'

layout:
	cargo run -p libra-genesis-tool -- set-layout \
	--shared-backend 'backend=github;repository_owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}/github_token.txt;namespace=common' \
	--path ./util/set_layout.toml

root:
		cargo run -p libra-genesis-tool -- libra-root-key \
		--validator-backend ${LOCAL} \
		--shared-backend ${REMOTE}

treasury:
		cargo run -p libra-genesis-tool -- treasury-compliance-key \
		--validator-backend ${LOCAL} \
		--shared-backend ${REMOTE}

#### GENESIS REGISTRATION ####
init:
	echo ${MNEM} | head -c -1 | cargo run -p libra-genesis-tool -- init --path=${DATA_PATH} --namespace=${NS}

# OWNER does this
# Submits proofs to shared storage
add-proofs:
	cargo run -p libra-genesis-tool -- mining \
	--path-to-genesis-pow ${DATA_PATH}/blocks/block_0.json \
	--shared-backend ${REMOTE}

# OPER does this
# Submits operator key to github, and creates local OPERATOR_ACCOUNT
oper-init:
	cargo run -p libra-genesis-tool -- operator-key \
	--validator-backend ${LOCAL} \
	--shared-backend ${REMOTE}

# OWNER does this
# Submits operator key to github, does *NOT* create the OWNER_ACCOUNT locally
owner-init:
	cargo run -p libra-genesis-tool -- owner-key \
	--validator-backend ${LOCAL} \
	--shared-backend ${REMOTE}

# OWNER does this
# Links to an operator on github, creates the OWNER_ACCOUNT locally
assign: 
	cargo run -p libra-genesis-tool -- set-operator \
	--operator-name ${OPER} \
	--shared-backend ${REMOTE}

# OPER does this
# Submits signed validator registration transaction to github.
reg:
	cargo run -p libra-genesis-tool -- validator-config \
	--owner-name ${OWNER} \
	--chain-id ${CHAIN_ID} \
	--validator-address "/ip4/${IP}/tcp/6180" \
	--fullnode-address "/ip4/${IP}/tcp/6179" \
	--validator-backend ${LOCAL} \
	--shared-backend ${REMOTE}
	

## Helpers to verify the local state.
verify:
	cargo run -p libra-genesis-tool -- verify \
	--validator-backend ${LOCAL}
	# --genesis-path ${DATA_PATH}/genesis.blob

verify-gen:
	cargo run -p libra-genesis-tool -- verify \
	--validator-backend ${LOCAL} \
	--genesis-path ${DATA_PATH}/genesis.blob


#### GENESIS  ####
genesis:
	cargo run -p libra-genesis-tool -- files \
	--validator-backend ${LOCAL} \
	--data-path ${DATA_PATH} \
	--namespace ${NS}

# gen:
# 	NODE_ENV='${NODE_ENV}' cargo run -p libra-genesis-tool -- genesis \
# 	--shared-backend ${REMOTE} \
# 	--path ${DATA_PATH}/genesis.blob \
# 	--chain-id ${CHAIN_ID}

# way: 
# 	NODE_ENV='${NODE_ENV}' cargo run -p libra-genesis-tool -- create-waypoint \
# 	--shared-backend ${REMOTE} \
# 	--chain-id ${CHAIN_ID}

# insert-way: 
# 	NODE_ENV='${NODE_ENV}' cargo run  -p libra-genesis-tool -- insert-waypoint \
# 	--validator-backend ${LOCAL} \
# 	--waypoint ${WAY}


#### NODE MANAGEMENT ####
start:
# run in foreground. Only for testing, use a daemon for net.
	cargo run -p libra-node -- --config ${DATA_PATH}/node.yaml

#### TEST SETUP ####

clear:
	if test ${DATA_PATH}/key_store.json; then \
		cd ${DATA_PATH} && rm -rf libradb *.yaml *.blob *.json db; \
	fi


echo:
	@echo NS: ${NS}
	@echo test: ${TEST}
	@echo env: ${NODE_ENV}
	@echo path: ${DATA_PATH}
	@echo ip: ${IP}
	@echo account: ${ACC}
	@echo github_token: ${GITHUB_TOKEN}
	@echo github_org: ${REPO_ORG}
	@echo github_repo: ${REPO_NAME}

######################################
## THIS IS TEST DATA -- NOT FOR GENESIS##

ifeq ($(NS), alice)
NS = alice
ACC = f094dfc3d134331d5410a23f795117b8
AUTH = f0dc83910c2263e5301431114c5c6d12f094dfc3d134331d5410a23f795117b8
IP = 142.93.191.147
MNEM = average list time circle item couch resemble tool diamond spot winter pulse cloth laundry slice youth payment cage neutral bike armor balance way ice
endif

ifeq ($(NS), alice-oper)
IP = 142.93.191.147
endif

ifeq ($(NS), bob)
ACC = 5831d5f6cb6c0c5c576c186f9c4efb63
AUTH = b28f75b8cdd27913ac785d38161501665831d5f6cb6c0c5c576c186f9c4efb63
IP = 167.71.84.248
MNEM = owner city siege lamp code utility humor inherit plug tuna orchard lion various hill arrow hold venture biology aisle talent desert expand nose city
endif

ifeq ($(NS), bob-oper)
IP = 167.71.84.248
endif

ifeq ($(NS), carol)
ACC = 07dcd9c8d1dbaaa1611880cbe4ee9691
AUTH = 89d1026ea2e6dd5a0366f96e773dec0b07dcd9c8d1dbaaa1611880cbe4ee9691
IP = 104.131.56.224
MNEM = motor employ crumble add original wealth spray lobster eyebrow title arrive hazard machine snake east dish alley drip mail erupt source dinner hobby day
endif

ifeq ($(NS), carol-oper)
IP = 104.131.56.224
endif

ifeq ($(NS), dave)
ACC = 4a6dcca79b3828fc665fca5c6218d793
AUTH = 4a62540137e5f3b05c6ea608e37b3ab74a6dcca79b3828fc665fca5c6218d793
IP = 104.131.32.62
MNEM = advice organ wage sick travel brief leave renew utility host roast barely can noble cheap cancel rotate series method inside damage beach tomorrow power
endif

ifeq ($(NS), dave-oper)
IP = 104.131.32.62
endif

ifeq ($(NS), eve)
ACC = e9fbaf07795acc2e675961eb7649acdf
AUTH = a34b9c1580fe7f7c518dac7ed9ddba0be9fbaf07795acc2e675961eb7649acdf
IP = 134.122.115.12
MNEM = veteran category typical plastic service mimic photo sort face taste puppy slogan nature youth member lake symptom edit pepper stairs actual hub miss train
endif

ifeq ($(NS), eve-oper)
IP = 134.122.115.12
endif

##########################