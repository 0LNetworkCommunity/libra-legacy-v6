SHELL=/usr/bin/env bash
DATA_PATH = ${HOME}/.0L
SOURCE = ${HOME}/libra

LIST = alice bob carol dave eve

# PERSONA = alice

all: 
	@for i in $(LIST); do \
		# echo $$i ; \
		PERSONA=$$i make onboard; \
	done

MNEM = $(shell cat ${SOURCE}/ol/fixtures/mnemonic/${PERSONA}.mnem)

check: 
	@echo ${MNEM}

onboard: 
	cd ../onboard && cargo r -p onboard -- val --genesis-ceremony --autopay-file ${SOURCE}/ol/fixtures/autopay/${PERSONA}.autopay_batch.json
	cp ${DATA_PATH}/blocks/block_0.json ${SOURCE}/ol/fixtures/blocks/${NODE_ENV}/${PERSONA}/
	cp ${DATA_PATH}/account.json ${SOURCE}/ol/fixtures/account/${PERSONA}.account.json
