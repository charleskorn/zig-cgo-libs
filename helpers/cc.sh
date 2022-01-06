#! /usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"

export ZIG_LOCAL_CACHE_DIR="$PROJECT_ROOT/.zigcache/"

set -x

if [[ "$ZTARGET" == *-macos-* ]]; then
  SYSROOT="$(xcrun --show-sdk-path)"
  # The -I, -F and -L flags are required to configure the sysroot correctly - see https://github.com/ziglang/zig/issues/10513#issuecomment-1005652047.
  # These -Wno-... flags are based on the suggestions in https://github.com/golang/go/issues/38876#issuecomment-669338355. They could also be set with the CGO_CPPFLAGS environment variable.
  zig cc -target "$ZTARGET" --sysroot "$SYSROOT" "-I$SYSROOT/usr/include" "-F$SYSROOT/System/Library/Frameworks" "-L$SYSROOT/usr/lib" -Wno-expansion-to-defined -Wno-availability -Wno-nullability-completeness "$@"
else
  zig cc -target "$ZTARGET" "$@"
fi

set +x
