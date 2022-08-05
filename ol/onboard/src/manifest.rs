//! `version` subcommand

#![allow(clippy::never_loop)]

use ol_keys::scheme::KeyScheme;
use ol_types::{block::VDFProof, config::AppCfg};

use crate::prelude::app_config;
use diem_types::transaction::SignedTransaction;
use diem_wallet::WalletLibrary;
use ol_types::{account::ValConfigs, pay_instruction::PayInstruction};
use std::path::PathBuf;

/// Creates an account.json file for the validator
pub fn write_manifest(
    path: &Option<PathBuf>,
    wallet: WalletLibrary,
    wizard_config: Option<AppCfg>,
    autopay_batch: Option<Vec<PayInstruction>>,
    autopay_signed: Option<Vec<SignedTransaction>>,
) {
    let cfg = if wizard_config.is_some() {
        wizard_config.unwrap()
    } else {
        app_config().clone()
    };

    let miner_home = path
        .clone()
        .unwrap_or_else(|| cfg.workspace.node_home.clone());

    let keys = KeyScheme::new(&wallet);
    let block = VDFProof::parse_block_file(cfg.get_block_dir().join("proof_0.json").to_owned());

    ValConfigs::new(
        Some(block),
        keys,
        cfg.profile.ip,
        cfg.profile.vfn_ip.unwrap_or("0.0.0.0".parse().unwrap()),
        autopay_batch,
        autopay_signed,
    )
    .create_manifest(miner_home);
}
