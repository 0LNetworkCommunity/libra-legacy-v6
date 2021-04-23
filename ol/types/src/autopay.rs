//! `autopay`

use libra_types::account_address::AccountAddress;
use serde::{Deserialize, Serialize};
use std::{fs, path::PathBuf};
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
/// Autopay payment instruction
pub struct PayInstruction {
    /// unique id of instruction
    pub uid: u64,
    /// destination account
    pub destination: AccountAddress,
    /// percentage of new inflow of epoch
    pub percent_inflow: Option<f64>,
    /// inflow percent cast to four digit u64 for Move
    pub percent_inflow_cast: Option<u64>,
    /// percentage of total balance at transaction time
    pub percent_balance: Option<f64>,
    /// balance percent cast to four digit u64 for Move
    pub percent_balance_cast: Option<u64>,
    /// percentage of total balance at transaction time
    pub fixed_payment: Option<u64>,
    /// epoch when payment instruction will stop
    pub end_epoch: u64,
    /// optional duration in epochs of the instruction
    pub duration_epochs: Option<u64>,
}

impl PayInstruction {
    /// extract autopay instructions from json file
    pub fn parse_autopay_instructions(autopay_batch_file: &PathBuf) -> Vec<PayInstruction> {
        let file = fs::File::open(autopay_batch_file).expect(&format!(
            "cannot open autopay batch file: {:?}",
            autopay_batch_file
        ));
        let inst_vec: Vec<PayInstruction> =
            serde_json::from_reader(&file).expect("cannot parse autopay.json");
        // let json: Value = serde_json::from_reader(&file).expect("cannot parse autopay.json");
        inst_vec.into_iter()
  .map(|mut i| {
    // TODO: check sequential instructions by uid

    // check the object has an actual payment instruction.
    if !i.percent_inflow.is_some() &&
    !i.percent_balance.is_some() &&
    !i.fixed_payment.is_some() {
    println!("autopay instruction file not valid, skipping all transactions. Issue at instruction {:?}", i);
    }
    // for percentages need to convert and scale the two decimal places
    i.percent_inflow_cast = scale_fractional(&i.percent_inflow);
    i.percent_balance_cast = scale_fractional(&i.percent_balance);
    i
  })
  .collect()
    }
}

// convert the decimals for Move.
// for autopay purposes percentages have two decimal places precision.
// No rounding is applied. The third decimal is trucated.
// the result is a integer of 4 bits.
fn scale_fractional(fract_percent: &Option<f64>) -> Option<u64> {
    // finish parsing the json
    match fract_percent {
        Some(fractional) => {
            // multiply by 100 to get the desired decimal precision
            let scaled = fractional * 100 as f64;
            // drop the fractional part with trunc()
            let trunc = scaled.trunc() as u64; // return max 4 digits.
            if trunc < 9999 {
                Some(trunc)
            } else {
                println!("percent needs to have max four digits, skipping");
                None
            }
        }
        None => None,
    }
}
