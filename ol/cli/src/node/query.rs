//! 'query'
use std::collections::BTreeMap;

use super::node::Node;
use anyhow::Error;
use diem_json_rpc_client::{
    views::{BytesView, EventView, TransactionView},
    AccountAddress,
};
use hex::decode;
use move_binary_format::file_format::{Ability, AbilitySet};
use move_core_types::{
    identifier::Identifier,
    language_storage::{StructTag, TypeTag},
};
use num_format::{Locale, ToFormattedString};
use resource_viewer::{AnnotatedAccountStateBlob, AnnotatedMoveStruct, AnnotatedMoveValue};
use serde::{Deserialize, Serialize};

const SCALING_FACTOR: u64 = 1_000_000;

#[derive(Debug)]
/// What query do we want to return
pub enum QueryType {
    /// Account balance
    Balance {
        /// account to query txs of
        account: AccountAddress,
    },
    /// Unlocked Account balance
    UnlockedBalance {
        /// account to query txs of
        account: AccountAddress,
    },
    /// Epoch and waypoint
    Epoch,
    /// Network block height
    BlockHeight,
    /// All account resources
    Resources {
        /// account to query txs of
        account: AccountAddress,
    },
    /// get a move value from account blob
    MoveValue {
        /// account to query txs of
        account: AccountAddress,
        /// move module name
        module_name: String,
        /// move struct name
        struct_name: String,
        /// move key name
        key_name: String,
    },
    /// How far behind the local is from the upstream nodes
    SyncDelay,
    /// Get transaction history
    Txs {
        /// account to query txs of
        account: AccountAddress,
        /// get transactions after this height
        txs_height: Option<u64>,
        /// limit how many txs
        txs_count: Option<u64>,
        /// filter by type
        txs_type: Option<String>,
    },
    /// Get events
    Events {
        /// account to query events
        account: AccountAddress,
        /// switch for sent or received events.
        sent_or_received: bool,
        /// what event sequence number to start querying from, if DB does not have all.
        seq_start: Option<u64>,
    },
    /// get the validator's on-chain configuration, including network discovery addresses
    ValConfig {
        /// the account of the validator
        account: AccountAddress,
    },
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]

/// wallet type
pub enum WalletType {
    ///
    None,
    ///
    Slow,
    ///
    Community,
}

