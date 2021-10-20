SHELL=/usr/bin/env bash
DATA_PATH = ${HOME}/.0L
SOURCE = ${HOME}/libra

LIST = alice bob carol dave eve

all: 
	@for i in $(LIST); do \
		# echo $$i ; \
		PERSONA=$$i MNEM=$$(cat ${SOURCE}/ol/fixtures/mnemonic/$$i.mnem) make fixtures-test; \
		PERSONA=$$i MNEM=$$(cat ${SOURCE}/ol/fixtures/mnemonic/$$i.mnem) make fixtures-prod; \
	done

check: 
	@for i in $(LIST); do \
		echo $$i ; \
		PERSONA=$$i MNEM=$$(cat ${SOURCE}/ol/fixtures/mnemonic/$$i.mnem) make check; \
	done

echo: 
	@echo ${PERSONA}:
	@echo ${MNEM}

fixtures-test: 
	cd ../onboard && NODE_ENV=test TEST=y cargo r -p onboard -- val --genesis-ceremony --autopay-file ${SOURCE}/ol/fixtures/autopay/${PERSONA}.autopay_batch.json
	cp ${DATA_PATH}/blocks/block_0.json ${SOURCE}/ol/fixtures/blocks/test/${PERSONA}/
	cp ${DATA_PATH}/account.json ${SOURCE}/ol/fixtures/account/${PERSONA}.account.json

fixtures-prod: 
	cd ../onboard && NODE_ENV=prod TEST=y cargo r -p onboard -- val --genesis-ceremony --autopay-file ${SOURCE}/ol/fixtures/autopay/${PERSONA}.autopay_batch.json
	cp ${DATA_PATH}/blocks/block_0.json ${SOURCE}/ol/fixtures/blocks/prod/${PERSONA}/
	cp ${DATA_PATH}/blocks/block_0.json ${SOURCE}/ol/fixtures/blocks/stage/${PERSONA}/