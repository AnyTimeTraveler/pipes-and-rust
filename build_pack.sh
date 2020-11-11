#!/usr/bin/env zsh

if [ $# -ne 1 ]; then
  echo "parameter 'debug' or 'release' required"
  exit
fi

build_type="$1"
arch="armv7-unknown-linux-musleabihf"
#arch="armv7-unknown-linux-gnueabihf"

echo "Compiling..."
if [ "$build_type" = "release" ]; then
  cross build --target "$arch" --release
else
  cross build --target "$arch"
fi
echo "Done"

# shellcheck disable=SC2181
if [ $? -eq 0 ]; then
  echo "Copying to directory..."
  cp "./target/$arch/$build_type/pipes-and-rust" "release/pipes-and-rust"
  echo "Done"
fi

version="$(grep 'version' Cargo.toml | head -n 1 | cut -d\" -f2)"

(cd release && zip "../pipes-and-rust-release-$version.zip" ./install.sh ./pipes-and-rust ./pipes-and-rust.service)
