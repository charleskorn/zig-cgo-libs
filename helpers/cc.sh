#! /usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"

export ZIG_LOCAL_CACHE_DIR="$PROJECT_ROOT/.zigcache/"

set -x

if [[ -z "${ZTARGET+x}" ]]; then
  zig cc "$@"
else
  SYSROOT="$(xcrun --show-sdk-path)"
  # The -I, -F and -L flags are required to configure the sysroot correctly - see https://github.com/ziglang/zig/issues/10790#issuecomment-1030712395.
  zig cc -target "$ZTARGET" --sysroot "$SYSROOT" "-I/usr/include" "-F/System/Library/Frameworks" "-L/usr/lib" "$@"
fi

set +x
