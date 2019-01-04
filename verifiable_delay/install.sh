#!/bin/sh --
exec 2>/dev/null
export RUSTFLAGS='-Clto -Cpanic=abort'
export DEBIAN_FRONTEND=noninteractive
sudo apt-get -y -q update
sudo apt-get install git build-essential libgmp3-dev curl -y -q
curl https://sh.rustup.rs -sSf | sh -s  -- -y
. ~/.cargo/env
rustup install nightly
rustup default nightly
cargo install --force --path=vdf-competition
