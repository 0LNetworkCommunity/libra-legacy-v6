//! `autopay`

use libra_types::account_address::AccountAddress;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::{fs, path::PathBuf};

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
/// Autopay payment instruction
pub struct Instruction {
    /// unique id of instruction
    pub uid: u64,
    /// destination account
    pub destination: AccountAddress,
    /// percentage of new inflow of epoch
    pub percent_inflow: Option<u64>,
    /// percentage of total balance at transaction time
    pub percent_balance: Option<u64>,
    /// percentage of total balance at transaction time
    pub fixed_payment: Option<u64>,
    /// epoch when payment instruction will stop
    pub end_epoch: u64,
    /// optional duration in epochs of the instruction
    pub duration_epochs: Option<u64>,
}

/// extract autopay instructions from json file
pub fn get_instructions(autopay_batch_file: &PathBuf) -> Vec<Instruction> {
    let file = fs::File::open(autopay_batch_file).expect(&format!(
        "cannot open autopay batch file: {:?}",
        autopay_batch_file
    ));
    let json: Value = serde_json::from_reader(file).expect("cannot parse autopay.json");
    let inst = json
        .get("autopay_instructions")
        .expect("file should have array of instructions");
    let batch = inst.as_array().unwrap().into_iter();

    batch
    .map(|value| {
      let readable_inst = value.to_string();
      let inst = value.as_object().expect("expected json object");

      // for percentages need to convert and scale the two decimal places
      let percent_inflow= inst
      .get("percent_inflow")
      .and_then(|f| scale_fractional(f));

      let percent_balance = inst
      .get("percent_balance")
      .and_then(|f| scale_fractional(f));

      let fixed_payment =  inst
      .get("fixed_payment").and_then(|f| f.as_u64());

      if percent_inflow.is_some() || percent_balance.is_some() || fixed_payment.is_some() {
        Instruction {
          uid: inst["uid"].as_u64().expect(&format!("no 'uid' found in line: {:?}", readable_inst)),
          destination: inst["destination"]
            .as_str()
            .unwrap()
            .to_owned()
            .parse()
            .expect(&format!("no 'destination' found in line: {:?}", readable_inst)),
          percent_inflow: percent_inflow,
          percent_balance: percent_balance,
          fixed_payment: fixed_payment,
          end_epoch: inst["end_epoch"].as_u64().expect(&format!("no 'end_epoch' found in line: {:?}", readable_inst)),
          duration_epochs: inst["duration_epochs"].as_u64(),
        }
      } else {
        panic!(format!("Malformed instruction, missing one of: percent_inflow, percent_balance, fixed_payment{:?}", readable_inst));
      }


    })
    .collect()
}

// convert the decimals for Move.
// for autopay purposes percentages have two decimal places precision.
// No rounding is applied. The third decimal is trucated.
// the result is a integer of 4 bits.
fn scale_fractional(fract_percent: &Value) -> Option<u64>{
    // finish parsing the json
    match fract_percent.as_f64() {
        Some(fractional) => {    // multiply by 100 to get the desired decimal precision
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
        None => None
    }

}