/// Get data from a client, with a query type. Will connect to local only if in sync.
impl Node {
    /// run a query
    // TODO: Make query accept and return a generic, instead of return formatted string.
    // that would make it more general purpose.
    pub fn query(&mut self, query_type: QueryType) -> Result<String, Error> {
        use QueryType::*;
        let print = match query_type {
            Balance { account } => {
                // TODO: get scaling factor from chain.
                match self.client.get_account(&account) {
                    Ok(Some(account_view)) => {
                        match account_view.balances.iter().find(|av| av.currency == "GAS") {
                            Some(av) => {
                                let a = av.amount as f64;
                                a.to_string()
                            }
                            _ => "No GAS found on account".to_owned(),
                        }
                    }
                    Ok(None) => format!("No account {} found on chain, account", account),
                    Err(e) => format!("Chain query error: {:?}", e),
                }
            }
            UnlockedBalance { account } => {
                // account
                match self.get_annotate_account_blob(account) {
                    Ok((Some(r), _)) => {
                        if !is_slow_wallet(&r) {
                            format!("Error, account is not a slow wallet")
                        } else {
                            let value = find_value_from_state(
                                &r,
                                "DiemAccount".to_string(),
                                "SlowWallet".to_string(),
                                "unlocked".to_string(),
                            );
                            value.unwrap().to_string()
                        }
                    }
                    Err(e) => format!("Error retrieving unlocked balance. Message: {:#?}", e),
                    _ => format!("Error, cannot find account state for {:#?}", account),
                }
            }
            BlockHeight => self.refresh_chain_info()?.0.height.to_string(),
            Epoch => {
                let c = self.refresh_chain_info()?;

                format!(
                    "{} - WAYPOINT: {}",
                    &c.0.epoch.to_string(),
                    &c.0.waypoint.unwrap_or_default().to_string()
                )
            }
            SyncDelay => match self.check_sync() {
                Ok(sync) => format!(
                    "is synced: {}, local height: {}, upstream delay: {}",
                    sync.is_synced, sync.sync_height, sync.sync_delay
                ),
                Err(e) => e.to_string(),
            },
            Resources { account } => {
                // account
                match self.get_annotate_account_blob(account) {
                    Ok((Some(r), _)) => format!("{:#?}", r),
                    Err(e) => format!("Error querying account resource. Message: {:#?}", e),
                    _ => format!("Error, cannot find account state for {:#?}", account),
                }
            }
            MoveValue {
                account,
                module_name,
                struct_name,
                key_name,
            } => {
                // account
                match self.get_annotate_account_blob(account) {
                    Ok((Some(r), _)) => {
                        let value = find_value_from_state(&r, module_name, struct_name, key_name);
                        format!("{:#?}", value)
                    }
                    Err(e) => format!("Error querying account resource. Message: {:#?}", e),
                    _ => format!("Error, cannot find account state for {:#?}", account),
                }
            }
            Txs {
                account,
                txs_height,
                txs_count,
                txs_type,
            } => {
                let current_height = self.refresh_chain_info()?.0.height;
                let query_height = if current_height > 100_000 {
                    current_height - 100_000
                } else {
                    0
                };

                let txs = self
                    .client
                    .get_txn_by_acc_range(
                        account,
                        txs_height.unwrap_or(query_height),
                        txs_count.unwrap_or(100),
                        true,
                    )
                    .unwrap();

                if let Some(t) = txs_type {
                    use diem_json_rpc_client::views::TransactionDataView;
                    let filter: Vec<TransactionView> = txs
                        .into_iter()
                        .filter(|tv| match &tv.transaction {
                            TransactionDataView::UserTransaction { script, .. } => {
                                return script.r#type == t;
                            }
                            _ => false,
                        })
                        .collect();
                    format!("{:#?}", filter)
                } else {
                    format!("{:#?}", txs)
                }
            }
            Events {
                account,
                sent_or_received,
                seq_start,
            } => {
                // TODO: should borrow and not create a new client.
                let mut print = "Events \n".to_string();
                let handles = self.get_payment_event_handles(account).unwrap();

                if let Some((sent_handle, received_handle)) = handles {
                    for evt in self.get_handle_events(&sent_handle, seq_start).unwrap() {
                        if sent_or_received {
                            print.push_str(&format_event_view(evt))
                        }
                    }
                    for evt in self.get_handle_events(&received_handle, seq_start).unwrap() {
                        if !sent_or_received {
                            print.push_str(&format_event_view(evt))
                        }
                    }
                };
                print
            }
            //           Tower { account } => {
            //             match self.get_account_state(account) {
            //               Ok(a) => {
            //                 let t: Option<TowerStateResource> = a.get_resource()?;

            //               },
            //               Err(_) => format!("No tower found at: {}", account)
            // ,
            //             }
            //           }
            ValConfig { account } => {
                // account
                match self.get_account_state(account) {
                    Ok(a) => {
                        if let Some(cr) = a.get_validator_config_resource()? {
                            let val_addr = cr
                                .clone()
                                .validator_config
                                .unwrap()
                                .validator_network_addresses()?;

                            let val_decrypted = val_addr
                          .first()
                          .unwrap()
                          .clone()
                          .decrypt(
                            &diem_types::network_address::encrypted::TEST_SHARED_VAL_NETADDR_KEY,
                            &account,
                            0
                          )?;

                            format!(
                                "\n
                            consensus pubkey: {:?}\n
                            validator network addr: {:?}\n
                            fullnode network addr: {:?}\n
                            ",
                                cr.clone()
                                    .validator_config
                                    .unwrap()
                                    .consensus_public_key
                                    .to_string(),
                                val_decrypted,
                                cr.validator_config.unwrap().fullnode_network_addresses()?,
                            )
                        } else {
                            format!("No validator configs found at: {}", account)
                        }
                    }
                    Err(_) => format!("No validator configs cound at: {}", account),
                }
            }
        };
        Ok(print)
    }
}

fn format_event_view(e: EventView) -> String {
    // TODO: make this more idiomatic.

    use diem_json_rpc_client::views::EventDataView::*;
    let (a, s, r, BytesView(m), ..) = match e.data {
        ReceivedPayment {
            amount,
            sender,
            receiver,
            metadata,
        } => (amount, sender, receiver, metadata),
        SentPayment {
            amount,
            receiver,
            sender,
            metadata,
        } => (amount, sender, receiver, metadata),
        _ => {
            panic!(
            "trying to parse a payment event type, but event is not a ReceivedPayment or SentPayment"
        )
        }
    };
    let scaled = a.amount / SCALING_FACTOR;
    dbg!(&m);
    format!(
        "id: {:?}, sender: {:?}, recipient: {:?}, amount: {:?}, metadata: {:?}\n",
        e.sequence_number,
        s.to_string(),
        r.to_string(),
        scaled.to_formatted_string(&Locale::en),
        String::from_utf8_lossy(&decode(m).unwrap_or(vec![])),
    )
}

