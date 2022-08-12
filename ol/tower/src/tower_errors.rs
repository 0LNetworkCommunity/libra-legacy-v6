//! TowerError

use diem_json_rpc_types::views::VMStatusView;
use serde::{Deserialize, Serialize};
use std::fmt;
use txs::submit_tx::TxError;

/// Common errors in Tower transaction submission
#[derive(Debug, Serialize, Deserialize)]
pub enum TowerError {
    ///
    Unknown,
    ///
    Other(VMStatusView),
    ///
    AppConfigs,
    /// No local blocks to be found
    NoLocalBlocks,
    ///
    ProverError,
    /// 404 defined in txs::submit_tx.rs
    NoClientCx,
    /// 1004 defined in txs::submit_tx.rs and DiemAccount.move
    AccountDNE,
    /// 1005 defined in DiemAccount.move
    OutOfGas,
    /// 130102 defined in TowerState.move
    WrongDifficulty,
    /// 130108 defined in TowerState.move   
    TooManyProofs,
    /// 130109 defined in TowerState.move
    Discontinuity,
    /// 130110 defined in TowerState.move
    Invalid,
}

impl fmt::Display for TowerError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            TowerError::Unknown => write!(f, "Unknown: {}", TowerError::Unknown.value()),
            TowerError::Other(vmv) => write!(
                f,
                "Other: {}, {}",
                TowerError::Other(vmv.to_owned()).value(),
                &vmv.to_string()
            ),
            TowerError::AppConfigs => write!(
                f,
                "App configuration file issue: {}",
                TowerError::AppConfigs.value()
            ),
            TowerError::NoLocalBlocks => write!(
                f,
                "No local blocks found in dir: {}",
                TowerError::NoLocalBlocks.value()
            ),
            TowerError::ProverError => {
                write!(f, "Cannot create: {}", TowerError::ProverError.value())
            }
            TowerError::NoClientCx => write!(
                f,
                "Cannot Connect to client: {}",
                TowerError::NoClientCx.value()
            ),
            TowerError::AccountDNE => write!(
                f,
                "Account does not exist: {}",
                TowerError::AccountDNE.value()
            ),
            TowerError::OutOfGas => write!(
                f,
                "Account out of gas, or price insufficient: {}",
                TowerError::OutOfGas.value()
            ),
            TowerError::WrongDifficulty => write!(
                f,
                "Wrong VDF difficulty being used: {}",
                TowerError::WrongDifficulty.value()
            ),
            TowerError::TooManyProofs => write!(
                f,
                "Too many proofs submitted in epoch: {}",
                TowerError::TooManyProofs.value()
            ),
            TowerError::Discontinuity => write!(
                f,
                "Proof submitted does not match previous: {}",
                TowerError::Discontinuity.value()
            ),
            TowerError::Invalid => write!(
                f,
                "VDF Proof is invalid, cannot verify: {}",
                TowerError::Invalid.value()
            ),
        }
    }
}

impl TowerError {
    /// get numeric representation
    pub fn value(&self) -> u64 {
        match *self {
            //
            TowerError::Unknown => 100,
            //
            TowerError::Other(_) => 101,
            //
            TowerError::AppConfigs => 103,
            //
            TowerError::NoLocalBlocks => 104,
            //
            TowerError::ProverError => 105,
            // 404 defined in txs::submit_tx.rs
            TowerError::NoClientCx => 404,
            // 1004 defined in txs::submit_tx.rs and DiemAccount.move
            TowerError::AccountDNE => 1004,
            // 1005 defined in DiemAccount.move
            TowerError::OutOfGas => 1005,
            // 130102 defined in TowerState.move
            TowerError::WrongDifficulty => 130102,
            // 130108 defined in TowerState.move
            TowerError::TooManyProofs => 130108,
            // 130109 defined in TowerState.move
            TowerError::Discontinuity => 130109,
            // 130110 defined in TowerState.move
            TowerError::Invalid => 130110,
        }
    }
}

/// get the Tower Error from TxError
pub fn parse_error(tx_err: &TxError) -> TowerError {
    match tx_err.abort_code {
        Some(404) => TowerError::NoClientCx,
        Some(1004) => TowerError::AccountDNE,
        Some(130102) => TowerError::WrongDifficulty,
        Some(130108) => TowerError::TooManyProofs,
        Some(130109) => TowerError::Discontinuity,
        Some(130110) => TowerError::Invalid,
        _ => {
            if let Some(tv) = &tx_err.tx_view {
                match tv.vm_status {
                    diem_json_rpc_types::views::VMStatusView::OutOfGas => TowerError::OutOfGas,
                    _ => TowerError::Other(tv.vm_status.to_owned()),
                }
            } else {
                TowerError::Unknown
            }
        }
    }
}
