SHELL=/usr/bin/env bash
DATA_PATH = ${HOME}/.0L
SWARM_TEMP = ${DATA_PATH}/swarm_temp
SOURCE_PATH = ${HOME}/libra/
UNAME := $(shell uname)

NODE_ENV=test

test: swarm-genesis swarm

fork-genesis:
	cargo run -p ol-genesis-tools -- --genesis ${DATA_PATH}/genesis_from_snapshot.blob --snapshot ../fixtures/state-snapshot/194/state_ver_74694920.0889/state.manifest

swarm-genesis:
	cargo run -p ol-genesis-tools -- --swarm --genesis ${DATA_PATH}/genesis_from_snapshot.blob --snapshot ../fixtures/state-snapshot/194/state_ver_74694920.0889/state.manifest

build: 
	cargo build -p libra-node -p cli

swarm: build
	 cargo run -p libra-swarm -- --libra-node ${SOURCE_PATH}/target/debug/libra-node -c ${DATA_PATH}/swarm_temp -n 1 -s --cli-path ${SOURCE_PATH}/target/debug/cli --genesis-blob-path ${DATA_PATH}/genesis_from_snapshot.blob

