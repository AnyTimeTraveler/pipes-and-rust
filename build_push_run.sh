#!/usr/bin/env zsh

host="remarkable"
arch="armv7-unknown-linux-musleabihf"
#arch="armv7-unknown-linux-gnueabihf"

function try_or_fail() {
  # shellcheck disable=SC2091
  if eval "$1"; then
    echo "Done"
  else
    echo "Error"
    exit 1
  fi
}


echo "Checking if Docker is running..."
if ! systemctl status docker.service > /dev/null; then
  echo "Done"
  echo "Starting Docker..."
  sudo systemctl start docker.service
fi
echo "Done"

echo "Compiling..."
try_or_fail "cross build --target $arch --release"

echo "Killing last process..."
ssh "$host" "killall pipes-and-rust"
echo "Done"

echo "Checking if /opt/ directory exists in device..."
try_or_fail "ssh $host 'mkdir -p /opt/'"

echo "Copying to device..."
try_or_fail "scp \"./target/$arch/release/pipes-and-rust\" \"$host:/opt/pipes-and-rust\""

echo "Running..."
try_or_fail "ssh $host \"/opt/pipes-and-rust\""
