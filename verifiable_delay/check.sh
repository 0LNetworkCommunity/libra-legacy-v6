#!/bin/sh --
a=$(exec cargo run prove "$1" "$2") || exit $?
exec ./target/debug/vdf-cli verify "$1" "$2" "$a"
