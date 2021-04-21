//! `autopay`

use libra_types::account_address::AccountAddress;
use serde::{Deserialize, Serialize};
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
    let json: serde_json::Value = serde_json::from_reader(file).expect("cannot parse JSON");
    let inst = json
        .get("autopay_instructions")
        .expect("file should have array of instructions");
    let batch = inst.as_array().unwrap().into_iter();

    batch
    .map(|value| {
      let readable_inst = value.to_string();
      let inst = value.as_object().expect("expected json object");
      let percent_inflow = inst["percent_inflow"].as_u64();
      let percent_balance =inst["percent_balance"].as_u64();
      let fixed_payment =  inst["fixed_payment"].as_u64();

      if percent_inflow.is_some() || percent_balance.is_some() || fixed_payment.is_some() {
        Instruction {
          uid: inst["uid"].as_u64().expect(&format!("no 'uid' found in line: {:?}", readable_inst)),
          destination: inst["destination"]
            .as_str()
            .unwrap()
            .to_owned()
            .parse()
            .expect(&format!("no 'destination' found in line: {:?}", readable_inst)),
          percent_inflow,
          percent_balance,
          fixed_payment,
          end_epoch: inst["end_epoch"].as_u64().expect(&format!("no 'end_epoch' found in line: {:?}", readable_inst)),
          duration_epochs: inst["duration_epochs"].as_u64(),
        }
      } else {
        panic!(format!("Malformed instruction, missing one of: percent_inflow, percent_balance, fixed_payment{:?}", readable_inst));
      }


    })
    .collect()
}
