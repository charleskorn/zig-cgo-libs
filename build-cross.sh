#! /usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"

function main() {
  if [[ $# -ne 3 ]]; then
    echoRed "Must provide exactly three arguments."
    exit 1
  fi

	echoBlue "Preparing..."
	rm -rf "$BUILD_DIR"
	mkdir -p "$BUILD_DIR"

  clearGoBuildCache
  build "$1" "$2" "$3"
}

function clearGoBuildCache() {
  go clean -cache
}

function build() {
	local binaryType=$1
	local os=$2
	local arch=$3

	echo
	echoBlue "Building $binaryType library for $os $arch..."

	local outputDir="$BUILD_DIR/$os/$arch/$binaryType"
	mkdir -p "$outputDir"

	local zos="$os"

	case $os in
		darwin)
			zos="macos"
			;;
	esac

	local zarch

	case $arch in
		arm64)
			zarch="aarch64"
			;;
		amd64)
			zarch="x86_64"
			;;
		*)
			echo "Unknown architecture $arch" >/dev/stderr
			exit 1
			;;
	esac

	local outputFile

	case $binaryType in
		shared)
			case $os in
				linux)
					outputFile="libmain.so"
					;;
				darwin)
					outputFile="libmain.dylib"
					;;
				windows)
					outputFile="main.dll"
					;;
				*)
					echo "Unknown OS $os" >/dev/stderr
					;;
			esac
			;;
		archive)
			case $os in
				windows)
					outputFile="main.lib"
					;;
				*)
					outputFile="libmain.a"
					;;
			esac
			;;
		*)
			echo "Unknown binary type $binaryType" >/dev/stderr
			exit 1
			;;
	esac

	{
		cd "$PROJECT_ROOT/src"

		# -ldflags "-s" below is inspired by https://github.com/ziglang/zig/issues/9050#issuecomment-859939664
		# and fixes errors like the following when building the shared library for darwin/amd64:
		# /opt/homebrew/Cellar/go/1.17.5/libexec/pkg/tool/darwin_arm64/link: /opt/homebrew/Cellar/go/1.17.5/libexec/pkg/tool/darwin_arm64/link: running strip failed: exit status 1
    # /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip: error: bad n_sect for symbol table entry 556 in: /private/var/folders/7t/_rsz39554vvgvq2t6b4ztktc0000gn/T/go-build3526877506/b001/exe/libmain.dylib

    {
      CGO_ENABLED=1 \
      GOOS=$os \
      GOARCH=$arch \
      CC="$PROJECT_ROOT/helpers/cc.sh" \
      CXX="$PROJECT_ROOT/helpers/cxx.sh" \
      ZTARGET="$zarch-$zos-gnu" \
        go build -buildmode="c-$binaryType" -o="$outputDir/$outputFile" -ldflags "-s" . 2>&1 &&
        echoGreen "Succeeded.";
    } || {
      echoRed "Failed!";
    }
	}
}

function echoRed() {
  local text=$1

  echo "$(tput setaf 1)$text$(tput sgr0)"
}

function echoBlue() {
  local text=$1

  echo "$(tput setaf 4)$text$(tput sgr0)"
}

function echoGreen() {
  local text=$1

  echo "$(tput setaf 2)$text$(tput sgr0)"
}

main "$@"
