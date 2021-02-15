#!/bin/bash

# targeting ububtu
export NODE_ENV=prod
apt update
apt install -y git vim zip jq build-essential cmake clang llvm libgmp-dev secure-delete pkg-config libssl-dev
curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable -y
export "$HOME/.cargo/bin:$PATH"
