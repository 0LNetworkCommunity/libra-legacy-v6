//! `autopay`

use libra_types::{account_address::AccountAddress};
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
  /// percentage to send
  pub percentage: u64,
  // TODO: fixed rate to send
  // pub percentage: u64, 
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
      let inst = value.as_object().expect("expected json object");
      Instruction {
        uid: inst["uid"].as_u64().unwrap(),
        destination: inst["destination"]
          .as_str()
          .unwrap()
          .to_owned()
          .parse()
          .unwrap(),
        percentage: inst["percentage"].as_u64().unwrap(),
        end_epoch: inst["end_epoch"].as_u64().unwrap(),
        duration_epochs: inst["duration_epochs"].as_u64(),
      }
    })
    .collect()
}
