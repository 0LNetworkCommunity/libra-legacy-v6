#### VARIABLES ####
SHELL=/usr/bin/env bash
HOME = /root/.0L
DATA_PATH = ${HOME}/node
IP = 1.2.3.4
GITHUB_TOKEN = $(shell cat ${DATA_PATH}/github_token.txt)
# # ACC = alice
# NS = $(ACC)
REPO_ORG = OLSF
REPO_NAME = dev-genesis
#experimental network is #7
CHAIN_ID = "7"
ifndef NODE_ENV
NODE_ENV = test
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

# for testing
smoke-root:
# root is the "association", set up the keys
	NS=root make root treasury layout

smoke-reg:
# note: this uses the NS in local env to create files i.e. alice or bob

# as a operator/owner pair.
	make clear fix
#initialize the OWNER account
	NS=${NS} make init
# The OPERs initialize local accounts and submit pubkeys to github
	NS=${NS}-oper make oper-key
# The OWNERS initialize local accounts and submit pubkeys to github, and mining proofs
	NS=${NS} make owner-key add-proofs
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
oper-key:
	cargo run -p libra-genesis-tool -- operator-key \
	--validator-backend ${LOCAL} \
	--shared-backend ${REMOTE}

# OWNER does this
# Submits operator key to github, does *NOT* create the OWNER_ACCOUNT locally
owner-key:
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

daemon:
# your node's custom libra-node.service lives in node_data. Take the template from libra/utils and edit for your needs.
	sudo cp -f ~/.0L/node/libra-node.service /lib/systemd/system/
# cp -f miner.service /lib/systemd/system/
	if test -d ~/logs; then \
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

fix:
ifdef TEST
	echo ${NS}
	if test ! -d ${HOME}; then \
		mkdir ${HOME}; \
		mkdir ${DATA_PATH}; \
	fi

	mkdir -p ${DATA_PATH}/blocks/

	if test -f ${DATA_PATH}/blocks/block_0.json; then \
		rm ${DATA_PATH}/blocks/block_0.json; \
	fi 

	if test -f ${DATA_PATH}/miner.toml; then \
		rm ${DATA_PATH}/miner.toml; \
	fi 

	cp ./fixtures/test/${NS}/miner.toml ${DATA_PATH}/miner.toml

	cp ./fixtures/test/${NS}/block_0.json ${DATA_PATH}/blocks/block_0.json

endif

#### HELPERS ####
bins:
	cd ~/libra && cargo build -p libra-node --release & sudo cp -f ~/libra/target/release/libra-node /usr/local/bin/libra-node
	# cd ~/libra && cargo build -p libra-management --release && sudo cp -f ~/libra/target/release/libra-management /usr/local/bin/libra-management
	cd ~/libra && cargo build -p miner --release && sudo cp -f ~/libra/target/release/miner /usr/local/bin/miner

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


######################################
## TEST FIXTURES -- NOT FOR GENESIS ##

ifeq ($(NS), alice)
NS = alice
ACC = "0E7DA4499FB75CCD30E6527761A55A06"
AUTH = "91ffe0bce9806e599cd3565958ed0d3a0e7da4499fb75ccd30e6527761a55a06"
IP = 142.93.191.147
MNEM = reunion liberty page dentist rule step negative erosion robot truth paddle image purpose patient work normal wet fruit toward embark speak rail endless final
endif

ifeq ($(NS), alice-oper)
IP = 142.93.191.147
endif

ifeq ($(NS), bob)
ACC = "61A730A3B230BBC4B00AA0C1EB74F5A0"
AUTH = "c06b6ec51678a72b3ec86a9a613aa27461a730a3b230bbc4b00aa0c1eb74f5a0"
IP = 167.71.84.248
MNEM = soldier call yellow stone share tortoise jewel gentle margin knock dismiss hurdle cable will surround october fringe input guess snap reveal excite mutual curve
endif

ifeq ($(NS), bob-oper)
IP = 167.71.84.248
endif

ifeq ($(NS), carol)
ACC = "E3DA896091E7958DD7A4A475672F085A"
AUTH = "b24745757cb3817417c314ada1e4d07ee3da896091e7958dd7a4a475672f085a"
IP = 104.131.56.224
MNEM = open neither replace gym pact happy net receive alpha door purse armor chase document forum into tube cherry step kitchen portion army praise keep
endif

ifeq ($(NS), carol-oper)
IP = 104.131.56.224
endif

ifeq ($(NS), dave)
ACC = "8FAB2B4D2AEEFF56155061CA2B4D9E29"
AUTH = "80ba01a073c77549c760ec88f1b8a5aa8fab2b4d2aeeff56155061ca2b4d9e29"
IP = 104.131.32.62
MNEM = word rival cabin stay enroll swarm shop stuff cruel disorder custom wet awful winter erosion card fantasy member budget aerobic warfare shove embody armor
endif

ifeq ($(NS), dave-oper)
IP = 104.131.32.62
endif

ifeq ($(NS), eve)
ACC = "22172B8D4D5CCC8C13BCA0981EF986EF"
AUTH = "f0e5b5ac5be816e87687b320273c815322172b8d4d5ccc8c13bca0981ef986ef"
IP = 134.122.115.12
MNEM = dry omit trade angry ahead edge remember stock ordinary elite scare gossip staff help exile minor swift crucial shrug boring stock believe violin vendor
endif

ifeq ($(NS), eve-oper)
IP = 134.122.115.12
endif

##########################