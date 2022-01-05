#! /usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
LOGS_DIR="$PROJECT_ROOT/logs"
ANY_TARGETS_FAILED=false

function main() {
	echoBlue "Preparing..."
	rm -rf "$BUILD_DIR" "$LOGS_DIR"
	mkdir -p "$BUILD_DIR" "$LOGS_DIR"

	build shared darwin amd64
	build archive darwin amd64
	build shared darwin arm64
	build archive darwin arm64
	build shared linux amd64
	build archive linux amd64
	build shared linux arm64
	build archive linux arm64
	build shared windows amd64
	build archive windows amd64

	echo

	if [[ "$ANY_TARGETS_FAILED" == "true" ]]; then
	  echoRed "One or more targets failed."
	  exit 1
  else
	  echoGreen "All targets finished."
	fi
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

    {
      CGO_ENABLED=1 \
      GOOS=$os \
      GOARCH=$arch \
      CC="$PROJECT_ROOT/helpers/cc.sh" \
      CXX="$PROJECT_ROOT/helpers/cxx.sh" \
      ZTARGET="$zarch-$zos-gnu" \
        go build -buildmode="c-$binaryType" -o="$outputDir/$outputFile" . &&
        echoGreen "Succeeded.";
    } || {
      ANY_TARGETS_FAILED=true &&
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

main
