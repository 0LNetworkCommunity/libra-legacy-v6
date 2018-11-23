#!/bin/bash --
set -euo pipefail

# Change to the directory containing this script
case $0 in
   (/*) cd "${0%/*}/";;
   (*/*) cd "./${0%/*}";;
   (*) :;;
esac

cargo test
cargo test --release
IFS=, k=: count=0
prove () {
   exec ./target/release/vdf-cli prove -- "$@"
}

verify() {
   exec ./target/release/vdf-cli verify -- "$@"
}

test_output () {
   q=$1
   shift
   if correct_output=$("$@") && [[ "$correct_output" = "$q" ]]; then
      echo SUCCESS
   else
      echo FAILED
      k=false
   fi
}

while read challenge iterations correct_proof; do
   printf "Checking proof of input %d... " "$((count += 1))"
   test_output "$correct_proof" prove "$challenge" "$iterations"
   printf "Checking verification of input %d... " "$count"
   test_output 'Proof is valid' verify "$challenge" "$iterations" "$correct_proof"
done < <(grep -E '^[a-f0-9]+,[0-9]+,[0-9a-f]+$' test_data.csv)
"$k"
