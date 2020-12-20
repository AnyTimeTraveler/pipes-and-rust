#!/usr/bin/env sh

# Set hostname or ip address of your reMarkable
host="remarkable"



ssh "$host" "mkdir -p /opt/" || exit 1
echo "Stopping previous version..."
ssh "$host" "systemctl stop pipes-and-rust.service"
ssh "$host" "killall pipes-and-rust"
echo "Copying files to device..."
scp "./pipes-and-rust" "$host:/opt/pipes-and-rust" || exit 1
scp "./pipes-and-rust.service" "$host:/lib/systemd/system/pipes-and-rust.service" || exit 1
echo "Done"

echo "Installing service..."
ssh "$host" "systemctl daemon-reload" || exit 1
ssh "$host" "systemctl enable pipes-and-rust.service" || exit 1
ssh "$host" "systemctl start pipes-and-rust.service" || exit 1
echo "Done"
