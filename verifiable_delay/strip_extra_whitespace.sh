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

# Delete trailing whitespace.  Also delete any leading or trailing lines that are
# only whitespace.  Operates on all files in the git repo.

set -euo pipefail
git ls-files -z | xargs -0 sed -i -- '
# Fix old copyright notices ― no longer used.
# s/Block Notary Inc/POA Networks, Ltd./g
# s/Poa Networks, Inc\./POA Networks, Ltd./g

# Strip trailing whitespace
s/\s\+$//
:a
/[^\s]/,$!d
/^\s*$/ {
   $d
   # Delete non-newline whitespace
   s/[^\n]//g
   # Add the next line
   N
}
/\n\s*$/ba
'
exec cargo fmt