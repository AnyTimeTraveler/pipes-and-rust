#!/usr/bin/env zsh

build_type="$1"
host="remarkable"
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
  echo "Killing last process..."
  ssh remarkable "killall pipes-and-rust"
  echo "Done"
  echo "Copying to device..."
  scp "./target/$arch/$build_type/pipes-and-rust" "$host:/opt/pipes-and-rust" && echo "Done" && ssh "$host" "/opt/pipes-and-rust"
fi
