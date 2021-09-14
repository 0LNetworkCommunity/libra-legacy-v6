#!/bin/bash
set -e # exit on error

printf "Warning: Run this script in project root\n\n"

echo "Step-1: building and running diem-framework ..."
cargo r --release -p diem-framework
# cargo r --release -p diem-framework -- --no-doc # for quick iteration

printf "\nStep-2: Copying 'language/diem-framework/releases/artifacts/current/transaction_script_builder.rs' into 'sdk/transaction-builder/src/stdlib.rs' ...\n"
cp language/diem-framework/releases/artifacts/current/transaction_script_builder.rs sdk/transaction-builder/src/stdlib.rs

printf "\nDone\n"