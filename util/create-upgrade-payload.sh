#!/bin/bash
set -e # exit on error

echo "Creating upgrade payload ..."
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
$THIS_DIR/build-stdlib.sh --create-upgrade-payload