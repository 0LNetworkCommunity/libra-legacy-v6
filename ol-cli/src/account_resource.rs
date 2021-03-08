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
use anyhow::{Result};
// use compiled_stdlib::StdLibOptions;
// use compiler::Compiler;
// use libra_crypto::{
//     ed25519::{Ed25519PrivateKey, Ed25519PublicKey, Ed25519Signature},
//     test_utils::KeyPair,
// };
// use libra_json_rpc_client::views::{AccountView, EventView, MetadataView, TransactionView, VMStatusView, MinerStateResourceView, OracleResourceView};
// use libra_logger::prelude::*;
// use libra_temppath::TempPath;

// use libra_wallet::{Mnemonic, WalletLibrary, io_utils};
// use num_traits::{
//     // cast::{FromPrimitive, ToPrimitive},
//     // identities::Zero,
// };
// use reqwest::Url;
// use resource_viewer::{AnnotatedAccountStateBlob, MoveValueAnnotator, NullStateView};
// use rust_decimal::Decimal;
use std::{
    collections::HashMap,
    convert::TryFrom,
    fmt, fs,
    io::{stdout, Write},
    path::{Path, PathBuf},
    // process::Command,
    str::{self, FromStr},
    thread, time,
};

pub fn get_annotate_account_blob(
    mut client: LibraClient,
    address: AccountAddress,
) -> Result<(Option<AnnotatedAccountStateBlob>, Version)> {
    let (blob, ver) = client.get_account_state_blob(address)?;
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