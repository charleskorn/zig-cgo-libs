#! /usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"

export ZIG_LOCAL_CACHE_DIR="$PROJECT_ROOT/.zigcache/"

set -x

if [[ "$ZTARGET" == "*-macos-*" ]]; then
  SYSROOT="$(xcrun --show-sdk-path)"
  zig c++ -target "$ZTARGET" --sysroot "$SYSROOT" "$@"
else
  zig c++ -target "$ZTARGET" "$@"
fi

set +x
