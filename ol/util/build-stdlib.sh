#!/bin/bash
set -e # exit on error

echo "Building and running diem-framework package ..."
printf "This builds:  
    language/diem-framework/modules/*
    language/diem-framework/modules/0L/*
    language/diem-framework/modules/0L_transaction_scripts/*
    language/move-stdlib/modules/* \n\n"

cargo r --release -p diem-framework -- $1
# cargo r --release -p diem-framework -- $1 --no-doc # for dev. quick iteration

printf "Done\n"