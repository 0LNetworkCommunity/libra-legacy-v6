SHELL=/usr/bin/env bash
DATA_PATH = ${HOME}/.0L
SOURCE_PATH = ${HOME}/libra
SWARM_TEMP = ${HOME}/swarm_temp
LOG=${HOME}/output.log

NODE_ENV=test
TEST=y

# alice
ifndef PERSONA
PERSONA=alice
endif

MNEM="talent sunset lizard pill fame nuclear spy noodle basket okay critic grow sleep legend hurry pitch blanket clerk impose rough degree sock insane purse"

NUM_NODES = 2

ifndef PREV_VERSION
PREV_VERSION=v4.3.0
endif

ifndef TEST_BRANCH
TEST_BRANCH=release-v4.3.1
endif

start:
	@echo Building Swarm
	cd ${SOURCE_PATH} && cargo build -p libra-node -p cli
	cd ${SOURCE_PATH} && cargo run -p libra-swarm -- --libra-node ${SOURCE_PATH}/target/debug/libra-node -c ${SWARM_TEMP} -n ${NUM_NODES} &> ${LOG}&

stop:
	killall libra-swarm libra-node

get-prev:
	cd ${SOURCE_PATH} && git reset --hard && git fetch
	cd ${SOURCE_PATH} && git checkout ${PREV_VERSION}

get-test:
	cd ${SOURCE_PATH} && git reset --hard && git fetch
	cd ${SOURCE_PATH} && git checkout ${TEST_BRANCH}

stdlib:
	cd ${SOURCE_PATH} && cargo run --release -p stdlib
	cd ${SOURCE_PATH} && cargo run --release -p stdlib -- --create-upgrade-payload
	sha256sum ${SOURCE_PATH}/language/stdlib/staged/stdlib.mv

init:
	cd ${SOURCE_PATH} && cargo run -p ol-cli -- --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} init
	mkdir ${HOME}/.0L/ | true
	cp ${SWARM_TEMP}/0/0L.toml ${HOME}/.0L/0L.toml

submit:
	cd ${SOURCE_PATH} && cargo run -p txs -- --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} oracle-upgrade

query:
	cd ${SOURCE_PATH} && cargo run -p ol-cli -- --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} query --blockheight

END=$(shell date -ud "5 minute" +%s)
NOW = $(shell date -u +%s)

START_TEXT = "To run the Libra CLI client"
UPGRADE_TEXT = "stdlib upgrade: published"

upgrade: 
	echo ${END}
	@while [[ ${NOW} -le ${END} ]] ; do \
			if grep -q ${START_TEXT} ${LOG} ; then \
				make -f ${SOURCE_PATH}/ol/util/test-upgrade.mk get-test stdlib submit; \
				PERSONA=bob make -f ${SOURCE_PATH}/ol/util/test-upgrade.mk submit; \
				break; \
			else \
				echo . ; \
			fi ; \
			echo "Sleeping for 5 secs" ; \
			sleep 5 ; \
	done

check:	
	@while [[ ${NOW} -le ${END} ]] ; do \
			make -f ${SOURCE_PATH}/ol/util/test-upgrade.mk query; \
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
	@while [[ ${NOW} -le ${END} ]] ; do \
			make -f ${SOURCE_PATH}/ol/util/test-upgrade.mk query; \
			if [TODO] ; then \
				echo making progress ; \
				break ; \
			else \
				echo . ; \
			fi ; \
			echo "Sleeping for 5 secs" ; \
			sleep 5 ; \
	done

test: get-prev start upgrade check stop