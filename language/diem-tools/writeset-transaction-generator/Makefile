ifndef SOURCE_PATH
SOURCE_PATH = $$HOME/libra
endif

ifndef DATA_PATH
DATA_PATH = $$HOME/.0L/
endif

wipe:
	rm -rf ${DATA_PATH}/db
	cp -r ${DATA_PATH}/db-reference ${DATA_PATH}/db
	STEP=wipe make dump

tx:
	cd ${SOURCE_PATH} && cargo r -p diem-writeset-generator -- --db ${DATA_PATH}/db --output ${DATA_PATH}/restore/rescue.blob rescue 46A7A744B5D33C47F6B20766F8088B10 

tx-reconfig:
	cd ${SOURCE_PATH} && cargo r -p diem-writeset-generator -- --db ${DATA_PATH}/db --output ${DATA_PATH}/restore/rescue.blob reconfig 

tx-stdlib:
	cd ${SOURCE_PATH} && cargo r -p diem-writeset-generator -- --db ${DATA_PATH}/db --output ${DATA_PATH}/restore/rescue.blob reconfig 

tx-time:
	cd ${SOURCE_PATH} && cargo r -p diem-writeset-generator -- --db ${DATA_PATH}/db --output ${DATA_PATH}/restore/rescue.blob time


check:
	cd ${SOURCE_PATH} && cargo r -p db-bootstrapper -- ${DATA_PATH}/db/ --genesis-txn-file ${DATA_PATH}/restore/rescue.blob

commit:
	cd ${SOURCE_PATH} && cargo r -p db-bootstrapper -- ${DATA_PATH}/db/ --genesis-txn-file ${DATA_PATH}/restore/rescue.blob --commit --waypoint-to-verify ${WAY}
	STEP=commit make dump

diff:
	@shasum ${DATA_PATH}/dump-wipe
	@shasum ${DATA_PATH}/dump-commit
	@shasum ${DATA_PATH}/dump-start

start:
	ol init --key-store --waypoint ${WAY}
	diem-node -f ${DATA_PATH}/validator.node.yaml

.PHONY:dump

dump:
	rm -f ${DATA_PATH}/dump
	cd ${SOURCE_PATH} && cargo r -p diem-transaction-replay -- --db ${DATA_PATH}/db annotate-account 00000000000000000000000000000000 > ${DATA_PATH}/dump-${STEP}
