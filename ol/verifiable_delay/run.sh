#!/bin/sh
unset RUST_BACKTRACE
exec ~/.cargo/bin/vdf-competition "$@"
