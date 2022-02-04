#! /usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"

export ZIG_LOCAL_CACHE_DIR="$PROJECT_ROOT/.zigcache/"

set -x

if [[ -z "${ZTARGET+x}" ]]; then
  zig c++ "$@"
else
  SYSROOT="$(xcrun --show-sdk-path)"
  # The -I, -F and -L flags are required to configure the sysroot correctly - see https://github.com/ziglang/zig/issues/10513#issuecomment-1005652047.
  zig c++ -target "$ZTARGET" --sysroot "$SYSROOT" "-I$SYSROOT/usr/include" "-F$SYSROOT/System/Library/Frameworks" "-L$SYSROOT/usr/lib" "$@"
fi

set +x
