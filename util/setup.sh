#!/bin/bash

# targeting ububtu
apt update
apt install -y git vim zip jq build-essential cmake clang llvm libgmp-dev secure-delete pkg-config libssl-dev lld
curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable -y
cargo install toml-cli
cargo install sccache

echo "Rust is installed now. Great!\
\
To get started you need Cargo's bin directory ($HOME/.cargo/bin) in your PATH\
environment variable. Next time you log in this will be done\
automatically.\
To configure your current shell, run:\
source $HOME/.cargo/env\
"

echo "Manually add 'export RUSTC_WRAPPER=sccache' to your bash profile ~/.bashrc"