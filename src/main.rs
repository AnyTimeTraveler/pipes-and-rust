extern crate simple_server;

use std::fs::File;
use std::io::Read;
use std::thread;

use byteorder::{ByteOrder, LittleEndian};
use rust_embed::RustEmbed;
use simple_server::Server;
use ws::{listen, Message};

use crate::Axis::*;
use crate::DigitizerEvent::*;

#[derive(RustEmbed)]
#[folder = "res/"]
struct Asset;

fn main() {
    let server = Server::new(|_, mut response| {
        Ok(response.body(Vec::from(Asset::get("index.html").unwrap()))?)
    });

    thread::spawn(move || {
        println!("Listening for http connections on port 80...");
        server.listen("0.0.0.0", "80");
    });

    println!("Listening for websocket connections on port 55555...");
    listen("0.0.0.0:55555", |out| {
        thread::Builder::new()
            .name(format!("connection_handler_{}", out.connection_id()))
            .spawn(move || {
                println!("Got Connection!");
                let mut input = File::open("/dev/input/event1").expect("opening wacom file");
                let mut buf = [0u8; 16];

                let mut state = DigitizerState::default();

                while let Ok(()) = input.read_exact(&mut buf) {
                    let event = parse_digitizer_event(&buf);

                    println!("Event: {:?}", event);

                    if let Ok(event) = event {
                        match event {
                            Sync => {
                                let data_string = format!(
                                    "[{},{},{},{}]",
                                    state.x,
                                    state.y,
                                    state.pressure,
                                    state.tool
                                );
                                println!("Sending: {}", data_string);

                                if let Err(value) = out.send(
                                    Message::text(
                                        data_string
                                    )
                                ) {
                                    eprintln!("Error: {:?}", value);
                                    return;
                                };
                            }
                            ChangeTool(tool) => {
                                match tool {
                                    Tool::ToolPen => state.tool = 1,
                                    Tool::ToolRubber => state.tool = 0,
                                    // Touch always happens, when the pen starts touching the tablet
                                    Tool::Touch => {}
                                    Tool::Stylus => {}
                                    Tool::Stylus2 => {}
                                }
                            }
                            Absolute(axis) => {
                                match axis {
                                    X(value) => state.x = value,
                                    Y(value) => state.y = value,
                                    Pressure(value) => state.pressure = value,
                                    Distance(_) => {}
                                    TiltX(_) => {}
                                    TiltY(_) => {}
                                }
                            }
                        }
                    }
                }
            })
            .expect("creating thread");
        move |msg| {
            println!("Got: {}", msg);
            Ok(())
        }
    }).expect("listening to websocket port");
}


struct DigitizerState {
    x: i32,
    y: i32,
    pressure: i32,
    tool: u8,
}

impl Default for DigitizerState {
    fn default() -> Self {
        DigitizerState {
            x: 0,
            y: 0,
            pressure: 0,
            tool: 1,
        }
    }
}

#[derive(PartialEq, Debug)]
enum Tool {
    ToolPen = 320,
    ToolRubber = 321,
    Touch = 330,
    Stylus = 331,
    Stylus2 = 332,
}

#[derive(Debug)]
enum Axis {
    X(i32),
    Y(i32),
    TiltX(i32),
    TiltY(i32),
    Pressure(i32),
    Distance(i32),
}

#[derive(Debug)]
enum DigitizerEvent {
    Sync,
    ChangeTool(Tool),
    Absolute(Axis),
}

// Using notes from https://github.com/ichaozi/RemarkableFramebuffer and the libremarkable crate
fn parse_digitizer_event(input: &[u8; 16]) -> Result<DigitizerEvent, ()> {
    let typ = input[8];
    let code = LittleEndian::read_i16(&input[10..12]);
    let value = LittleEndian::read_i32(&input[12..16]);

    println!("{},{},{}", typ, code, value);

    Ok(match typ {
        0 => Sync,
        1 => ChangeTool(match code {
            320 => Tool::ToolPen,
            321 => Tool::ToolRubber,
            330 => Tool::Touch,
            331 => Tool::Stylus,
            332 => Tool::Stylus2,
            _ => return Err(())
        }),
        3 => Absolute(match code {
            0 => X(value),
            1 => Y(value),
            24 => Pressure(value),
            25 => Distance(value),
            26 => TiltX(value),
            27 => TiltY(value),
            _ => return Err(())
        }),
        _ => return Err(())
    })
}
