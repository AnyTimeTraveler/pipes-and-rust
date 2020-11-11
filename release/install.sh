#!/usr/bin/env sh

# Set hostname or ip address of your reMarkable
host="remarkable"



ssh "$host" "mkdir -p /opt/"
echo "Copying files to device..."
scp "./pipes-and-rust" "$host:/opt/pipes-and-rust" || exit
scp "./pipes-and-rust.service" "$host:/lib/systemd/system/pipes-and-rust.service" || exit
echo "Done"

echo "Installing service..."
ssh "$host" "systemctl daemon-reload" || exit
ssh "$host" "systemctl enable pipes-and-rust.service" || exit
ssh "$host" "systemctl start pipes-and-rust.service" || exit
echo "Done"
