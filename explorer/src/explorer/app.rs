use crate::util::TabsState;
use chrono::Utc;
use cli::libra_client::LibraClient;
use libra_json_rpc_client::views::TransactionView;
use libra_types::{account_address::AccountAddress, account_state::AccountState};
use std::convert::TryFrom;

pub struct Server<'a> {
    pub name: &'a str,
    pub location: &'a str,
    pub coords: (f64, f64),
    pub status: &'a str,
}

pub struct App<'a> {
    pub client: LibraClient,
    pub title: &'a str,
    pub should_quit: bool,
    pub tabs: TabsState<'a>,
    pub show_chart: bool,
    pub progress: f64,
    pub servers: Vec<Server<'a>>,
    pub enhanced_graphics: bool,
    pub account_state: Option<AccountState>,
    pub chain_state: Option<ChainState>,
    pub validators: Vec<ValidatorInfo>,
    pub last_fetch_tx_version: u64,
    pub txs: Vec<TransactionView>,
}

impl<'a> App<'a> {
    pub fn new(title: &'a str, enhanced_graphics: bool, client: LibraClient) -> App<'a> {
        App {
            title,
            client,
            account_state: None,
            chain_state: None,
            should_quit: false,
            tabs: TabsState::new(vec!["Overview", "Network", "Transactions", "Coin List"]),
            show_chart: true,
            progress: 0.0,
            servers: vec![],
            enhanced_graphics,
            validators: vec![],
            last_fetch_tx_version: 0,
            txs: vec![],
        }
    }

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

    pub fn fetch(&mut self) {
        let (blob, _version) = self
            .client
            .get_account_state_blob(AccountAddress::ZERO)
            .unwrap();
        let mut cs = ChainState::default();
        if let Some(account_blob) = blob {
            let account_state = AccountState::try_from(&account_blob).unwrap();
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
            self.progress = (now - ts) as f64 / 61f64;

            if let Some(first) = account_state
                .get_registered_currency_info_resources()
                .unwrap()
                .first()
            {
                cs.total_supply = (first.total_value() / first.fractional_part() as u128) as u64;
            }

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
                                // ips.iter().map(|ip|{
                                //     self.servers.push(Server{
                                //         name: ip.as_slice().first().unwrap().to_string().as_str(),
                                //         location: "",
                                //         coords: (0.0, 0.0),
                                //         status: "Up"
                                //     });
                                // });
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

        cs.height = self.client.get_metadata().unwrap().version;
        self.chain_state = Some(cs);
    }

    pub fn on_up(&mut self) {
        //self.tasks.previous();
    }

    pub fn on_down(&mut self) {
        //self.tasks.next();
    }

    pub fn on_right(&mut self) {
        self.tabs.next();
    }

    pub fn on_left(&mut self) {
        self.tabs.previous();
    }

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
        //
        // self.sparkline.on_tick();
        // self.signals.on_tick();
        //
        // let log = self.logs.items.pop().unwrap();
        // self.logs.items.insert(0, log);
        //
        // let event = self.barchart.pop().unwrap();
        // self.barchart.insert(0, event);
    }
}

#[derive(Default)]
pub struct ChainState {
    pub epoch: u64,
    pub height: u64,
    pub validator_count: u64,
    pub total_supply: u64,
    pub latest_epoch_change_time: u64,
}

#[derive(Default)]
pub struct ValidatorInfo {
    pub account_address: String,
    pub pub_key: String,
    pub voting_power: u64,
    pub full_node_ip: String,
    pub validator_ip: String,
    pub tower_height: u64,
    pub tower_epoch: u64,
    pub count_proofs_in_epoch: u64,
    pub epochs_validating_and_mining: u64,
    pub contiguous_epochs_validating_and_mining: u64,
    pub epochs_since_last_account_creation: u64,
}
