//! `chain_info`
use anyhow::{bail, Error};
use chrono::Utc;
use diem_json_rpc_client::views::OracleUpgradeStateView;
use diem_types::{
    account_address::AccountAddress, account_state::AccountState,
    ol_validators_stats::ValidatorsStatsResource, validator_info::ValidatorInfo,
    waypoint::Waypoint,
};
use ol_types::{autopay::AutoPayView, validator_config::ValidatorConfigView};

use super::{autopay_view::PayeeStats, dictionary::AccountDictionary, node::Node, query};
use serde::{Deserialize, Serialize};
use std::{
    collections::HashMap,
    convert::TryFrom,
    net::{IpAddr, SocketAddr, TcpStream},
    str::FromStr,
    time::Duration,
};

/// name of chain info key for db
pub const CHAIN_INFO_DB_KEY: &str = "chain_info";
/// name of val info key for db
pub const VAL_INFO_DB_KEY: &str = "val_info";

#[derive(Default, Clone, Debug, Deserialize, Serialize)]
/// ChainInfo struct
pub struct ChainView {
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
    /// epoch_progress
    pub epoch_progress: f64,
    /// waypoint
    pub waypoint: Option<Waypoint>,
    /// upgrade
    pub upgrade: Option<OracleUpgradeStateView>,
    /// validator view
    pub validator_view: Option<Vec<ValidatorView>>,
    /// validators stats
    pub validators_stats: Option<ValidatorsStatsResource>,
    /// audit stats
    pub vals_config_stats: Option<ValsConfigStats>,
    /// autopay payees percentage recurring stats
    pub autopay_watch_list: Option<Vec<PayeeStats>>,
}

#[derive(Default, Debug, Deserialize, Serialize, Clone)]
/// Validator info struct
pub struct ValidatorView {
    /// account address
    pub account_address: String,
    /// public key
    pub pub_key: String,
    /// voting power
    pub voting_power: u64,
    /// full node full ip
    pub vfn_full_ip: String,
    /// full node ip
    pub vfn_ip: String,
    /// validator full ip
    pub validator_full_ip: String,
    /// validator ip
    pub validator_ip: String,
    /// ports status
    pub ports_status: HashMap<String, bool>,
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
    /// total count votes in current epoch
    pub vote_count_in_epoch: u64,
    /// total block propositions in current epoch
    pub prop_count_in_epoch: u64,
    /// validator config in the chain
    pub validator_config: Option<ValidatorConfigView>,
    /// autopay instructions
    pub autopay: Option<AutoPayView>,
    /// burn preferences
    pub burn_to_community: bool,
    /// note
    pub note: String,
}

/// Validators config stats
#[derive(Default, Debug, Deserialize, Serialize, Clone)]
pub struct ValsConfigStats {
    /// total #vals in the stats
    pub total_vals: usize,
    /// total of vals with autopay set
    pub count_vals_with_autopay: u64,
    /// total of vals with operator account
    pub count_vals_with_operator: u64,
    /// total of vals having operator with balance greater than zero
    pub count_positive_balance_operators: u64,
    /// percentage of vals with autopay set
    pub percent_vals_with_autopay: f64,
    /// percentage of vals with operator account
    pub percent_vals_with_operator: f64,
    /// percentage of vals having operator with balance greater than zero
    pub percent_positive_balance_operators: f64,
}

impl Node {
    /// fetch state from system address 0x0
    pub fn refresh_chain_info(&mut self) -> Result<(ChainView, Vec<ValidatorView>), Error> {
        // let mut client = client::pick_client();
        let (blob, _version) = match self.client.get_account_state_blob(&AccountAddress::ZERO) {
            Ok(t) => t,
            Err(_) => (None, 0),
        };
        let mut cs = ChainView::default();

        // TODO: Uncomment this if the tools are not fetch up to date info
        // self.client.update_and_verify_state_proof()?;

        cs.waypoint = self.client.waypoint().ok();

        if let Some(account_blob) = blob {
            let account_state = AccountState::try_from(&account_blob)?;
            let meta = self.client.get_metadata()?;

            let conf_resource = match account_state.get_configuration_resource()? {
                Some(cr) => cr,
                None => bail!("cannot get configuration resource from chain"),
            };

            ////////////// CHAIN METADATA //////////////
            cs.epoch = conf_resource.epoch();

            // Calculate Epoch Progress
            let time_start = conf_resource.last_reconfiguration_time() as i64 / 1000000;

            let now = Utc::now().timestamp();

            match meta.chain_id {
                // testnet has faster epochs
                4 => cs.epoch_progress = (now - time_start) as f64 / 61f64, // 1 minute
                // for main net
                _ => cs.epoch_progress = (now - time_start) as f64 / 86401f64, // 24 hours
            }
            if cs.epoch_progress > 1f64 {
                cs.epoch_progress = 0f64;
            };

            if let Some(first) = account_state
                .get_registered_currency_info_resources()?
                .first()
            {
                cs.total_supply = (first.total_value() / first.scaling_factor() as u128) as u64;
            }

            cs.height = meta.version;

            ////////////// GET VALIDATOR INFO //////////////
            let validator_set = match account_state.get_validator_set()? {
                Some(vs) => vs,
                None => bail!("cannot get validator set resource from chain"),
            };

            cs.validator_count = validator_set.payload().len() as u64;

            // Get vals stats
            let validators_stats = match account_state.get_validators_stats()? {
                Some(vsr) => vsr,
                None => bail!("could not get validators stats"),
            };

            let dict = self.load_account_dictionary();

            // Fetch and format all data for each Validator
            let validators: Vec<ValidatorView> = validator_set
                .payload()
                .iter()
                .filter_map(|v| self.format_validator_info(v, &dict, &validators_stats).ok())
                .collect();

            cs.validator_view = Some(validators.clone());
            cs.validators_stats = Some(validators_stats);
            cs.vals_config_stats = calc_config_stats(validators.clone()).ok();
            cs.autopay_watch_list = self.get_autopay_watch_list(validators.clone());
            cs.upgrade = self.client.get_oracle_upgrade_state()?;

            self.vitals.chain_view = Some(cs.clone());

            return Ok((cs, validators));
        }

        bail!("could not get chain info")
    }

