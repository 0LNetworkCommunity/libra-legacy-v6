//! `monitor-cmd` subcommand

use abscissa_core::{Command, Options, Runnable};
use crate::explorer::event::{Events, Config, Event};
use std::time::Duration;
use std::io;
use termion::{event::Key, input::MouseTerminal, raw::IntoRawMode, screen::AlternateScreen};
use tui::backend::TermionBackend;
use tui::Terminal;
use crate::explorer::{App, ui};

/// `explorer-cmd` subcommand
#[derive(Command, Debug, Options)]
pub struct ExplorerCMD {

    #[options(help = "Tick rate of the screen", default="250")]
    tick_rate: u64,

    #[options(help = "Using enhanced graphics", default="true")]
    enhanced_graphics: bool,
}

impl Runnable for ExplorerCMD {
    /// Start the application.
    fn run(&self) {

        let events = Events::with_config(Config {
            tick_rate: Duration::from_millis(self.tick_rate),
            ..Config::default()
        });

        let stdout = io::stdout().into_raw_mode().expect("Failed to initial screen");
        let stdout = MouseTerminal::from(stdout);
        let stdout = AlternateScreen::from(stdout);
        let backend = TermionBackend::new(stdout);
        let mut terminal = Terminal::new(backend).expect("Failed to initial screen");

        let rpc = super::super::client::default_local_client()
            .0.expect("Failed to connect to localhost");

        let mut app = App::new(" Block Explorer Menu ", self.enhanced_graphics, rpc);
        app.fetch();
        terminal.clear().unwrap();
        loop {
            terminal.draw(|f| ui::draw(f, &mut app))
                .expect("failed to draw screen");

            match events.next().unwrap() {
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
        terminal.clear().unwrap();
        terminal.flush().unwrap();
    }
}
