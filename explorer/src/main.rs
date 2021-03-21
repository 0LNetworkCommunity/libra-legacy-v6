mod explorer;
mod util;

use crate::explorer::{ui, App};
use crate::util::event::{Config, Event, Events};
use argh::FromArgs;
use cli::libra_client::LibraClient;
use libra_types::waypoint::Waypoint;
use reqwest::Url;
use std::{error::Error, io, time::Duration};
use termion::{event::Key, input::MouseTerminal, raw::IntoRawMode, screen::AlternateScreen};
use tui::{backend::TermionBackend, Terminal};

/// Termion demo
#[derive(Debug, FromArgs)]
struct Cli {
    /// time in ms between two ticks.
    #[argh(option, default = "250")]
    tick_rate: u64,
    /// whether unicode symbols are used to improve the overall look of the app
    #[argh(option, default = "true")]
    enhanced_graphics: bool,
    /// url of fullnode
    #[argh(option)]
    url: String,
    /// initial waypoint
    #[argh(option)]
    waypoint: Waypoint,
}

fn main() -> Result<(), Box<dyn Error>> {
    let cli_args: Cli = argh::from_env();

    let url = Url::parse(cli_args.url.as_str()).expect("Url is invalid");
    let x = LibraClient::new(url, cli_args.waypoint).expect("Failed to connect to host.");

    let events = Events::with_config(Config {
        tick_rate: Duration::from_millis(cli_args.tick_rate),
        ..Config::default()
    });

    let stdout = io::stdout().into_raw_mode()?;
    let stdout = MouseTerminal::from(stdout);
    let stdout = AlternateScreen::from(stdout);
    let backend = TermionBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    let mut app = App::new(" Block Explorer Menu ", cli_args.enhanced_graphics, x);
    app.fetch();
    loop {
        terminal.draw(|f| ui::draw(f, &mut app))?;

        match events.next()? {
            Event::Input(key) => match key {
                Key::Char(c) => {
                    app.on_key(c);
                }
                Key::Up => {
                    app.on_up();
                }
                Key::Down => {
                    app.on_down();
                }
                Key::Left => {
                    app.on_left();
                }
                Key::Right => {
                    app.on_right();
                }
                _ => {}
            },
            Event::Tick => {
                app.on_tick();
            }
        }
        if app.should_quit {
            break;
        }
    }

    Ok(())
}
