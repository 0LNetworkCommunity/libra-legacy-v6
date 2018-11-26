#!/bin/bash --
# Copyright 2018 POA Networks, Ltd.
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
done < <(grep -E '^[a-f0-9]{64},[0-9]{2,4},[0-9a-f]+$' test_data.csv)
"$k"
