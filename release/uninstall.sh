#!/usr/bin/env sh

# Set hostname or ip address of your reMarkable
host="remarkable"


echo "Stopping service..."
ssh "$host" "test -f /lib/systemd/system/pipes-and-rust.service && systemctl disable --now pipes-and-rust.service" || exit 1
ssh "$host" "pidof pipes-and-rust > /dev/null && killall pipes-and-rust" || exit 1
echo "Done"

echo "Removing files from device..."
ssh "$host" "test -f /opt/pipes-and-rust && rm /opt/pipes-and-rust" || exit 1
ssh "$host" "test -f /lib/systemd/system/pipes-and-rust.service && rm /lib/systemd/system/pipes-and-rust.service" || exit 1
ssh "$host" "systemctl daemon-reload"
echo "Done"

echo
echo "pipes-and-rust has been successfully removed from your device!"
