#!/bin/bash
set -e # exit on error

echo "Building and creating upgrade payload ..."
cargo r --release -p diem-framework -- --create-upgrade-payload

printf "\nDone\n"