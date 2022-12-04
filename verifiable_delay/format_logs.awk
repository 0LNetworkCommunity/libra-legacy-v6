#!/usr/bin/gawk -E
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
function die(message, status) {
   print message > "/dev/stderr";
   if (0 == status) { status = 1; }
   exit (retcode = status);
}
BEGIN {
   if (ARGC != 3) {
      die("Must have exactly 2 arguments!");
   }
   if (ARGV[1] == ARGV[2]) {
      die("Arguments must not be equal!");
   }
   multiply = ARGV[1];
   square = ARGV[2];
   ARGC = 0;
}
/-?[0-9]+,-?[0-9]+,-?[0-9]+\|-?[0-9]+,-?[0-9]+,-?[0-9]+\|-?[0-9]+,-?[0-9]+,-?[0-9]+$/ {
   print $0 >> multiply;
   next;
}
/-?[0-9]+,-?[0-9]+,-?[0-9]+\|-?[0-9]+,-?[0-9]+,-?[0-9]+$/ {
   print $0 >> square;
   sub(/^[^|]*/, "&|&", $0);
   print $0 >> multiply;
   next;
}
{
   print;
}
END {
   if (retcode) {
      exit retcode;
   }
   if (status = close(square)) {
      die("Closing ARGV[2] failed: " status);
   }
   if (status = close(multiply)) {
      die("Closing ARGV[1] failed: " status);
   }
}
