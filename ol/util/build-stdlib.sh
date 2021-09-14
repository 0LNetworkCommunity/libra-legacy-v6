#!/bin/bash
set -e # exit on error

echo "Building and running diem-framework ..."
cargo r --release -p diem-framework
# cargo r --release -p diem-framework -- --no-doc # for quick iteration

printf "\nDone\n"