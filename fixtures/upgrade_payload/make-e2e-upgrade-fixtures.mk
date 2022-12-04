SHELL=/usr/bin/env bash

ifndef SOURCE_PATH
SOURCE_PATH = ${HOME}/libra
endif

LIBRA_PATH = ${SOURCE_PATH}
FIXTURES_PATH = ${LIBRA_PATH}/ol/fixtures/upgrade_payload
DF_SRC_PATH = ${LIBRA_PATH}/diem-move/diem-framework/DPN/sources
DF_PATH = ${LIBRA_PATH}/diem-move/diem-framework
MOVE_BIN_PATH = ${SOURCE_PATH}/DPN/staged/stdlib.mv
# Create foo_stdlib.mv which contains"foo" symbol(fn)
fixtures: rename-files stdlib check-foo copy reverse-rename stdlib-again

stdlib:
	cd ${SOURCE_PATH} && make stdlib

stdlib-again:
# TODO: can't run recipes twice?
	cd ${SOURCE_PATH} && make stdlib

rename-files:
# Module rename
	mv ${DF_SRC_PATH}/0L/Upgrade.move ${DF_SRC_PATH}/0L/Upgrade.move.temp
	mv ${DF_SRC_PATH}/0L/Upgrade.move.e2e ${DF_SRC_PATH}/0L/Upgrade.move

# transaction script rename
	mv ${DF_SRC_PATH}/0L_transaction_scripts/ol_e2e_test_upgrade_foo_tx.move.e2e \
	   ${DF_SRC_PATH}/0L_transaction_scripts/ol_e2e_test_upgrade_foo_tx.move

check-foo:
# checks the foo function exists in the compile
	grep ${MOVE_BIN_PATH} -e foo

copy:
	cp ${MOVE_BIN_PATH} ${FIXTURES_PATH}/foo_stdlib.mv

# cp ${DF_PATH}/releases/artifacts/current/script_abis/ol_e2e_test_upgrade_foo_tx/ol_oracle_upgrade_foo_tx.abi \ 
#    ${FIXTURES_PATH}/tx_scripts/ol_oracle_upgrade_foo_tx.abi

# cp ${DF_PATH}/releases/artifacts/current/script_abis/ol_e2e_test_upgrade_foo_tx/ol_oracle_upgrade_foo_tx.abi ${FIXTURES_PATH}/tx_scripts/ol_oracle_upgrade_foo_tx.abi

# cp ${DF_PATH}/releases/artifacts/current/modules/*_OracleUpgradeFooTx.mv ${FIXTURES_PATH}/tx_scripts/

reverse-rename:
# Module rename
	mv ${DF_SRC_PATH}/0L/Upgrade.move ${DF_SRC_PATH}/0L/Upgrade.move.e2e
	mv ${DF_SRC_PATH}/0L/Upgrade.move.temp ${DF_SRC_PATH}/0L/Upgrade.move

# transaction script rename
	mv ${DF_SRC_PATH}/0L_transaction_scripts/ol_e2e_test_upgrade_foo_tx.move \
	   ${DF_SRC_PATH}/0L_transaction_scripts/ol_e2e_test_upgrade_foo_tx.move.e2e