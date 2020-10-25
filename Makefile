#### VARIABLES ####
SHELL=/usr/bin/env bash
DIR = ~/node_data/
GITHUB_TOKEN = a6376bbd4965667882582461e81287e37d6e7150
ACC = alice
NAMESPACE = $(ACC)
REPO_ORG = OLSF
REPO_NAME = dev-genesis
CHAIN_ID = "1"

REMOTE = 'backend=github;repository_owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}/github_token.txt;namespace=${NAMESPACE}'
LOCAL = 'backend=disk;path=${DATA_PATH}/key_store.json;namespace=${NAMESPACE}'

##### PIPELINES #####
compile: stop stdlib bins
# pipelines for genesis ceremony
register: clear init keys owner oper reg verify
# do genesis
genesis: gen way insert-way files
# for testing
smoke: register genesis verify-gen start

#### GENESIS BACKEND SETUP ####
init-backend: 
	curl -X POST -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/orgs/${REPO_ORG}/repos -d '{"name":"${REPO_NAME}", "private": "true", "auto_init": "true"}'

layout:
	cargo run -p libra-genesis-tool -- set-layout \
	--shared-backend 'backend=github;repository_owner=${REPO_ORG};repository=${REPO_NAME};token=${DATA_PATH}/github_token.txt;namespace=common' \
	--path set_layout.toml

root:
		cargo run -p libra-genesis-tool -- libra-root-key \
		--validator-backend ${LOCAL} \
		--shared-backend ${REMOTE}

tresury:
		cargo run -p libra-genesis-tool -- treasury-compliance-key \
		--validator-backend ${LOCAL} \
		--shared-backend ${REMOTE}

#### GENESIS REGISTRATION ####
init:
	cargo run -p libra-genesis-tool -- init --path=${DATA_PATH} --namespace=${NAMESPACE}

# add-proofs:
# 	cargo run -p libra-management -- mining \
# 	--path-to-genesis-pow ${DATA_PATH}/blocks/block_0.json \
# 	--backend ${REMOTE}

keys:
	cargo run -p libra-genesis-tool -- operator-key \
	--validator-backend ${LOCAL} \
	--shared-backend ${REMOTE}

owner:
	cargo run -p libra-genesis-tool -- owner-key \
	--validator-backend ${LOCAL} \
	--shared-backend ${REMOTE}

oper:
	cargo run -p libra-genesis-tool -- set-operator \
	--operator-name alice \
	--shared-backend ${REMOTE}

reg:
	cargo run -p libra-genesis-tool -- validator-config \
	--owner-name ${ACC} \
	--chain-id ${CHAIN_ID} \
	--validator-address "/ip4/${IP}/tcp/6180" \
	--fullnode-address "/ip4/${IP}/tcp/6179" \
	--validator-backend ${LOCAL} \
	--shared-backend ${REMOTE}

verify:
	cargo run -p libra-genesis-tool -- verify \
	--validator-backend ${LOCAL}
	# --genesis-path ${DATA_PATH}/genesis.blob

verify-gen:
	cargo run -p libra-genesis-tool -- verify \
	--validator-backend ${LOCAL} \
	--genesis-path ${DATA_PATH}/genesis.blob


#### GENESIS  ####
gen:
	NODE_ENV='${NODE_ENV}' cargo run -p libra-genesis-tool -- genesis \
	--shared-backend ${REMOTE} \
	--path ${DATA_PATH}/genesis.blob \
	--chain-id ${CHAIN_ID}

way: 
	NODE_ENV='${NODE_ENV}' cargo run -p libra-genesis-tool -- create-waypoint \
	--shared-backend ${REMOTE} \
	--chain-id ${CHAIN_ID}

insert-way: 
	NODE_ENV='${NODE_ENV}' cargo run -p libra-genesis-tool -- insert-waypoint \
	--validator-backend ${LOCAL} \
	--waypoint 0:d1a56e91421b9ff9c0431ce5b363845f77231bc8e96e24e67425b0e777769286

files:
	cargo run -p libra-genesis-tool -- files \
	--validator-backend ${LOCAL}

#### NODE MANAGEMENT ####
start:
# run in foreground. Only for testing, use a daemon for net.
	cargo run -p libra-node -- --config ${DATA_PATH}/node.configs.yaml

#### TEST SETUP ####

clear:
	if test -f ~/node_data/key_store.json; then \
		cd ${DATA_PATH} && rm -rf libradb *.yaml *.blob *.json; \
	fi