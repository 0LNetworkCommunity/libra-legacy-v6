//! `autopay`

use anyhow::Error;
use libra_types::{
    account_address::AccountAddress,
    transaction::{Script, TransactionArgument},
};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::{fs, path::PathBuf};
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
/// Autopay payment instruction
pub struct PayInstruction {
    /// unique id of instruction
    pub uid: u64,
    /// type of instruction
    pub in_type: u8,
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
    pub fn parse_autopay_instructions(autopay_batch_file: &PathBuf) -> Result<Vec<PayInstruction>, Error> {
        let file = fs::File::open(autopay_batch_file).expect(&format!(
            "cannot open autopay batch file: {:?}",
            autopay_batch_file
        ));
        let json: Value = serde_json::from_reader(&file).expect("cannot parse autopay.json");
        let val: Value = json.get("autopay_instructions").unwrap().to_owned();
        let inst_vec: Vec<PayInstruction> = serde_json::from_value(val).unwrap();
        
        let mut total_pct_inflow: f64 = 0f64;
        let mut total_pct_balance: f64 = 0f64;

        let transformed = inst_vec.into_iter()
        .map(|mut i| {
            // TODO: check sequential instructions by uid
            // check the object has an actual payment instruction.
            if !i.percent_inflow.is_some() &&
            !i.percent_balance.is_some() &&
            !i.fixed_payment.is_some() {
              println!("autopay instruction file not valid, skipping all transactions. Issue at instruction {:?}", i);
            }
            i.cast_scale();
            if let Some(pct_in) = i.percent_inflow {total_pct_inflow = total_pct_inflow + pct_in};

            if let Some(pct_bal) = i.percent_balance {total_pct_balance = total_pct_balance + pct_bal};

            i
        })
        .collect();

        if (total_pct_inflow < 100f64) && (total_pct_balance < 100f64){
          Ok(transformed)
        } else {
          Err(Error::msg("percentages sum greater than 100%"))
        }
    }

    /// checks ths instruction against the raw script for correctness.
    pub fn check_instruction_safety(&self, script: Script) -> Result<(), Error> {
        let PayInstruction {
            uid,
            in_type,
            destination,
            end_epoch,
            percent_balance_cast,
            ..
        } = *self;

        assert!(
            script.args()[0] == TransactionArgument::U64(uid),
            "not same unique id"
        );
        assert!(
            script.args()[1] == TransactionArgument::Address(destination),
            "not sending to expected destination"
        );
        assert!(
            script.args()[2] == TransactionArgument::U64(end_epoch),
            "not the same ending epoch"
        );
        assert!(
            script.args()[3]
                == TransactionArgument::U64(
                    percent_balance_cast.expect("cannot get percent_balance_cast")
                ),
            "not the same ending epoch"
        );
        Ok(())
    }

    /// add cast fields in instruction objects
    pub fn cast_scale(&mut self) -> &Self {
        // for percentages need to convert and scale the two decimal places
        self.percent_inflow_cast = scale_fractional(&self.percent_inflow);
        self.percent_balance_cast = scale_fractional(&self.percent_balance);
        self
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