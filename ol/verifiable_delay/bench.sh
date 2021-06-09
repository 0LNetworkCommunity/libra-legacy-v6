#!/bin/sh --
set -euf
unset IFS RUST_BACKTRACE
if test $# -ne 1; then
   printf 'Must have exactly one argument\n' >&2; exit 1
fi
case $1 in
   (*[!a-f0-9]*) printf 'Invalid character in hex argument\n' >&2; exit 1;;
esac
if test "$((${#1} & 1))" -ne 0; then
   printf 'Argument must be of even length\n' >&2; exit 1
fi

VDF_BENCHMARK_SEED=$1 cargo bench -p vdf --bench classgroup-bench
