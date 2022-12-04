#!/bin/bash --
# Copyright 2018 POA Networks Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# and limitations under the License.

set -euo pipefail

# Change to the directory containing this script
case $0 in
   (/*) cd "${0%/*}/";;
   (*/*) cd "./${0%/*}";;
   (*) :;;
esac

cargo test --all
cargo test --all --release
cargo run --release >/dev/null 2>&1 || :
IFS=, k=: count=0
prove () {
   fst_arg=$1
   case a$1 in
      (a-tpietrzak|a-twesolowski) :;;
      (*) echo 'internal error' "$1" >&2; exit 1;;
   esac
   shift
   exec ./target/release/vdf-cli "$fst_arg" -- "$@"
}

test_output () {
   local correct_output actual_output
   correct_output=$1
   shift
   if actual_output=$("$@") && [[ "$correct_output" = "$actual_output" ]]; then
      echo SUCCESS
   else
      echo FAILED
      k=false
   fi
}

for proof_type in wesolowski pietrzak; do
   while read challenge iterations correct_proof; do
      printf "Checking proof of type %q on input %d... " "$proof_type" "$((count += 1))"
      test_output "$correct_proof" ./target/release/vdf-cli "-t$proof_type" -- "$challenge" "$iterations"
      printf "Checking verification of input %d... " "$count"
      test_output 'Proof is valid' ./target/release/vdf-cli "-t$proof_type" -- "$challenge" "$iterations" "$correct_proof"
   done < <(grep -E '^[a-f0-9]{64},[0-9]{2,4},[0-9a-f]+$' "$proof_type.csv")
done
"$k"
