//! `monitor-cmd` subcommand

use abscissa_core::{Command, Options, Runnable};
use crate::{application::app_config, check::{self, runner}, entrypoint, explorer::event::{Events, Config, Event}, node::{client, node::Node}};
use std::{thread, time::Duration};
use std::io;
use termion::{event::Key, input::MouseTerminal, raw::IntoRawMode, screen::AlternateScreen};
use tui::backend::TermionBackend;
use tui::Terminal;
use crate::explorer::{App, ui};
/// `explorer-cmd` subcommand
#[derive(Command, Debug, Options)]
pub struct ExplorerCMD {
    ///
    #[options(help = "Don't run the Pilot service to start apps")]
    skip_pilot: bool,
    ///
    #[options(help = "Tick rate of the screen", default="250")]
    tick_rate: u64,
    ///
    #[options(help = "Using enhanced graphics", default="true")]
    enhanced_graphics: bool,


}

impl Runnable for ExplorerCMD {
    /// Start the application.
    fn run(&self) {
        let cfg = app_config().clone();
        let args = entrypoint::get_args();

        let events = Events::with_config(Config {
            tick_rate: Duration::from_millis(self.tick_rate),
            ..Config::default()
        });

        let stdout = io::stdout().into_raw_mode().expect("Failed to initial screen");
        let stdout = MouseTerminal::from(stdout);
        let stdout = AlternateScreen::from(stdout);
        let backend = TermionBackend::new(stdout);
        let mut terminal = Terminal::new(backend).expect("Failed to initial screen");

        let client = client::pick_client(args.swarm_path, &cfg).unwrap().0;
        let node = Node::new(client, cfg);
        let mut app = App::new(" Block Explorer Menu ", self.enhanced_graphics, node);
        app.fetch();
        terminal.clear().unwrap();

        // // Start the health check runner in background, optionally with --pilot, which starts services.
        // let test = thread::spawn(move || {
        //     runner::run_checks(&mut app.node, !self.skip_pilot, true, false);
        // });

        loop {
            terminal.draw(|f| ui::draw(f, &mut app))
                .expect("failed to draw screen");

            match events.next().unwrap() {
                Event::Input(key) => match key {
                    Key::Char(character) => {
                        app.on_key(character);
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
