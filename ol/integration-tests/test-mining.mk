SHELL=/usr/bin/env bash
DATA_PATH = ${HOME}/.0L
SWARM_TEMP = ${DATA_PATH}/swarm_temp
LOG=${DATA_PATH}/test-mining.log
UNAME := $(shell uname)

NODE_ENV=test
TEST=y

ifndef SOURCE_PATH
SOURCE_PATH = ${HOME}/code/rust/libra
endif
MAKE_FILE = ${SOURCE_PATH}/ol/integration-tests/test-mining.mk

# alice
ifndef PERSONA
PERSONA=alice
endif

MNEM="talent sunset lizard pill fame nuclear spy noodle basket okay critic grow sleep legend hurry pitch blanket clerk impose rough degree sock insane purse"

NUM_NODES = 2

START_TEXT = "To run the Diem CLI client"
SUCCESS_TEXT = "Proof committed to chain"


test: swarm check-swarm start-mine check stop

swarm:
	@echo Building Swarm
	rm -rf ${SWARM_TEMP}
	mkdir ${SWARM_TEMP}
	cd ${SOURCE_PATH} && cargo build -p diem-node -p cli
	cd ${SOURCE_PATH} && cargo run -p diem-swarm -- --diem-node ${SOURCE_PATH}/target/debug/diem-node -c ${SWARM_TEMP} -n ${NUM_NODES} &> ${LOG} &

stop:
	killall diem-swarm diem-node tower ol txs cli | true

echo: 
	@echo hi &> ${LOG} &

init:
	cd ${SOURCE_PATH} && cargo r -p ol -- --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} init --source-path ${SOURCE_PATH} --chain-id TESTING

mine:
	cd ${SOURCE_PATH} && cargo r -p tower -- --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} start

create-stage:
	cd ${SOURCE_PATH} && cargo r -p txs -- --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} create-validator -f ol/fixtures/account/stage.eve.account.json 

create:
	cd ${SOURCE_PATH} && cargo r -p txs -- --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} create-validator -f ol/fixtures/account/eve.account.json 

resources:
	cd ${SOURCE_PATH} && cargo run -p ol -- --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} query --resources


check-swarm: 
	@while [[ ${NOW} -le ${END} ]] ; do \
			if grep -q ${START_TEXT} ${LOG} ; then \
				break; \
			else \
				echo . ; \
			fi ; \
			echo "Sleeping for 5 secs" ; \
			sleep 5 ; \
	done

start-mine: 
	PERSONA=alice make -f ${MAKE_FILE} init
	PERSONA=alice make -f ${MAKE_FILE} mine &> ${LOG} &

check:
	@while [[ ${NOW} -le ${END} ]] ; do \
			if grep -q ${SUCCESS_TEXT} ${LOG} ; then \
				echo MINING SUCCESS ; \
				break ; \
			else \
				echo . ; \
			fi ; \
			echo "Sleeping for 5 secs" ; \
			sleep 5 ; \
	done