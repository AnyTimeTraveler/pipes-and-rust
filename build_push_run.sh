#!/usr/bin/env zsh

host="remarkable"
arch="armv7-unknown-linux-musleabihf"
#arch="armv7-unknown-linux-gnueabihf"

echo "Checking if Docker is running..."
if ! systemctl status docker.service > /dev/null; then
  echo "Done"
  echo "Starting Docker..."
  sudo systemctl start docker.service
fi
echo "Done"

echo "Compiling..."
cross build --target "$arch" --release || exit 1
echo "Done"

echo "Killing last process..."
ssh "$host" "killall pipes-and-rust"
echo "Done"

echo "Checking if /opt/ directory exists in device..."
ssh "$host" "mkdir -p /opt/" || exit 1
echo "Done"

echo "Copying to device..."
scp "./target/$arch/release/pipes-and-rust" "$host:/opt/pipes-and-rust" || exit 1
echo "Done"

echo "Running..."
ssh "$host" "/opt/pipes-and-rust" || exit 1
echo "Done"
