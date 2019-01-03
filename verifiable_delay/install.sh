#!/bin/sh --
export RUSTFLAGS='-Clto -Cpanic=abort'
export DEBIAN_FRONTEND=noninteractive
exec 2>/dev/null
sudo apt-get -y -q update
sudo apt-get install git build-essential libgmp3-dev -y -q
curl https://sh.rustup.rs -sSf | sh -s  -- -y
export PATH="$HOME/.cargo/bin:$PATH"
rustup install nightly
rustup default nightly
cargo install --force --path=vdf-competition || :
exit 0
