SHELL=/usr/bin/env bash
DATA_PATH = ${HOME}/.0L
SWARM_TEMP = ${DATA_PATH}/swarm_temp
LOG=${DATA_PATH}/test-autopay.log
UNAME := $(shell uname)

NODE_ENV=test
TEST=y

ifndef SOURCE_PATH
SOURCE_PATH = ${HOME}/libra
endif
MAKE_FILE = ${SOURCE_PATH}/ol/integration-tests/test-tx-tools.mk

# alice
ifndef PERSONA
PERSONA=alice
endif

MNEM="talent sunset lizard pill fame nuclear spy noodle basket okay critic grow sleep legend hurry pitch blanket clerk impose rough degree sock insane purse"

NUM_NODES = 2

START_TEXT = "To run the Diem CLI client"

ifndef SUCCESS_TEXT
SUCCESS_TEXT = "transaction executed"
endif

ifndef AUTOPAY_FILE
AUTOPAY_FILE = alice.autopay_batch.json
endif

export

# Start a swarm with alice, bob, carol. They are all slow wallets.
# make bob a community wallet.
# have bob send a tx to carol.

#test: swarm check-swarm set-community send-tx check-tx check-transfer  stop
test: swarm check-swarm set-community send-tx check-tx check-transfer 


swarm:
	@echo Building Swarm
	rm -rf ${SWARM_TEMP}
	mkdir ${SWARM_TEMP}
	cd ${SOURCE_PATH} && cargo build -p diem-node -p cli
	cd ${SOURCE_PATH} && cargo run -p diem-swarm -- --diem-node ${SOURCE_PATH}/target/debug/diem-node -c ${SWARM_TEMP} -n ${NUM_NODES} &> ${LOG} &

stop:
	killall diem-swarm diem-node tower ol txs cli | true

init:
	cd ${SOURCE_PATH} && cargo r -p ol -- --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} init --source-path ${SOURCE_PATH} --chain-id TESTING

tx: balance
	cd ${SOURCE_PATH} && NODE_ENV=test TEST=y cargo r -p txs -- --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} community-pay -a e660402d586ad220ed9beff47d662d54 -c 1 -m hello
	

set-community:
	cd ${SOURCE_PATH} && NODE_ENV=test TEST=y cargo r -p txs -- --swarm-path ${SWARM_TEMP} --swarm-persona bob wallet -c

resources:
	cd ${SOURCE_PATH} && cargo run -p ol -- --account 00000000000000000000000000000000 --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} query --resources

balance:
	cd ${SOURCE_PATH} && cargo run -p ol -- --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} query --balance

balance-carol:
	cd ${SOURCE_PATH} && cargo run -p ol -- --account e660402d586ad220ed9beff47d662d54 --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} query --balance


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

send-tx: 
	PERSONA=bob make -f ${MAKE_FILE} init
	PERSONA=bob make -f ${MAKE_FILE} tx &>> ${LOG} &

check-tx:
	@while [[ ${NOW} -le ${END} ]] ; do \
			if grep -q ${SUCCESS_TEXT} ${LOG} ; then \
				echo TX SUCCESS ; \
				break ; \
			else \
				echo . ; \
			fi ; \
			echo "Sleeping for 5 secs" ; \
			sleep 5 ; \
	done

check-transfer:
# swarm accounts start with a balance of 10, but go below that with gas tx costs.
# all tests above push the balance back up to 10, 11 or 15

# check for the memo field of the community transfer
	@while [[ ${NOW} -le ${END} ]] ; do \
			if PERSONA=carol make -f ${MAKE_FILE} resources | grep -e "expire_epoch"; then \
				echo TX SUCCESS ; \
				break ; \
			else \
				echo . ; \
			fi ; \
			echo "Sleeping for 5 secs" ; \
			sleep 5 ; \
	done
	