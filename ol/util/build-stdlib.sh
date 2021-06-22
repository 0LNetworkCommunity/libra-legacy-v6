#!/bin/bash
set -e # exit on error

echo "Step-1: building and running diem-framework ..."
cargo r --release -p diem-framework
# cargo r --release -p diem-framework -- --no-doc # for quick iteration

printf "\nStep-2: cp language/diem-framework/releases/artifacts/current/transaction_script_builder.rs sdk/transaction-builder/src/stdlib.rs\n"
cp language/diem-framework/releases/artifacts/current/transaction_script_builder.rs sdk/transaction-builder/src/stdlib.rs

printf "\nDone"