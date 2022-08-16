SHELL=/usr/bin/env bash
DATA_PATH = ${HOME}/.0L
SWARM_TEMP = ${DATA_PATH}/swarm_temp
LOG=${DATA_PATH}/test-onboard.log
UNAME := $(shell uname)

NODE_ENV=test
TEST=y

ifndef SOURCE_PATH
SOURCE_PATH = ${HOME}/libra
endif
MAKE_FILE = ${SOURCE_PATH}/ol/integration-tests/test-onboard.mk

# alice
ifndef PERSONA
PERSONA=alice
endif

# Eve mnemonic
MNEM="recall october regret kite undo choice outside season business wall quit arrest vacant arrow giggle vote ghost winter hawk soft cheap decide exhaust spare"

NUM_NODES = 2
EVE = 3DC18D1CF61FAAC6AC70E3A63F062E4B

# ONBOARD_FILE=${SOURCE_PATH}/ol/fixtures/account/swarm/eve.fixed_recurring.account.json

ONBOARD_FILE= ${DATA_PATH}/account.json

START_TEXT = "To run the Diem CLI client"
SUCCESS_TEXT = "Account created on chain"

export

# account.json fixtures generated with:
# cargo r -p onboard -- --swarm-path ./whatever val --upstream-peer http://167.172.248.37/

# test: swarm check-swarm set-community create-json send-tx check-tx check-account-created check-autopay stop

test: swarm check-swarm create-json send-tx check-tx check-account-created stop

# Testing the Onboarding of Eve, there are many steps, and it involved Eve (to be onboarded), Alice (the onboarder), and Bob, a community wallet Eve wants to donate to.

# 1. swarm - start swarm with 2 nodes, Alice and Bob
# 2. check-swarm - check swarm is running
# 3. set-community - set Bob's account as a community wallet
# 4. create-json - create all onboarding files for Eve 
# 5. send-tx - send the onboarding transaction from Alice's account to create Eve
# 6. check-tx - check that the onboarding tx works and was accepted.
# 7. check-account-created - checks that Eve's account was created.
# 8. check-autopay - checks that the autopay instruction on chain includes Bob's address
# 9. TODO: check-transfer - check repeatedly (over epochs) if Bob's account is receiving autopay payments from Eve. NOTE: Since the onboarding transfer is on 1 gas and tx fees push the balance below 1, autopay is disabled to prevent the account doesn't get locked.

# That's a successful onboarding.

swarm:
	@echo Building Swarm
	rm -rf ${SWARM_TEMP}
	mkdir ${SWARM_TEMP}
	cd ${SOURCE_PATH} && cargo build -p diem-node -p cli
	cd ${SOURCE_PATH} && NODE_ENV=test TEST=y cargo run -p diem-swarm -- --diem-node ${SOURCE_PATH}/target/debug/diem-node -c ${SWARM_TEMP} -n ${NUM_NODES} &> ${LOG} &

stop:
	killall diem-swarm diem-node tower ol txs cli | true

init:
	cd ${SOURCE_PATH} && cargo r -p ol -- --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} init --source-path ${SOURCE_PATH} --chain-id TESTING

create-json:
	cp ${SOURCE_PATH}/ol/fixtures/autopay/alice.autopay_batch.json ${DATA_PATH}/autopay_batch.json

# This account Eve account.json needs to be created on the fly, because there is a tx expiry param, which has a max of approx 7 days, which means CI tests will fail with state fixtures.

# note we need the swarm-path so that the onboarding takes the tx params for swarm, otherwise the tx will fail
# we pass all these params so that the wizard does not dialogue with us.

# TODO: Makefile question: Why do we need to set MNEM set to itself here?
	MNEM=${MNEM} cargo r -p onboard -- --swarm-path ~/swarm_temp val --upstream-peer http://localhost --epoch 5 --waypoint '0:683185844ef67e5c8eeaa158e635de2a4c574ce7bbb7f41f787d38db2d623ae2' --home-path ${DATA_PATH} --output-path ${DATA_PATH} --ci


 
tx: balance-alice
	@echo SENDING ONBOARDING TX
	cd ${SOURCE_PATH} && NODE_ENV=test TEST=y cargo r -p txs -- --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} create-validator -f ${ONBOARD_FILE}

set-community:
	cd ${SOURCE_PATH} && NODE_ENV=test TEST=y cargo r -p txs -- --swarm-path ${SWARM_TEMP} --swarm-persona bob wallet -c

resources:
	cd ${SOURCE_PATH} && cargo run -p ol -- --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} --account ${EVE} query --resources

balance:
	cd ${SOURCE_PATH} && cargo run -p ol -- --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} --account 3DC18D1CF61FAAC6AC70E3A63F062E4B query --balance

query-autopay:
	cd ${SOURCE_PATH} && cargo run -p ol -- --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} --account 3DC18D1CF61FAAC6AC70E3A63F062E4B query --move-state --move-module AutoPay --move-struct UserAutoPay --move-value payments

balance-alice:
	cd ${SOURCE_PATH} && cargo run -p ol -- --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} --account 4C613C2F4B1E67CA8D98A542EE3F59F5 query --balance

balance-bob:
	cd ${SOURCE_PATH} && cargo run -p ol -- --account 88E74DFED34420F2AD8032148280A84B --swarm-path ${SWARM_TEMP} --swarm-persona ${PERSONA} query --balance


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
	PERSONA=alice make -f ${MAKE_FILE} init
	PERSONA=alice make -f ${MAKE_FILE} tx &>> ${LOG} &

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

check-account-created: 
# checks if there is any mention of BOB's account as a payee on EVE's account
	PERSONA=alice make -f ${MAKE_FILE} resources | grep -e 'previous_proof_hash'
	
check-autopay:
# swarm accounts start with a balance of 10, check that the balance increases
	@while [[ ${NOW} -le ${END} ]] ; do \
			if PERSONA=alice make -f ${MAKE_FILE} query-autopay | grep -e '88E74DFED34420F2AD8032148280A84B'; then \
				echo TX SUCCESS ; \
				break ; \
			else \
				echo . ; \
			fi ; \
			echo "Sleeping for 5 secs" ; \
			sleep 5 ; \
	done
	

# check-transfer:
# # swarm accounts start with a balance of 10, check that the balance increases
# 	@while [[ ${NOW} -le ${END} ]] ; do \
# 			if PERSONA=alice make -f ${MAKE_FILE} balance-bob | grep -e '10' -e '11' -e '15'; then \
# 				echo TX SUCCESS ; \
# 				break ; \
# 			else \
# 				echo . ; \
# 			fi ; \
# 			echo "Sleeping for 5 secs" ; \
# 			sleep 5 ; \
# 	done