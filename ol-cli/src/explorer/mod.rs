#[allow(missing_docs)]
pub use app::App;

/// application
mod app;
/// ui
pub mod ui;
/// event
pub mod event;

/// Cli tab status
pub struct TabsState<'a> {
    /// titles of tabs
    pub titles: Vec<&'a str>,
    /// tab index
    pub index: usize,
}

/// implementation of tab states
impl<'a> TabsState<'a> {
    /// new a instance
    pub fn new(titles: Vec<&'a str>) -> TabsState<'a> {
        TabsState { titles, index: 0 }
    }
    /// switch to next tab.
    pub fn next(&mut self) {
        self.index = (self.index + 1) % self.titles.len();
    }
    /// switch to previous tab
    pub fn previous(&mut self) {
        if self.index > 0 {
            self.index -= 1;
        } else {
            self.index = self.titles.len() - 1;
        }
    }
}