/// check if the vec of value, is actually of other structs
pub fn is_vec_of_struct(move_val: &Vec<AnnotatedMoveValue>) -> bool {
    if let Some(e) = move_val.first() {
        match e {
            AnnotatedMoveValue::Struct(_) => return true,
            _ => return false,
        }
    }
    false
}

/// get last vec
pub fn get_last_stuct_in_vec(move_val: &Vec<AnnotatedMoveValue>) -> bool {
    if let Some(e) = move_val.first() {
        match e {
            AnnotatedMoveValue::Struct(_) => return true,
            _ => return false,
        }
    }
    false
}

// Ability to query Move types by walking an account blob. This is for structs which we may not have an equivalent type created in rust. For structs the core platform uses we have mappings available e.g. ol/types/src/miner_state.rs. This solves querying for resource structs that may be created by third parties.

/// check if the vec of value, is actually of other structs
pub fn unwrap_val_to_struct(move_val: &AnnotatedMoveValue) -> Option<&AnnotatedMoveStruct> {
    match move_val {
        AnnotatedMoveValue::Struct(s) => Some(s),
        _ => None,
    }
}

/// find the value in a struct
pub fn find_value_in_struct(
    s: &AnnotatedMoveStruct,
    key_name: String,
) -> Option<&AnnotatedMoveValue> {
    match s
        .value
        .iter()
        .find(|v| v.0.clone().into_string() == key_name)
    {
        Some((_, v)) => Some(v),
        None => None,
    }
}
/// finds a value
pub fn find_value_from_state(
    blob: &AnnotatedAccountStateBlob,
    module_name: String,
    struct_name: String,
    key_name: String,
) -> Option<&AnnotatedMoveValue> {
    match blob.0.values().find(|&s| {
        s.type_.module.as_ref().to_string() == module_name
            && s.type_.name.as_ref().to_string() == struct_name
    }) {
        Some(s) => find_value_in_struct(s, key_name),
        None => None,
    }
}

/// check if is a slow wallet
pub fn is_slow_wallet(r: &AnnotatedAccountStateBlob) -> bool {
    let slow_module_name = "DiemAccount";
    let slow_struct_name = "SlowWallet";
    let unlocked = find_value_from_state(
        &r,
        slow_module_name.to_string(),
        slow_struct_name.to_string(),
        "unlocked".to_string(),
    );
    if !unlocked.is_none() {
        return true;
    }
    false
}

/// check if is a community wallet
pub fn is_community_wallet(r: &AnnotatedAccountStateBlob) -> bool {
    let community_module_name = "Wallet";
    let community_struct_name = "CommunityFreeze";
    let is_frozen = find_value_from_state(
        &r,
        community_module_name.to_string(),
        community_struct_name.to_string(),
        "is_frozen".to_string(),
    );
    if let Some(AnnotatedMoveValue::Bool(false)) = is_frozen {
        let consecutive_rejections = find_value_from_state(
            &r,
            community_module_name.to_string(),
            community_struct_name.to_string(),
            "consecutive_rejections".to_string(),
        );
        if let Some(AnnotatedMoveValue::U64(0)) = consecutive_rejections {
            let unfreeze_votes = find_value_from_state(
                &r,
                community_module_name.to_string(),
                community_struct_name.to_string(),
                "unfreeze_votes".to_string(),
            );
            if let Some(AnnotatedMoveValue::Vector(TypeTag::Address, vec)) = unfreeze_votes {
                if vec.len() == 0 {
                    return true;
                }
            }
        }
    }
    false
}

/// test fixtures
pub fn test_fixture_blob() -> AnnotatedAccountStateBlob {
    let mut s = BTreeMap::new();
    let move_struct = test_fixture_struct();
    s.insert(move_struct.type_.clone(), move_struct);
    AnnotatedAccountStateBlob(s)
}

