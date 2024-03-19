#!/bin/bash

set -euo pipefail

SOURCE_ROOT="BLAKE3/c"
TARGET_ROOT="BLAKE3-build"

mkdir -p "${TARGET_ROOT}"
pushd "${TARGET_ROOT}"
cmake -DCMAKE_BUILD_TYPE=Release ../"${SOURCE_ROOT}"
make
popd
