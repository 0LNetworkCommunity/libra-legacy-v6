use std::io;
use std::sync::mpsc;
use std::sync::{
    atomic::{AtomicBool, Ordering},
    Arc,
};
use std::thread;
use std::time::Duration;
use termion::event::Key;
use termion::input::TermRead;
/// Event Struct
pub enum Event<I> {
    /// Input Event
    Input(I),
    /// Tick Event
    Tick,
}

#[allow(dead_code)]
/// A small event handler that wrap termion input and tick events. Each event
/// type is handled in its own thread and returned to a common `Receiver`
pub struct Events {
    /// rx
    rx: mpsc::Receiver<Event<Key>>,
    /// input handler
    input_handle: thread::JoinHandle<()>,
    /// ignore exit key
    ignore_exit_key: Arc<AtomicBool>,
    /// tick handler
    tick_handle: thread::JoinHandle<()>,
}

#[derive(Debug, Clone, Copy)]
/// Config struct of Event
pub struct Config {
    /// exit key
    pub exit_key: Key,
    /// tick rate
    pub tick_rate: Duration,
}

/// implement default() for Config struct
impl Default for Config {
    fn default() -> Config {
        Config {
            exit_key: Key::Char('q'),
            tick_rate: Duration::from_millis(250),
        }
    }
}

/// Events
impl Events {
    /// Config Event
    pub fn with_config(config: Config) -> Events {
        let (tx, rx) = mpsc::channel();
        let ignore_exit_key = Arc::new(AtomicBool::new(false));
        let input_handle = {
            let tx = tx.clone();
            let ignore_exit_key = ignore_exit_key.clone();
            thread::spawn(move || {
                let stdin = io::stdin();
                for evt in stdin.keys() {
                    if let Ok(key) = evt {
                        if let Err(err) = tx.send(Event::Input(key)) {
                            eprintln!("{}", err);
                            return;
                        }
                        if !ignore_exit_key.load(Ordering::Relaxed) && key == config.exit_key {
                            return;
                        }
                    }
                }
            })
        };
        let tick_handle = {
            thread::spawn(move || loop {
                if tx.send(Event::Tick).is_err() {
                    break;
                }
                thread::sleep(config.tick_rate);
            })
        };
        Events {
            rx,
            ignore_exit_key,
            input_handle,
            tick_handle,
        }
    }

    /// Next Event
    pub fn next(&self) -> Result<Event<Key>, mpsc::RecvError> {
        self.rx.recv()
    }
}
