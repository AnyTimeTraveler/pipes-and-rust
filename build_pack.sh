#!/usr/bin/env zsh

arch="armv7-unknown-linux-musleabihf"
#arch="armv7-unknown-linux-gnueabihf"

echo "Compiling..."
cross build --target "$arch" --release || exit 1
echo "Done"

echo "Copying to directory..."
cp "./target/$arch/release/pipes-and-rust" "release/pipes-and-rust" || exit 1
echo "Done"

version="$(grep 'version' Cargo.toml | head -n 1 | cut -d\" -f2)"

cd release || exit 1
zip "../pipes-and-rust-release-$version.zip" \
./install.sh \
./pipes-and-rust \
./pipes-and-rust.service