/// stuct fixture
pub fn test_fixture_struct() -> AnnotatedMoveStruct {
    let module_tag = StructTag {
        address: AccountAddress::random(),
        module: Identifier::new("TestModule").unwrap(),
        name: Identifier::new("TestStructName").unwrap(),
        type_params: vec![TypeTag::Bool],
    };

    let key = Identifier::new("test_key").unwrap();
    let value = AnnotatedMoveValue::Bool(true);

    AnnotatedMoveStruct {
        abilities: AbilitySet::EMPTY | Ability::Key,
        type_: module_tag.clone(),
        value: vec![(key, value)],
    }
}

/// test fixtures to generate wallet
pub fn test_fixture_wallet_type(
    module_name: &str,
    struct_name: &str,
    value: Vec<(Identifier, AnnotatedMoveValue)>,
) -> AnnotatedAccountStateBlob {
    let mut s = BTreeMap::new();
    let module_tag = StructTag {
        address: AccountAddress::random(),
        module: Identifier::new(module_name).unwrap(),
        name: Identifier::new(struct_name).unwrap(),
        type_params: vec![],
    };

    let move_struct = AnnotatedMoveStruct {
        abilities: AbilitySet::EMPTY | Ability::Key,
        type_: module_tag.clone(),
        value,
    };
    s.insert(move_struct.type_.clone(), move_struct);
    AnnotatedAccountStateBlob(s)
}

#[test]
fn test_find_annotated_move_value() {
    let s = test_fixture_blob();
    match find_value_from_state(
        &s,
        "TestModule".to_owned(),
        "TestStructName".to_owned(),
        "test_key".to_owned(),
    ) {
        // NOTE: This is gross, but I don't see a way to use assert_eq! on AnnotatedMoveValue
        Some(v) => {
            match v {
                // TODO: For some reason can't use assert
                AnnotatedMoveValue::Bool(b) => assert!(*b == true),
                _ => panic!("not the right value"),
            }
        }
        None => panic!("not the right value"),
    }
}

#[test]
fn test_is_slow_wallet_should_return_true() {
    let value = vec![(
        Identifier::new("unlocked").unwrap(),
        AnnotatedMoveValue::U64(0),
    )];
    let s = test_fixture_wallet_type("DiemAccount", "SlowWallet", value);
    assert_eq!(true, is_slow_wallet(&s), "{}", s.to_string());
}

#[test]
fn test_is_slow_wallet_should_return_false_if_missing_unlocked() {
    let value = vec![(
        Identifier::new("transferred").unwrap(),
        AnnotatedMoveValue::U64(0),
    )];
    let s = test_fixture_wallet_type("DiemAccount", "SlowWallet", value);
    assert_eq!(false, is_slow_wallet(&s), "{}", s.to_string());
}

#[test]
fn test_is_slow_wallet_should_return_false_with_wrong_module_name() {
    let value = vec![
        (
            Identifier::new("unlocked").unwrap(),
            AnnotatedMoveValue::U64(0),
        ),
        (
            Identifier::new("transferred").unwrap(),
            AnnotatedMoveValue::U64(1),
        ),
    ];
    let s = test_fixture_wallet_type("IncorrectModuleName", "SlowWallet", value);
    assert_eq!(false, is_slow_wallet(&s), "{}", s.to_string());
}

#[test]
fn test_is_slow_wallet_should_return_false_with_wrong_struct_name() {
    let value = vec![
        (
            Identifier::new("unlocked").unwrap(),
            AnnotatedMoveValue::U64(0),
        ),
        (
            Identifier::new("transferred").unwrap(),
            AnnotatedMoveValue::U64(1),
        ),
    ];
    let s = test_fixture_wallet_type("DiemAccount", "IncorrectStructName", value);
    assert_eq!(false, is_slow_wallet(&s), "{}", s.to_string());
}

#[test]
fn test_is_community_wallet_should_return_true() {
    let value = vec![
        (
            Identifier::new("is_frozen").unwrap(),
            AnnotatedMoveValue::Bool(false),
        ),
        (
            Identifier::new("consecutive_rejections").unwrap(),
            AnnotatedMoveValue::U64(0),
        ),
        (
            Identifier::new("unfreeze_votes").unwrap(),
            AnnotatedMoveValue::Vector(TypeTag::Address, vec![]),
        ),
    ];
    let s = test_fixture_wallet_type("Wallet", "CommunityFreeze", value);
    assert_eq!(true, is_community_wallet(&s), "{}", s.to_string());
}

