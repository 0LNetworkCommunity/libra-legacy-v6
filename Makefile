SHELL=/usr/bin/env bash

all : all-bins

# Add other binaries later.
install:
	cp -f target/release/ol_miner /usr/local/bin/ol_miner
	cp -f target/release/libra-management /usr/local/bin/libra-management

all-bins:
	cargo build --all --bins --release --exclude cluster-test

deps:
	sudo apt-get update
	sudo apt-get install build-essential cmake clang llvm libgmp-dev
