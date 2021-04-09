#!/bin/bash

# targeting ububtu
apt update
apt install -y git vim zip jq build-essential cmake clang llvm libgmp-dev secure-delete pkg-config libssl-dev lld
curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable -y
export "$HOME/.cargo/bin:$PATH"
cargo install toml-cli
cargo install sccache

echo "Manually add `export RUSTC_WRAPPER=sccache` to your bash profile ~/.bashrc`