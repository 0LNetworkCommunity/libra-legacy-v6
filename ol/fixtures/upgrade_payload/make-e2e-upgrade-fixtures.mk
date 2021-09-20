SHELL=/usr/bin/env bash

ifndef SOURCE_PATH
SOURCE_PATH = ${HOME}/libra/
endif

FIXTURES_PATH = ${SOURCE_PATH}ol/fixtures/upgrade_payload/

fixtures: rename-files stdlib check-foo copy reverse-rename stdlib-again

stdlib:
	cd ${SOURCE_PATH} && cargo run --release -p diem-framework -- --create-upgrade-payload

stdlib-again:
# TODO: can't run recipes twice?
	cd ${SOURCE_PATH} && cargo run --release -p diem-framework -- --create-upgrade-payload


rename-files:
# Module rename
	mv ${SOURCE_PATH}/language/diem-framework/modules/0L/Upgrade.move ${SOURCE_PATH}/language/diem-framework/modules/0L/Upgrade.move.temp

	mv ${SOURCE_PATH}/language/diem-framework/modules/0L/Upgrade.move.e2e ${SOURCE_PATH}/language/diem-framework/modules/0L/Upgrade.move

# transaction script rename
	mv ${SOURCE_PATH}language/diem-framework/modules/0L_transaction_scripts/ol_e2e_test_upgrade_foo_tx.move.e2e ${SOURCE_PATH}language/diem-framework/modules/0L_transaction_scripts/ol_e2e_test_upgrade_foo_tx.move

check-foo:
# checks the foo function exists in the compile
	grep ${SOURCE_PATH}/language/diem-framework/staged/stdlib.mv -e foo

copy:
	cp ${SOURCE_PATH}/language/diem-framework/staged/stdlib.mv ${FIXTURES_PATH}/foo_stdlib.mv

# cp ${SOURCE_PATH}/language/diem-framework/releases/artifacts/current/script_abis/ol_e2e_test_upgrade_foo_tx/ol_oracle_upgrade_foo_tx.abi ${FIXTURES_PATH}/tx_scripts/ol_oracle_upgrade_foo_tx.abi

# cp ${SOURCE_PATH}/language/diem-framework/releases/artifacts/current/script_abis/ol_e2e_test_upgrade_foo_tx/ol_oracle_upgrade_foo_tx.abi ${FIXTURES_PATH}/tx_scripts/ol_oracle_upgrade_foo_tx.abi

# cp ${SOURCE_PATH}/language/diem-framework/releases/artifacts/current/modules/*_OracleUpgradeFooTx.mv ${FIXTURES_PATH}/tx_scripts/

reverse-rename:
# Module rename
	mv ${SOURCE_PATH}/language/diem-framework/modules/0L/Upgrade.move ${SOURCE_PATH}/language/diem-framework/modules/0L/Upgrade.move.e2e
	
	mv ${SOURCE_PATH}/language/diem-framework/modules/0L/Upgrade.move.temp ${SOURCE_PATH}/language/diem-framework/modules/0L/Upgrade.move

# transaction script rename
	mv ${SOURCE_PATH}language/diem-framework/modules/0L_transaction_scripts/ol_e2e_test_upgrade_foo_tx.move ${SOURCE_PATH}language/diem-framework/modules/0L_transaction_scripts/ol_e2e_test_upgrade_foo_tx.move.e2e