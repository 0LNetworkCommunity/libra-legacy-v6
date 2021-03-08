//! `bal` subcommand

use abscissa_core::{Command, Options, Runnable};
use cli::libra_client::LibraClient;
use reqwest::Url;
use libra_types::{account_address::AccountAddress, account_state::AccountState, transaction::Version, waypoint::Waypoint};
use num_format::{Locale, ToFormattedString};
use resource_viewer::{AnnotatedAccountStateBlob, MoveValueAnnotator, NullStateView};

// use anyhow::Error;
// use crate::{
//     commands::{is_address, is_authentication_key},
//     libra_client::LibraClient,
//     // AccountData, AccountStatus,
// };
use anyhow::{bail, ensure, format_err, Error, Result};
// use compiled_stdlib::StdLibOptions;
// use compiler::Compiler;
// use libra_crypto::{
//     ed25519::{Ed25519PrivateKey, Ed25519PublicKey, Ed25519Signature},
//     test_utils::KeyPair,
// };
// use libra_json_rpc_client::views::{AccountView, EventView, MetadataView, TransactionView, VMStatusView, MinerStateResourceView, OracleResourceView};
// use libra_logger::prelude::*;
// use libra_temppath::TempPath;
use libra_types::{
    access_path::AccessPath,
    account_address::AccountAddress,
    account_config::{
        from_currency_code_string, libra_root_address, testnet_dd_account_address,
        treasury_compliance_account_address, type_tag_for_currency_code,
        ACCOUNT_RECEIVED_EVENT_PATH, ACCOUNT_SENT_EVENT_PATH, COIN1_NAME, LBR_NAME,
    },
    account_state::AccountState,
    chain_id::ChainId,
    ledger_info::LedgerInfoWithSignatures,
    transaction::{
        authenticator::AuthenticationKey,
        helpers::{create_unsigned_txn, create_user_txn, TransactionSigner},
        parse_transaction_argument, Module, RawTransaction, Script, SignedTransaction,
        TransactionArgument, TransactionPayload, Version, WriteSetPayload,
    },
    waypoint::Waypoint,
};
// use libra_wallet::{Mnemonic, WalletLibrary, io_utils};
// use num_traits::{
//     // cast::{FromPrimitive, ToPrimitive},
//     // identities::Zero,
// };
use reqwest::Url;
use resource_viewer::{AnnotatedAccountStateBlob, MoveValueAnnotator, NullStateView};
// use rust_decimal::Decimal;
use std::{
    collections::HashMap,
    convert::TryFrom,
    fmt, fs,
    io::{stdout, Write},
    path::{Path, PathBuf},
    process::Command,
    str::{self, FromStr},
    thread, time,
};
use std::fs::File;
use std::io::Read;

/// `bal` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Default, Options)]
pub struct BalCmd {
    #[options(short = "u", help = "URL for client connection")]
    url: Option<Url>,

    #[options(short = "w", help = "Waypoint to sync from")]
    way: Option<Waypoint>,

    #[options(short = "a", help = "account to query")]
    account: String,
}

impl Runnable for BalCmd {
    fn run(&self) {
        let mut client = LibraClient::new(
            self.url.clone().unwrap_or("http://localhost:808".to_owned().parse().unwrap()),
            self.way.unwrap()
        ).unwrap();

        let account_struct = self.account.clone().parse::<AccountAddress>().unwrap();
        let (account_view, _) = client.get_account(account_struct, true).unwrap();

        for av in account_view.unwrap().balances.iter() {
            if av.currency == "GAS" { println!("{} GAS", av.amount.to_formatted_string(&Locale::en)) }
        }
    }
}


fn get_annotate_account_blob(
    &mut self,
    address: AccountAddress,
) -> Result<(Option<AnnotatedAccountStateBlob>, Version)> {
    let (blob, ver) = self.client.get_account_state_blob(address)?;
    if let Some(account_blob) = blob {
        let state_view = NullStateView::default();
        let annotator = MoveValueAnnotator::new(&state_view);
        let annotate_blob =
            annotator.view_account_state(&AccountState::try_from(&account_blob)?)?;
        Ok((Some(annotate_blob), ver))
    } else {
        Ok((None, ver))
    }
}