    fn format_validator_info(
        &mut self,
        v: &ValidatorInfo,
        dict: &AccountDictionary,
        stats: &ValidatorsStatsResource,
    ) -> Result<ValidatorView, Error> {
        let vfn_full_ip = match v.config().fullnode_network_addresses() {
            Ok(ips) => {
                if ips.len() > 0 {
                    ips.last().unwrap().to_string()
                } else {
                    "--".to_string()
                }
            }
            Err(_) => "--".to_string(),
        };

        let vfn_ip = extract_ip(&vfn_full_ip);

        let validator_full_ip = match v.config().validator_network_addresses() {
            Ok(ips) => ips
                .first()
                .unwrap()
                .clone()
                .decrypt(
                    &diem_types::network_address::encrypted::TEST_SHARED_VAL_NETADDR_KEY,
                    &v.account_address().clone(),
                    0,
                )?
                .to_string(),
            Err(_) => "--".to_string(),
        };

        let validator_ip = extract_ip(&validator_full_ip);

        let ms = self
            .client
            .get_miner_state(&v.account_address().clone())?
            .unwrap();

        let one_val_stat = stats.get_validator_current_stats(v.account_address().clone())?;

        let val_config_opt = match self.get_validator_config(v.account_address().clone()) {
            Ok(v) => Some(v),
            Err(_) => None,
        };

        let autopay_opt = match self.get_autopay_view(v.account_address().clone()) {
            Ok(a) => Some(a),
            Err(_) => None,
        };

        let burn_to_community = match self.get_annotate_account_blob(v.account_address().clone()) {
            Ok((Some(r), _)) => {
                match query::find_value_from_state(
                    &r,
                    "Burn".to_string(),
                    "BurnPreference".to_string(),
                    "send_community".to_string(),
                ) {
                    Some(resource_viewer::AnnotatedMoveValue::Bool(b)) => *b,
                    _ => false,
                }
            }
            _ => false,
        };

        let ports = get_ports_status(&validator_ip);

        Ok(ValidatorView {
            account_address: v.account_address().to_string(),
            voting_power: v.consensus_voting_power(),
            vfn_full_ip,
            vfn_ip,
            pub_key: v.consensus_public_key().to_string(),
            validator_full_ip,
            validator_ip,
            ports_status: ports,

            tower_height: ms.verified_tower_height,
            tower_epoch: ms.latest_epoch_mining,
            count_proofs_in_epoch: ms.actual_count_proofs_in_epoch,
            epochs_validating_and_mining: ms.epochs_validating_and_mining,
            contiguous_epochs_validating_and_mining: ms.contiguous_epochs_validating_and_mining,
            epochs_since_last_account_creation: ms.epochs_since_last_account_creation,

            vote_count_in_epoch: one_val_stat.vote_count,
            prop_count_in_epoch: one_val_stat.prop_count,
            validator_config: val_config_opt,
            autopay: autopay_opt,
            burn_to_community,
            note: dict.get_note_for_address(*v.account_address()),
        })
    }
}

fn calc_config_stats(vals: Vec<ValidatorView>) -> Result<ValsConfigStats, Error> {
    let mut count_autopay = 0;
    let mut count_operators = 0;
    let mut count_positive_balance = 0;

    for val in vals.iter() {
        if let Some(config) = val.validator_config.clone() {
            if let Some(a) = &val.autopay {
                if a.payments.iter().any(|each| each.is_percent_of_change()) {
                    count_autopay += 1;
                }
            }
            if config.operator_account.is_some() {
                count_operators += 1;
            }
            if config.operator_has_balance.is_some() && config.operator_has_balance.unwrap_or(false)
            {
                count_positive_balance += 1;
            }
        }
    }
    Ok(ValsConfigStats {
        total_vals: vals.len(),
        count_vals_with_autopay: count_autopay,
        count_vals_with_operator: count_operators,
        count_positive_balance_operators: count_positive_balance,
        percent_vals_with_autopay: count_autopay as f64 / vals.len() as f64,
        percent_vals_with_operator: count_operators as f64 / vals.len() as f64,
        percent_positive_balance_operators: count_positive_balance as f64 / vals.len() as f64,
    })
}

fn get_ports_status(ip: &String) -> HashMap<String, bool> {
    let mut result: HashMap<String, bool> = HashMap::new();
    let ports = get_ports_to_test();
    for port in ports.iter() {
        result.insert(port.to_string(), scan_port(&ip, port));
    }
    result
}

fn scan_port(ip: &String, port: &u16) -> bool {
    let timeout = Duration::from_millis(200);
    match IpAddr::from_str(ip) {
        Ok(address) => {
            let socket_address = SocketAddr::new(address, port.clone());
            match TcpStream::connect_timeout(&socket_address, timeout) {
                Ok(_) => true,
                _ => false,
            }
        }
        Err(_) => false,
    }
}

fn get_ports_to_test() -> Vec<u16> {
    // TODO: default OR read from local file
    vec![6180u16]
}

fn extract_ip(full_ip: &String) -> String {
    let split_str: Vec<&str> = full_ip.split('/').collect();
    match split_str.get(2) {
        Some(ip) => ip.to_string(),
        None => full_ip.to_string(),
    }
}
