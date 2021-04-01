#[allow(missing_docs)]
use super::TabsState;
use chrono::Utc;
use cli::libra_client::LibraClient;
use libra_json_rpc_client::views::TransactionView;
use libra_types::{account_address::AccountAddress, account_state::AccountState};
use std::convert::TryFrom;
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
    pub client: LibraClient,
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
    pub chain_state: Option<ChainState>,
    /// caches for validator list
    pub validators: Vec<ValidatorInfo>,
    /// latest fetched tx version
    pub last_fetch_tx_version: u64,
    /// transaction list
    pub txs: Vec<TransactionView>,
}

/// implementation of app
impl<'a> App<'a> {
    /// new a instance of explorer
    pub fn new(title: &'a str, enhanced_graphics: bool, client: LibraClient) -> App<'a> {
        App {
            title,
            client,
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
            .client
            .get_metadata()
            .expect("Fail to fetch version")
            .version;
        // if self.last_fetch_tx_version == 0 {
        //     self.last_fetch_tx_version = latest_version - 1000 // initial start version for tx fetching
        // };
        match self
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
        let (blob, _version) = self
            .client
            .get_account_state_blob(AccountAddress::ZERO)
            .unwrap();
        let mut cs = ChainState::default();
        if let Some(account_blob) = blob {
            let account_state = AccountState::try_from(&account_blob).unwrap();
            let meta = self.client.get_metadata().unwrap();
            cs.epoch = account_state
                .get_configuration_resource()
                .unwrap()
                .unwrap()
                .epoch();
            cs.validator_count = account_state
                .get_validator_set()
                .unwrap()
                .unwrap()
                .payload()
                .len() as u64;
            let ts = account_state
                .get_configuration_resource()
                .unwrap()
                .unwrap()
                .last_reconfiguration_time() as i64
                / 1000000;
            let now = Utc::now().timestamp();
            match meta.chain_id {
                4 => self.progress = (now - ts) as f64 / 61f64, // 1 minute
                _ => self.progress = (now - ts) as f64 / 86401f64, // 24 hours
            }
            if self.progress > 1f64 {
                self.progress = 0f64;
            };

            if let Some(first) = account_state
                .get_registered_currency_info_resources()
                .unwrap()
                .first()
            {
                cs.total_supply = (first.total_value() / first.scaling_factor() as u128) as u64;
            }

            cs.height = meta.version;
            self.chain_state = Some(cs);

            self.validators = account_state
                .get_validator_set()
                .unwrap()
                .unwrap()
                .payload()
                .iter()
                .map(|v| {
                    let full_node_ip = match v.config().fullnode_network_addresses() {
                        Ok(ips) => {
                            if !ips.is_empty() {
                            //     ips.iter().map(|na|{
                            //         na.as_slice().iter().map(|ip| {
                            //             match ip {
                            //                 Protocol::Ip4(ip4) => {
                            //                     if !ip4.is_private() {
                            //                         // servers.push(Server {
                            //                         //     name: ip4.to_string(),
                            //                         //     location: "",
                            //                         //     coords: (0.0, 0.0),
                            //                         //     status: "Up"
                            //                         // });
                            //                     }
                            //                 }
                            //                 Protocol::Ip6(_ip6) => {
                            //                     // servers.push(Server {
                            //                     //     name: ip6.to_string().as_str(),
                            //                     //     location: "",
                            //                     //     coords: (0.0, 0.0),
                            //                     //     status: "Up"
                            //                     // });
                            //                 }
                            //                 _ => {}
                            //             }
                            //         });
                            //     }).count();
                                ips.last().unwrap().to_string()
                            } else {
                                "--".to_string()
                            }
                        }
                        Err(_) => "--".to_string(),
                    };
                    let validator_ip = match v.config().validator_network_addresses() {
                        Ok(ips) => {
                            if !ips.is_empty() {
                                ips.get(0).unwrap().seq_num().to_string()
                            } else {
                                "--".to_string()
                            }
                        }
                        Err(_) => "--".to_string(),
                    };
                    let ms = self
                        .client
                        .get_miner_state(v.account_address().clone())
                        .unwrap()
                        .unwrap();

                    ValidatorInfo {
                        account_address: v.account_address().to_string(),
                        voting_power: v.consensus_voting_power(),
                        full_node_ip,
                        pub_key: v.consensus_public_key().to_string(),
                        validator_ip,

                        tower_height: ms.verified_tower_height,
                        tower_epoch: ms.latest_epoch_mining,

                        count_proofs_in_epoch: ms.count_proofs_in_epoch,
                        epochs_validating_and_mining: ms.epochs_validating_and_mining,
                        contiguous_epochs_validating_and_mining: ms
                            .contiguous_epochs_validating_and_mining,
                        epochs_since_last_account_creation: ms.epochs_since_last_account_creation,
                    }
                })
                .collect();
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

#[derive(Default)]
/// ChainState struct
pub struct ChainState {
    /// epoch
    pub epoch: u64,
    /// height/version
    pub height: u64,
    /// validator count
    pub validator_count: u64,
    /// total supply of GAS
    pub total_supply: u64,
    /// latest epoch change time
    pub latest_epoch_change_time: u64,
}

#[derive(Default)]
/// Validator info struct
pub struct ValidatorInfo {
    /// account address
    pub account_address: String,
    /// public key
    pub pub_key: String,
    /// voting power
    pub voting_power: u64,
    /// full node ip
    pub full_node_ip: String,
    /// validator ip
    pub validator_ip: String,
    /// tower height
    pub tower_height: u64,
    /// tower epoch
    pub tower_epoch: u64,
    /// proof counts in current epoch
    pub count_proofs_in_epoch: u64,
    /// epoch validating and mining
    pub epochs_validating_and_mining: u64,
    /// contiguous epochs of mining
    pub contiguous_epochs_validating_and_mining: u64,
    /// epoch count since creation
    pub epochs_since_last_account_creation: u64,
}
