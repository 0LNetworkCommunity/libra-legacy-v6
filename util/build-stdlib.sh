#!/bin/bash
set -e # exit on error

echo -e "\nBuilding and running diem-framework package ..."
printf "This builds:  
    diem-move/diem-framework/DPN/sources/*
    diem-move/diem-framework/DPN/sources/0L/*
    diem-move/diem-framework/DPN/sources/0L_transaction_scripts/* \n\n"

cd diem-move/diem-framework
cargo r --release -- $1
# cargo r --release -- $1 --no-doc # for dev. quick iteration

printf "Done\n"