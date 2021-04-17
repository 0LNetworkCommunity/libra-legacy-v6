
#[allow(missing_docs)]
use crate::node::chain_info;
use crate::node::node::Node;
use super::TabsState;

use libra_json_rpc_client::views::TransactionView;
use libra_types::{account_state::AccountState};
// use libra_network_address::Protocol;

/// struct for fullnode list
pub struct Server<'a> {
    /// owner name or hex address
    pub name: &'a str,
    /// IP location
    pub location: &'a str,
    /// GEO
    pub coords: (f64, f64),
    /// Status(Up or Down)
    pub status: &'a str,
}

/// Explorer Application
pub struct App<'a> {
    /// blockchain client to fetch data
    pub node: Node,
    /// title of app
    pub title: &'a str,
    /// should quit?
    pub should_quit: bool,
    /// tabs
    pub tabs: TabsState<'a>,
    /// not use currently
    pub show_chart: bool,
    /// progress of epoch
    pub progress: f64,
    /// caches for fullnodes
    pub servers: Vec<Server<'a>>,
    /// enhanced graphics
    pub enhanced_graphics: bool,
    /// caches for account state
    pub account_state: Option<AccountState>,
    /// caches for chain state
    pub chain_state: Option<chain_info::ChainInfo>,
    /// caches for validator list
    pub validators: Vec<chain_info::ValidatorInfo>,
    /// latest fetched tx version
    pub last_fetch_tx_version: u64,
    /// transaction list
    pub txs: Vec<TransactionView>,
}

/// implementation of app
impl<'a> App<'a> {
    /// new a instance of explorer
    pub fn new(title: &'a str, enhanced_graphics: bool, node: Node) -> App<'a> {
        App {
            node,
            title,
            account_state: None,
            chain_state: None,
            should_quit: false,
            tabs: TabsState::new(vec!["Overview", "Network", "Transactions", "Coin List"]),
            show_chart: true,
            progress: 0.1,
            servers: vec![
                Server{
                    name: "NorthAmerica-1",
                    location: "New York City",
                    coords: (40.71, -74.00),
                    status: "Up",
                },
                Server{
                    name: "NorthAmerica-2",
                    location: "New York City",
                    coords: (43.38, -79.23),
                    status: "Up",
                },
                Server{
                    name: "NorthAmerica-3",
                    location: "New York City",
                    coords: (34.04, -118.15),
                    status: "Up",
                },
                Server {
                    name: "Europe-1",
                    location: "Paris",
                    coords: (48.85, 2.35),
                    status: "Up",
                },
                Server {
                    name: "Asia-0",
                    location: "ShangHai",
                    coords: (32.23, 118.76),
                    status: "Up",
                },
                Server {
                    name: "Asia-1",
                    location: "Singapore",
                    coords: (1.35, 103.86),
                    status: "Up",
                },
            ],
            enhanced_graphics,
            validators: vec![],
            last_fetch_tx_version: 0,
            txs: vec![],
        }
    }

    /// fetch transactions
    pub fn fetch_txs(&mut self) {
        let latest_version = self
            .node
            .client
            .get_metadata()
            .expect("Fail to fetch version")
            .version;

        match self
          .node
            .client
            .get_txn_by_range(self.last_fetch_tx_version, 100, true)
        {
            Ok(txs) => {
                let _ = txs.iter().map(|tv| {
                    self.txs.push(tv.clone());
                });
            }
            Err(_) => {}
        }
        self.last_fetch_tx_version = latest_version;
    }

    /// fetch basic data for first tab
    pub fn fetch(&mut self) {
      let (chain_info, validator_info) = self.node.fetch_chain_info();
      self.chain_state = chain_info;
      self.validators = validator_info.unwrap();
    }

    /// handler for key up
    pub fn on_up(&mut self) {
        //self.tasks.previous();
    }

    /// handler for key down
    pub fn on_down(&mut self) {
        //self.tasks.next();
    }

    /// handler for key right
    pub fn on_right(&mut self) {
        self.tabs.next();
    }

    /// handler for key left
    pub fn on_left(&mut self) {
        self.tabs.previous();
    }

    /// handler for all keys
    pub fn on_key(&mut self, c: char) {
        match c {
            'q' => {
                self.should_quit = true;
            }
            't' => {
                self.show_chart = !self.show_chart;
            }
            _ => {}
        }
    }

    /// handler for tick
    pub fn on_tick(&mut self) {
        // Update progress
        self.progress += 0.001;
        if self.progress > 1.0 {
            self.progress = 0.0;
        }

        match self.tabs.index {
            0 => self.fetch(),
            2 => self.fetch_txs(),
            _ => {}
        }
    }
}
