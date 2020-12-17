# Pipes and Rust

Draw on a html canvas directly from your reMarkable 2.

![](images/wiriting_test_canvas.png)

# Usage

1. Install the software with one of the methods below.
2. Connect to http://remarkable (or device IP)
3. Done!

# Requirements

1. SSH access to the reMarkable for installation
2. (when building from source) Rust

# Installation (from Binary)

1. Download the [latest release](https://github.com/AnyTimeTraveler/pipes-and-rust/releases)
2. Set IP or hostname in `install.sh`
3. Run install.sh

# Installation (from Source)

1. Install [Rust](https://rustup.rs/)
2. Install [Cross](https://github.com/rust-embedded/cross) to build for armv7
3. Set hostname in `build_push_run.sh`
4. Run `build_push_run.sh` with either 'debug' or 'release' as parameter

# Credits

This work is based on [pipes-and-paper](https://gitlab.com/afandian/pipes-and-paper) by Joe Wass and uses his code to read the stylus coordinates.

# License

MIT-License
