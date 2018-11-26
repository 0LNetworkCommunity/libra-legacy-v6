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

# Delete trailing whitespace.  Also delete any leading or trailing lines that
# are only whitespace.  Operates on all files in the git repo EXCEPT .rs files,
# since those are handled by `cargo fmt`.  Finally, delete RLS log files.

set -euo pipefail
cargo fmt
git ls-files -z | { if false; then cat; else grep -vEz '\.rs$'; fi; } | xargs -0 sed -ni -- '
s/\s\s*$//
/./,$!d
/^$/! b done
h
:loop
n
s/\s\s*$//
H
/^$/bloop
g
:done
# s/POA Networks, Ltd\./POA Networks Ltd./g
p
'
rm -f rls*.log
