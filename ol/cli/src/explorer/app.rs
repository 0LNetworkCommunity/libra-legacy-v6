
#[allow(missing_docs)]
use crate::node::chain_info;
use crate::node::node::Node;
use super::TabsState;
use libra_json_rpc_client::views::{TransactionDataView, TransactionView};
use libra_types::{account_state::AccountState};

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

pub struct Tx {
    /// Sender
    pub sender: String,
    /// signature_scheme
    pub signature_scheme: String,
    /// signature
    pub signature: String,
    /// pubkey
    pub public_key: String,
    /// sequence
    pub sequence_number: u64,
    /// chain id
    pub chain_id: u8,
    /// max gas amount
    pub max_gas_amount: u64,
    /// gas unit price
    pub gas_unit_price: u64,
    /// Gas currency
    pub gas_currency: String,
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
    pub chain_state: Option<chain_info::ChainView>,
    /// caches for validator list
    pub validators: Vec<chain_info::ValidatorView>,
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
            tabs: TabsState::new(vec!["Overview", "Pilot", "Network", "Transactions", "Coins"]),
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
        let meta = self
            .node
            .client
            .get_metadata();
        if meta.is_err() { return }
        let latest_version =meta.unwrap().version;
        //self.last_fetch_tx_version = if latest_version > 1000 {latest_version-1000} else {0};

        match self
          .node
            .client
            .get_txn_by_range(if latest_version > 1000 {latest_version-1000} else {0}, 100, true)
        {
            Ok(txs) => {
                self.txs = txs;
                self.txs.reverse();
                // txs.iter().for_each(|tv| {
                //     match tv.clone().transaction {
                //         TransactionDataView::UserTransaction {sender,
                //                                              signature_scheme,
                //                                              signature,
                //                                              public_key,
                //                                              sequence_number,
                //                                              chain_id,
                //                                              max_gas_amount,
                //                                              gas_unit_price,
                //                                              gas_currency,
                //             ..} => {
                //             println!("TX:{:?}, {:?}", &sender, signature);
                //             self.txs.push(Tx{
                //                 sender,
                //                 sequence_number,
                //                 signature,
                //                 signature_scheme,
                //                 public_key,
                //                 chain_id,
                //                 max_gas_amount,
                //                 gas_currency,
                //                 gas_unit_price,
                //             });
                //         },
                //         _ => {}
                //     }
                // });
            }
            Err(e) => { println!("Error occurs: {}", e)}
        }
    }

    /// fetch basic data for first tab
    pub fn fetch(&mut self) {
      let (chain_info, validator_info) = self.node.refresh_chain_info();
      self.chain_state = chain_info;
      if validator_info.is_some() {
          self.validators = validator_info.unwrap();
      }
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
            'c' => {
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
            3 => self.fetch_txs(),
            _ => {}
        }
    }
}
