ifndef SOURCE_PATH
SOURCE_PATH = $$HOME/libra
endif

ifndef DATA_PATH
DATA_PATH = $$HOME/.0L
RESCUE_PATH = ${DATA_PATH}/rescue

endif

DATE = $(shell date "+%Y-%m-%d-%T")

ifndef VALS
# FOR TEST PURPOSES
VALS = ECAF65ADD1B785B0495E3099F4045EC0
# VALS = ECAF65ADD1B785B0495E3099F4045EC0 46A7A744B5D33C47F6B20766F8088B10 7EC16859C24200D8E074809D252AC740
endif

wipe:
	mkdir ${RESCUE_PATH} | true
# rm -rf ${DATA_PATH}/db
	mv -f ${DATA_PATH}/db ${DATA_PATH}/db.bak.${DATE} | true
	cp -r ${DATA_PATH}/db-reference ${DATA_PATH}/db
	STEP=wipe make dump

tx:
	mkdir ${RESCUE_PATH} | true
	cd ${SOURCE_PATH} && cargo r -p diem-writeset-generator -- --db ${DATA_PATH}/db --output ${RESCUE_PATH}/rescue.blob rescue ${VALS}

tx-debug:
	cd ${SOURCE_PATH} && cargo r -p diem-writeset-generator -- --db ${DATA_PATH}/db --output ${RESCUE_PATH}/rescue.blob debug ${VALS}

tx-vals:
	cd ${SOURCE_PATH} && cargo r -p diem-writeset-generator -- --db ${DATA_PATH}/db --output ${RESCUE_PATH}/rescue.blob update-validators ${VALS}

tx-boundary:
	cd ${SOURCE_PATH} && cargo r -p diem-writeset-generator -- --db ${DATA_PATH}/db --output ${RESCUE_PATH}/rescue.blob boundary ${VALS}

tx-reconfig:
	cd ${SOURCE_PATH} && cargo r -p diem-writeset-generator -- --db ${DATA_PATH}/db --output ${RESCUE_PATH}/rescue.blob reconfig

tx-stdlib:
	cd ${SOURCE_PATH} && cargo r -p diem-writeset-generator -- --db ${DATA_PATH}/db --output ${DATA_PATH}/restore/rescue.blob reconfig 

tx-time:
	cd ${SOURCE_PATH} && cargo r -p diem-writeset-generator -- --db ${DATA_PATH}/db --output ${RESCUE_PATH}/rescue.blob time

tx-testnet:
	cd ${SOURCE_PATH} && cargo r -p diem-writeset-generator -- --db ${DATA_PATH}/db --output ${RESCUE_PATH}/rescue.blob testnet

tx-epoch-time:
	cd ${SOURCE_PATH} && cargo r -p diem-writeset-generator -- --db ${DATA_PATH}/db --output ${RESCUE_PATH}/rescue.blob epoch-time 

tx-migrate:
	cd ${SOURCE_PATH} && cargo r -p diem-writeset-generator -- --db ${DATA_PATH}/db --output ${RESCUE_PATH}/rescue.blob migrate ${SOURCE_PATH}/ol/fixtures/rescue/ancestry.json ${SOURCE_PATH}/ol/fixtures/rescue/make_whole.json ${VALS}

# tx-custom:
# 	cd ${SOURCE_PATH} && cargo r -p diem-writeset-generator -- --db ${DATA_PATH}/db --output ${DATA_PATH}/restore/rescue.blob build-custom-script set_testnet.move '{}'


check:
	cd ${SOURCE_PATH} && cargo r -p db-bootstrapper -- ${DATA_PATH}/db/ --genesis-txn-file ${RESCUE_PATH}/rescue.blob | grep -oP 'waypoint: \K\w+:\w+' > ${RESCUE_PATH}/rescue_waypoint.txt 
	@echo Waypoint: $(shell cat ${RESCUE_PATH}/rescue_waypoint.txt )

commit:
	cd ${SOURCE_PATH} && cargo r -p db-bootstrapper -- ${DATA_PATH}/db/ --genesis-txn-file ${RESCUE_PATH}/rescue.blob --commit --waypoint-to-verify $(shell cat ${RESCUE_PATH}/rescue_waypoint.txt)
	STEP=commit make dump

diff:
	@shasum ${RESCUE_PATH}/dump-wipe | true
	@shasum ${RESCUE_PATH}/dump-commit | true
	@shasum ${RESCUE_PATH}/dump-start | true

init:
	mv ${DATA_PATH}/key_store.json ${DATA_PATH}/key_store.json.bak.${DATE} | true
	ol init --key-store --waypoint $(shell cat ${RESCUE_PATH}/rescue_waypoint.txt)

start:
	cd ${SOURCE_PATH} && cargo r -p diem-node -- -f ${DATA_PATH}/validator.node.yaml 2>&1 | tee ${DATA_PATH}/logs/node.log

.PHONY:dump

dump:
	mkdir ${RESCUE_PATH} | true
	cd ${SOURCE_PATH} && cargo r -p diem-transaction-replay -- --db ${DATA_PATH}/db annotate-account 00000000000000000000000000000000 > ${RESCUE_PATH}/dump-${STEP}

dump-self:
	mkdir ${RESCUE_PATH} | true
	cd ${SOURCE_PATH} && cargo r -p diem-transaction-replay -- --db ${DATA_PATH}/db annotate-account ${VALS} > ${RESCUE_PATH}/dump-self

test: wipe tx check commit init start


# NOTES for testing

# Step 0: change this makefile so that VALS= at top has your node address. Use a sanitized validator.node.yaml file.

# STEP 1: Jailbreak the backup
# >make test

# - Get a new STDLIB that doesn't have the DiemConfig::reconfigure_ timestamp checking.
# - STDLIB also shouldn't advance if less than 10k blocks have been committed since last boundary.
# - reset the validator set to one validator, so that blocks can make progress. NOTE: do not trigger epoch boundary since the state may not have all info needed.

# Step 2: Run the node
# make some progres in blocks.

# Step 3: Submit a test net transaction writeset.
# > make tx-testnet check commit init start

# Step 4: Run node again

# STEP 5: Trigger an epoch boundary
# > make tx-boundary check commit init start


# - makes sure theres only a validator set of 1
# - resets the counters

### deprecated.

# Step 2: Start the node
# make some progres in blocks.

# STEP 3: Trigger a val set update WITHOUT triggering epoch counters reset.

# Don't know why


# Step 4: Start node again

# STEP 5: Trigger an epoch boundary
# new writeset "boundary"
# - makes sure theres only a validator set of 1
# - resets the counters