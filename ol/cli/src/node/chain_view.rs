//! `chain_info`
use anyhow::{bail, Error};
use chrono::Utc;
use diem_json_rpc::views::OracleUpgradeStateView;
use diem_types::{
    account_address::AccountAddress, account_state::AccountState,
    ol_validators_stats::ValidatorsStatsResource, validator_info::ValidatorInfo,
    waypoint::Waypoint,
};
use ol_types::{autopay::AutoPayView, validator_config::ValidatorConfigView};

use super::{node::Node, dictionary::AccountDictionary, autopay_view::PayeeStats};
use serde::{Deserialize, Serialize};
use std::{convert::TryFrom};

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
    /// total count votes in current epoch
    pub vote_count_in_epoch: u64,
    /// total block propositions in current epoch
    pub prop_count_in_epoch: u64,
    /// validator config in the chain
    pub validator_config: Option<ValidatorConfigView>,
    /// autopay instructions
    pub autopay: Option<AutoPayView>,
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

        cs.waypoint = Some(self.client.get_waypoint()?.into_inner().unwrap().waypoint);

        if let Some(account_blob) = blob {
            let account_state = AccountState::try_from(&account_blob)?;
            let meta = self.client.get_metadata()?.into_inner();

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
            cs.autopay_watch_list =  self.get_autopay_watch_list(validators.clone());
            cs.upgrade = self.client.get_oracle_upgrade_state()?.into_inner();

            self.vitals.chain_view = Some(cs.clone());

            return Ok((cs, validators));
        }

        bail!("could not get chain info")
    }

    fn format_validator_info(
      &mut self,
      v: &ValidatorInfo,
      dict: &AccountDictionary,
      stats: &ValidatorsStatsResource
    ) -> Result<ValidatorView, Error> {
    let full_node_ip = match v.config().fullnode_network_addresses() {
        Ok(ips) => {
            if ips.len() > 0 {
                ips.last().unwrap().to_string()
            } else {
                "--".to_string()
            }
        }
        Err(_) => "--".to_string(),
    };
    let validator_ip = match v.config().validator_network_addresses() {
        Ok(ips) => {
            if ips.len() > 0 {
                match ips.get(0) {
                    Some(netw_addr) => netw_addr.to_string(), // Todo: Needs review
                    None => "--".to_string(),
                }
            } else {
                "--".to_string()
            }
        }
        Err(_) => "--".to_string(),
    };
    let ms  = self.client.get_miner_state(v.account_address().clone())?.into_inner().unwrap();
    let one_val_stat = stats.get_validator_current_stats(v.account_address().clone());
    let val_config = self.get_validator_config(v.account_address().clone()).unwrap();
    let autopay = self.get_autopay_view(v.account_address().clone()).unwrap();

    Ok(ValidatorView {
        account_address: v.account_address().to_string(),
        voting_power: v.consensus_voting_power(),
        full_node_ip,
        pub_key: v.consensus_public_key().to_string(),
        validator_ip,

        tower_height: ms.verified_tower_height,
        tower_epoch: ms.latest_epoch_mining,
        count_proofs_in_epoch: ms.count_proofs_in_epoch,
        epochs_validating_and_mining: ms.epochs_validating_and_mining,
        contiguous_epochs_validating_and_mining: ms.contiguous_epochs_validating_and_mining,
        epochs_since_last_account_creation: ms.epochs_since_last_account_creation,
        
        vote_count_in_epoch: one_val_stat.vote_count,
        prop_count_in_epoch: one_val_stat.prop_count,
        validator_config: Some(val_config),
        autopay: Some(autopay),
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