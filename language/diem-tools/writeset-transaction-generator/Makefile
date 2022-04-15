ifndef SOURCE_PATH
SOURCE_PATH = $$HOME/libra
endif

ifndef DATA_PATH
DATA_PATH = $$HOME/.0L
endif

DATE = $(shell date "+%Y-%m-%d-%T")

ifndef VALS
# FOR TEST PURPOSES
VALS = ECAF65ADD1B785B0495E3099F4045EC0 46A7A744B5D33C47F6B20766F8088B10 7EC16859C24200D8E074809D252AC740
endif

wipe:
	mv -f ${DATA_PATH}/db ${DATA_PATH}/db.bak.${DATE} | true
	cp -r ${DATA_PATH}/db-reference ${DATA_PATH}/db
	STEP=wipe make dump

tx:
	cd ${SOURCE_PATH} && cargo r -p diem-writeset-generator -- --db ${DATA_PATH}/db --output ${DATA_PATH}/restore/rescue.blob rescue ${VALS}

tx-vals:
	cd ${SOURCE_PATH} && cargo r -p diem-writeset-generator -- --db ${DATA_PATH}/db --output ${DATA_PATH}/restore/rescue.blob update-validators ${VALS}


# tx-reconfig:
# 	cd ${SOURCE_PATH} && cargo r -p diem-writeset-generator -- --db ${DATA_PATH}/db --output ${DATA_PATH}/restore/rescue.blob reconfig 

# tx-stdlib:
# 	cd ${SOURCE_PATH} && cargo r -p diem-writeset-generator -- --db ${DATA_PATH}/db --output ${DATA_PATH}/restore/rescue.blob reconfig 

# tx-time:
# 	cd ${SOURCE_PATH} && cargo r -p diem-writeset-generator -- --db ${DATA_PATH}/db --output ${DATA_PATH}/restore/rescue.blob time


check:
	cd ${SOURCE_PATH} && cargo r -p db-bootstrapper -- ${DATA_PATH}/db/ --genesis-txn-file ${DATA_PATH}/restore/rescue.blob

check-alt:
	cd ${SOURCE_PATH} && cargo r -p db-bootstrapper -- ${DATA_PATH}/db/ --genesis-txn-file ${DATA_PATH}/restore/rescue.blob | grep -oP 'waypoint: \K\w+:\w+' > ${DATA_PATH}/rescue_waypoint.txt 
	@echo Waypoint: $(shell cat ${DATA_PATH}/rescue_waypoint.txt )

commit:
	cd ${SOURCE_PATH} && cargo r -p db-bootstrapper -- ${DATA_PATH}/db/ --genesis-txn-file ${DATA_PATH}/restore/rescue.blob --commit --waypoint-to-verify $(shell cat ${DATA_PATH}/rescue_waypoint.txt)
	STEP=commit make dump

diff:
	@shasum ${DATA_PATH}/dump-wipe
	@shasum ${DATA_PATH}/dump-commit
	@shasum ${DATA_PATH}/dump-start

init:
	mv ${DATA_PATH}/key_store.json ${DATA_PATH}/key_store.json.bak.${DATE}
	ol init --key-store --waypoint $(shell cat ${DATA_PATH}/rescue_waypoint.txt)

start:
	diem-node -f ${DATA_PATH}/validator.node.yaml

.PHONY:dump

dump:
	rm -f ${DATA_PATH}/dump
	cd ${SOURCE_PATH} && cargo r -p diem-transaction-replay -- --db ${DATA_PATH}/db annotate-account 00000000000000000000000000000000 > ${DATA_PATH}/dump-${STEP}
