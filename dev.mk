SHELL=/usr/bin/env bash
DATA_PATH = ${HOME}/.0L
SWARM_TEMP = ${DATA_PATH}/swarm_temp
UNAME := $(shell uname)
LOG=${DATA_PATH}/make_swarm.log
NODE_ENV=test
TEST=y
START_TEXT = "To run the Libra CLI client"

ifndef SOURCE_PATH
SOURCE_PATH = ${HOME}/libra
endif

# alice
ifndef PERSONA
PERSONA=alice
endif

ifeq ($(UNAME), Darwin)
END = $(shell date -v +5M +%s)
NOW = $(shell date -u +%s)
else 
END = $(shell date -ud "5 minutes" +%s)
NOW = $(shell date -u +%s)
endif

swarm: s-build s-start s-check s-init

s-build:
	@echo Building Swarm
	touch ${LOG}
	cd ${SOURCE_PATH} && cargo build -p libra-node

s-start:
	cd ${SOURCE_PATH} && cargo run -p libra-swarm -- --libra-node ${SOURCE_PATH}/target/debug/libra-node -c ${SWARM_TEMP} -n ${NUM_NODES} &> ${LOG}&

s-init:
	cargo run -p ol -- --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} init --source-path ${SOURCE_PATH}

s-check: 
	@while [[ ${NOW} -le ${END} ]] ; do \
			if grep -q ${START_TEXT} ${LOG} ; then \
				break; \
			else \
				echo . ; \
			fi ; \
			echo "Sleeping for 5 secs" ; \
			sleep 5 ; \
	done

stop: 
	killall libra-swarm libra-node