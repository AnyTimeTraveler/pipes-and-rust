#!/usr/bin/env zsh

version="$1"
host="remarkable"
arch="armv7-unknown-linux-musleabihf"
#arch="armv7-unknown-linux-gnueabihf"

echo "Compiling..."
if [ "$version" = "release" ]; then
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
  scp "./target/$arch/$version/pipes-and-rust" "$host:" && echo "Done" && ssh "$host" "./pipes-and-rust"
fi
