#!/usr/bin/env sh

# Set hostname or ip address of your reMarkable
host="remarkable"



echo "Stopping service..."
ssh "$host" "systemctl disable --now pipes-and-rust.service"
ssh "$host" "killall pipes-and-rust"
echo "Done"

echo "Removing files from device..."
ssh "rm /opt/pipes-and-rust" || exit 1
ssh "rm /lib/systemd/system/pipes-and-rust.service" || exit 1
ssh "$host" "systemctl daemon-reload" || exit 1
echo "Done"

echo
echo "pipes-and-rust has been successfully removed from your device!"
