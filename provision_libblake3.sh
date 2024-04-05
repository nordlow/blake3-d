#!/bin/bash

set -euo pipefail

SOURCE_ROOT="BLAKE3/c"
TARGET_ROOT="BLAKE3-build"

mkdir -p "${TARGET_ROOT}"
pushd "${TARGET_ROOT}" > /dev/null

# ok to use "-march=native" because of no distribution
cmake -DBUILD_SHARED_LIBS=yes -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS="-march=native" ../"${SOURCE_ROOT}"
make --quiet

popd > /dev/null
