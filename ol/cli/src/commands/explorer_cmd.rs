//! `monitor-cmd` subcommand

use abscissa_core::{Command, Options, Runnable};
use crate::{application::app_config, entrypoint, explorer::event::{Events, Config, Event}, node::{client, node::Node}};
use std::time::Duration;
use std::{io, thread};
use termion::{event::Key, input::MouseTerminal, raw::IntoRawMode, screen::AlternateScreen};
use tui::backend::TermionBackend;
use tui::Terminal;
use crate::explorer::{App, ui};
use crate::check::runner;
use crate::config::AppCfg;

/// `explorer-cmd` subcommand
#[derive(Command, Debug, Options)]
pub struct ExplorerCMD {
    ///
    #[options(short = "p", help = "Run Pilot service to start apps")]
    // TODO: optionally don't do the pilot
    pilot: bool,
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
        // let cfg = app_config().clone();
        // let args = entrypoint::get_args();

        // TODO: optionally start explorer with the pilot process in a thread
        // Start the health check runner in background, optionally with --pilot, which starts services.
        // check if pilot or something else is already running.
        let do_pilot = self.pilot.to_owned();
        thread::spawn(move || {
            let mut conf = match entrypoint::get_args().swarm_path {
                Some(sp) => AppCfg::init_app_configs_swarm(sp.clone(), sp.join("0")),
                None => app_config().to_owned()
            };
            let client = client::pick_client( entrypoint::get_args().swarm_path, &mut conf).unwrap().0;
            let mut node = Node::new(client, conf);
            runner::run_checks(&mut node, do_pilot, true, false);
        });

        let args = entrypoint::get_args();

        let mut cfg = match args.swarm_path.clone() {
            Some(sp) => AppCfg::init_app_configs_swarm(sp.clone(), sp.join("0")),
            None => app_config().to_owned()
        };

        let client = client::pick_client(args.swarm_path, &mut cfg).unwrap().0;
        let node = Node::new(client, cfg);

        let mut app = App::new(" Console ", self.enhanced_graphics, node);
        app.fetch();

        let events = Events::with_config(Config {
            tick_rate: Duration::from_millis(self.tick_rate),
            ..Config::default()
        });

        let stdout = io::stdout().into_raw_mode().expect("Failed to initial screen");
        //let stdout = MouseTerminal::from(stdout);
        let stdout = AlternateScreen::from(stdout);
        stdout.lock();
        let backend = TermionBackend::new(stdout);
        let mut terminal = Terminal::new(backend).expect("Failed to initial screen");

        terminal.clear().unwrap();
        
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
        std::mem::drop(terminal);
    }
}
