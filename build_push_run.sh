cross build --target armv7-unknown-linux-gnueabihf --release && ssh remarkable "killall pipes-and-rust" && scp ./target/armv7-unknown-linux-gnueabihf/release/pipes-and-rust remarkable: && ssh remarkable "./pipes-and-rust"

