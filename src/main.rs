use std::fs::File;
use std::io::Read;
use std::thread;

use ws::{listen, Message};

fn main() {
    println!("Listening...");
    listen("0.0.0.0:55555", |out| {
        thread::Builder::new()
            .name(format!("connection_handler_{}", out.connection_id()))
            .spawn(move || {
                println!("Got Connection!");
                let mut input = File::open("/dev/input/event1").expect("file");
                let mut buf = [0u8; 16];

                let mut x = 0;
                let mut y = 0;
                let mut pressure = 0;

                while let Ok(()) = input.read_exact(&mut buf) {
                    // Using notes from https://github.com/ichaozi/RemarkableFramebuffer
                    let typ = buf[8];
                    let code = buf[10] as i32 + buf[11] as i32 * 0x100;
                    let value = buf[12] as i32 + buf[13] as i32 * 0x100 + buf[14] as i32 * 0x10000 + buf[15] as i32 * 0x1000000;

                    // Absolute position
                    if typ == 3 {
                        if code == 0 {
                            x = value
                        } else if code == 1 {
                            y = value
                        } else if code == 24 {
                            pressure = value
                        }
                        if let Err(value) = out.send(Message::text(format!("[{},{},{}]", x, y, pressure))) {
                            eprintln!("Error: {:?}", value);
                            return;
                        };
                    }
                }
            }).expect("creating thread");
        move |msg| {
            println!("Got: {}", msg);
            Ok(())
        }
    }).unwrap();
    println!("Ended!");
}