#[test]
fn test_is_community_wallet_should_return_false_with_wrong_is_frozen() {
    let value = vec![
        (
            Identifier::new("is_frozen").unwrap(),
            AnnotatedMoveValue::Bool(true),
        ),
        (
            Identifier::new("consecutive_rejections").unwrap(),
            AnnotatedMoveValue::U64(0),
        ),
        (
            Identifier::new("unfreeze_votes").unwrap(),
            AnnotatedMoveValue::Vector(TypeTag::Address, vec![]),
        ),
    ];
    let s = test_fixture_wallet_type("Wallet", "CommunityFreeze", value);
    assert_eq!(false, is_community_wallet(&s), "{}", s.to_string());
}

#[test]
fn test_is_community_wallet_should_return_false_with_wrong_consecutive_rejections() {
    let value = vec![
        (
            Identifier::new("is_frozen").unwrap(),
            AnnotatedMoveValue::Bool(false),
        ),
        (
            Identifier::new("consecutive_rejections").unwrap(),
            AnnotatedMoveValue::U64(1),
        ),
        (
            Identifier::new("unfreeze_votes").unwrap(),
            AnnotatedMoveValue::Vector(TypeTag::Address, vec![]),
        ),
    ];
    let s = test_fixture_wallet_type("Wallet", "CommunityFreeze", value);
    assert_eq!(false, is_community_wallet(&s), "{}", s.to_string());
}

#[test]
fn test_is_community_wallet_should_return_false_with_wrong_unfreeze_votes() {
    let value = vec![
        (
            Identifier::new("is_frozen").unwrap(),
            AnnotatedMoveValue::Bool(false),
        ),
        (
            Identifier::new("consecutive_rejections").unwrap(),
            AnnotatedMoveValue::U64(0),
        ),
        (
            Identifier::new("unfreeze_votes").unwrap(),
            AnnotatedMoveValue::Vector(TypeTag::Address, vec![AnnotatedMoveValue::Bool(false)]),
        ),
    ];
    let s = test_fixture_wallet_type("Wallet", "CommunityFreeze", value);
    assert_eq!(false, is_community_wallet(&s), "{}", s.to_string());
}

#[test]
fn test_is_community_wallet_should_return_false_if_missing_unfreeze_votes() {
    let value = vec![
        (
            Identifier::new("consecutive_rejections").unwrap(),
            AnnotatedMoveValue::U64(0),
        ),
        (
            Identifier::new("unfreeze_votes").unwrap(),
            AnnotatedMoveValue::Vector(TypeTag::Address, vec![]),
        ),
    ];
    let s = test_fixture_wallet_type("Wallet", "CommunityFreeze", value);
    assert_eq!(false, is_community_wallet(&s), "{}", s.to_string());
}

#[test]
fn test_is_community_wallet_should_return_false_if_missing_consecutive_rejections() {
    let value = vec![
        (
            Identifier::new("is_frozen").unwrap(),
            AnnotatedMoveValue::Bool(false),
        ),
        (
            Identifier::new("unfreeze_votes").unwrap(),
            AnnotatedMoveValue::Vector(TypeTag::Address, vec![]),
        ),
    ];
    let s = test_fixture_wallet_type("Wallet", "CommunityFreeze", value);
    assert_eq!(false, is_community_wallet(&s), "{}", s.to_string());
}

#[test]
fn test_is_community_wallet_should_return_false_with_wrong_module_name() {
    let value = vec![
        (
            Identifier::new("is_frozen").unwrap(),
            AnnotatedMoveValue::Bool(false),
        ),
        (
            Identifier::new("consecutive_rejections").unwrap(),
            AnnotatedMoveValue::U64(0),
        ),
        (
            Identifier::new("unfreeze_votes").unwrap(),
            AnnotatedMoveValue::Vector(TypeTag::Address, vec![]),
        ),
    ];
    let s = test_fixture_wallet_type("IncorrectModuleName", "CommunityFreeze", value);
    assert_eq!(false, is_community_wallet(&s), "{}", s.to_string());
}

#[test]
fn test_is_community_wallet_should_return_false_with_wrong_struct_name() {
    let value = vec![
        (
            Identifier::new("is_frozen").unwrap(),
            AnnotatedMoveValue::Bool(false),
        ),
        (
            Identifier::new("consecutive_rejections").unwrap(),
            AnnotatedMoveValue::U64(0),
        ),
        (
            Identifier::new("unfreeze_votes").unwrap(),
            AnnotatedMoveValue::Vector(TypeTag::Address, vec![]),
        ),
    ];
    let s = test_fixture_wallet_type("Wallet", "IncorrectStructName", value);
    assert_eq!(false, is_community_wallet(&s), "{}", s.to_string());
}
