//! TowerError

use diem_json_rpc_types::views::VMStatusView;
use txs::submit_tx::TxError;

/// Common errors in Tower transaction submission
#[derive(Debug)]
pub enum TowerError {
    ///
    Unknown,
    ///
    Other(VMStatusView),
    /// 404 defined in txs::submit_tx.rs
    NoClientCx,      
    /// 1004 defined in txs::submit_tx.rs and DiemAccount.move 
    AccountDNE,
    /// 1005 defined in DiemAccount.move 
    OutOfGas,
    /// 130108 defined in TowerState.move   
    TooManyProofs, 
    /// 130109 defined in TowerState.move
    Discontinuity, 
    /// 130110 defined in TowerState.move
    Invalid,       
}

/// get the Tower Error from TxError
pub fn parse_error(tx_err: TxError) -> TowerError {
    match tx_err.abort_code {
        Some(404) => TowerError::NoClientCx,
        Some(1004) => TowerError::AccountDNE,
        Some(130108) => TowerError::TooManyProofs,
        Some(130109) => TowerError::Discontinuity,
        Some(130110) => TowerError::Invalid,
        _ => {
            if let Some(tv) = tx_err.tx_view {
                match tv.vm_status {
                    diem_json_rpc_types::views::VMStatusView::OutOfGas => TowerError::OutOfGas,
                    _ => TowerError::Other(tv.vm_status),
                }
            } else {
                TowerError::Unknown
            }
        }
    }
}
