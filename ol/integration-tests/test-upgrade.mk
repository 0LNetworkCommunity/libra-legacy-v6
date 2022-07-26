SHELL=/usr/bin/env bash
DATA_PATH = ${HOME}/.0L
SWARM_TEMP = ${DATA_PATH}/swarm_temp
UPGRADE_TEMP = ${DATA_PATH}/test-upgrade
SAFE_MAKE_FILE = ${UPGRADE_TEMP}/test-upgrade.mk
LOG=${UPGRADE_TEMP}/test-upgrade.log
UNAME := $(shell uname)

NODE_ENV=test
TEST=y

RUST_BACKTRACE=1

ifndef SOURCE_PATH
SOURCE_PATH = ${HOME}/libra
endif

STDLIB_BIN = ${SOURCE_PATH}/language/diem-framework/staged/stdlib.mv
STDLIB_BIN_HOLDING = ${UPGRADE_TEMP}/stdlib.mv
HASH := $(shell sha256sum ${STDLIB_BIN} | cut -d " " -f 1)


# alice
ifndef PERSONA
PERSONA=alice
endif

MNEM="talent sunset lizard pill fame nuclear spy noodle basket okay critic grow sleep legend hurry pitch blanket clerk impose rough degree sock insane purse"

NUM_NODES = 2

ifndef PREV_VERSION
#TODO: decide how to programmatically tell the tests what version is in production. 
#This needs to be updated after every chain upgrade
PREV_VERSION = v5.0.10
endif

ifndef BRANCH_NAME
BRANCH_NAME = $(shell git branch --show-current)
endif

# USAGE: BRANCH_NAME=<latest branch> make -f test-upgrade.mk upgrade
# NOTE: BRANCH_NAME shares semantics with https://github.com/marketplace/actions/get-branch-name
test: prep stdlib get-prev prev-stdlib start upgrade check progress stop

start:
	@echo Building Swarm
	cd ${SOURCE_PATH} && cargo build -p diem-node -p cli
	cd ${SOURCE_PATH} && cargo run -p diem-swarm -- --diem-node ${SOURCE_PATH}/target/debug/diem-node -c ${SWARM_TEMP} -n ${NUM_NODES} 2>&1 | tee ${LOG}&

stop:
	killall diem-swarm diem-node tower ol txs cli | true

prep:
# save makefile outside of repo, since we'll need it across branches
#	mkdir ${HOME}/.0L/ | true
	mkdir -p ${UPGRADE_TEMP} | true
	cp ${SOURCE_PATH}/ol/integration-tests/test-upgrade.mk ${SAFE_MAKE_FILE}

get-prev:
	cd ${SOURCE_PATH} && git reset --hard && git fetch
	cd ${SOURCE_PATH} && git checkout ${PREV_VERSION} -f

stdlib:
	cd ${SOURCE_PATH} && cargo run --release -p diem-framework
	cd ${SOURCE_PATH} && cargo run --release -p diem-framework -- --create-upgrade-payload
	sha256sum ${STDLIB_BIN}
	cp ${STDLIB_BIN} ${STDLIB_BIN_HOLDING}

prev-stdlib:
	cd ${SOURCE_PATH} && cargo run --release -p diem-framework


init:
	cd ${SOURCE_PATH} && cargo r -p ol -- --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} init --source-path ${SOURCE_PATH} --chain-id TESTING
	cp ${SWARM_TEMP}/0/0L.toml ${HOME}/.0L/0L.toml

submit:
	cd ${SOURCE_PATH} && cargo run -p txs -- --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} oracle-upgrade -v -f ${STDLIB_BIN_HOLDING}

submit-hash:
	echo ${HASH}
	cd ${SOURCE_PATH} && cargo run -p txs -- --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} oracle-upgrade -v -h ${HASH}

query:
	cd ${SOURCE_PATH} && cargo run -p ol -- --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} query --blockheight | grep -Eo [0-9]+ | tail -n1

txs:
	cd ${SOURCE_PATH} && cargo run -p txs -- --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} demo

ifeq ($(UNAME), Darwin)
END = $(shell date -v +5M +%s)
NOW = $(shell date -u +%s)
else 
END = $(shell date -ud "5 minutes" +%s)
NOW = $(shell date -u +%s)
endif

START_TEXT = "To run the Diem CLI client"
UPGRADE_TEXT = "stdlib upgrade: published"

upgrade: 
# Note, in order to have bob vote with hash, change 'submit' in his command to 'submit-hash', will only work if PREV_VERSION also has the submit-hash command
	@while [[ ${NOW} -le ${END} ]] ; do \
			if grep -q ${START_TEXT} ${LOG} ; then \
				PERSONA=alice make -f ${SAFE_MAKE_FILE} submit; \
				PERSONA=bob make -f ${SAFE_MAKE_FILE} submit; \
				break; \
			else \
				echo . ; \
			fi ; \
			echo "Sleeping for 5 secs" ; \
			sleep 5 ; \
	done

check:	
	@while [[ ${NOW} -le ${END} ]] ; do \
			if grep -q ${UPGRADE_TEXT} ${SWARM_TEMP}/logs/0.log ; then \
				echo UPGRADE SUCCESS! ; \
				break ; \
			else \
				echo . ; \
			fi ; \
			echo "Sleeping for 5 secs" ; \
			sleep 5 ; \
	done

# check the blocks are progressing after upgrade
progress:
	@i=1 ; \
	while [[ $$i -le 10 ]] ; do \
			echo ===== Transaction $$i =====; \
			if make -f ${SAFE_MAKE_FILE} txs ; then \
				echo Making progress ; \
				i=$$(($$i + 1)); \
			else \
				echo ERROR, txs not successful ; \
				cat ${LOG};\
				cat ${SWARM_TEMP}/logs/0.log;\
				exit 1 ; \
			fi ; \
			echo "Sleeping for 1 min" ; \
			sleep 1m ; \
	done

tail:
	tail -f ${SWARM_TEMP}/logs/0/log
