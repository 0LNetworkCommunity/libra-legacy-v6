//! `autopay`

use anyhow::Error;
use diem_types::{
    account_address::AccountAddress,
    transaction::{Script, TransactionArgument},
};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::{
    fs::{self, File},
    io::Write,
    path::PathBuf,
    process::exit,
    u64,
};

#[cfg(test)]
use crate::fixtures;

// These match Autpay2.move
/// send percent of balance at end of epoch payment type
const PERCENT_OF_BALANCE: u8 = 0;
/// send percent of the change in balance since the last tick payment type
const PERCENT_OF_CHANGE: u8 = 1;
/// send a certain amount each tick until end_epoch is reached payment type
const FIXED_RECURRING: u8 = 2;
/// send a certain amount once at the next tick payment type
const FIXED_ONCE: u8 = 3;

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
/// Types of instructions for autopay
pub enum InstructionType {
    /// balance
    PercentOfBalance,
    /// inflow
    PercentOfChange,
    /// fixed recurring
    FixedRecurring,
    /// fixed one time payment
    FixedOnce,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
// #[serde(deny_unknown_fields)]
/// Autopay payment instruction
pub struct PayInstruction {
    /// unique id of instruction
    pub uid: Option<u64>,
    /// description of payment, not sent to chain
    pub note: Option<String>,
    /// enum for type of instruction
    pub type_of: InstructionType,
    /// type of instruction
    pub type_move: Option<u8>,
    /// value cast for move
    pub value: f64,
    /// value cast for move
    pub value_move: Option<u64>,
    /// destination account
    pub destination: AccountAddress,
    /// epoch when payment instruction will stop
    pub end_epoch: Option<u64>,
    /// optional duration in epochs of the instruction
    pub duration_epochs: Option<u64>,
}

impl PayInstruction {
    /// extract autopay instructions from json file
    pub fn parse_autopay_instructions(
        autopay_batch_file: &PathBuf,
        current_epoch: Option<u64>,
        start_uid: Option<u64>,
    ) -> Result<Vec<PayInstruction>, Error> {
        let file = fs::File::open(autopay_batch_file).expect(&format!(
            "cannot open autopay batch file: {:?}",
            autopay_batch_file
        ));
        let json: Value = serde_json::from_reader(&file).expect("cannot parse autopay.json");
        let val: Value = json.get("autopay_instructions").unwrap().to_owned();
        let inst_vec: Vec<PayInstruction> = serde_json::from_value(val).unwrap();

        let mut total_pct_of_change: f64 = 0f64;
        let mut total_pct_balance: f64 = 0f64;
        // let mut ids: Vec<u64> = vec!();
        let new_uid = start_uid.unwrap_or(0) + 1;
        let transformed = inst_vec
            .into_iter()
            .enumerate()
            .map(|(i, mut inst)| {
                inst.uid = Some(new_uid + i as u64);

                if inst.end_epoch.is_none()
                && inst.duration_epochs.is_none() {

                if inst.type_of != InstructionType::FixedOnce {
                      println!(
                          "Need to set end_epoch, or duration_epoch in instruction: {:?}",
                          &inst
                      );
                      exit(1);
                  } else {
                    inst.duration_epochs = Some(1);
                  }
                }

                if let Some(duration) = inst.duration_epochs {
                    if duration == 0 {
                      println!("Duration cannot be 0. Instruction: {:?}", &inst);
                      exit(1);
                    }
                    if let Some(current) = current_epoch {
                      inst.end_epoch = Some(duration + current);
                    } else {
                      println!("If you are setting a duration_epochs instruction, we need the current epoch. Instruction: {:?}", &inst);
                      exit(1);
                    }
                } else {

                }

                match inst.type_of {
                    InstructionType::PercentOfBalance => {
                        inst.type_move = Some(PERCENT_OF_BALANCE);
                        inst.value_move = scale_percent(inst.value);
                        total_pct_balance = total_pct_balance + inst.value;
                    }
                    InstructionType::PercentOfChange => {
                        inst.type_move = Some(PERCENT_OF_CHANGE);
                        inst.value_move = scale_percent(inst.value);
                        total_pct_of_change = total_pct_of_change + inst.value;
                    }
                    InstructionType::FixedRecurring => {
                        inst.type_move = Some(FIXED_RECURRING);
                        inst.value_move = scale_coin(inst.value);
                    }
                    InstructionType::FixedOnce => {
                        inst.type_move = Some(FIXED_ONCE);
                        inst.value_move = scale_coin(inst.value);
                        // TODO: temporary patch to duration bug  https://github.com/OLSF/libra/pull/556
                        inst.duration_epochs = Some(2);
                    }
                }

                inst
            })
            .collect();

        if (total_pct_of_change < 100f64) && (total_pct_balance < 100f64) {
            Ok(transformed)
        } else {
            Err(Error::msg("Aborting, percentages sum greater than 100%"))
        }
    }

    /// checks ths instruction against the raw script for correctness.
    pub fn check_instruction_match_tx(&self, script: Script) -> Result<(), Error> {
        let PayInstruction {
            uid,
            type_move,
            value_move,
            destination,
            end_epoch,
            ..
        } = *self;

        assert!(
            script.args()[0] == TransactionArgument::U64(uid.unwrap()),
            "not same unique id"
        );
        assert!(
            script.args()[1] == TransactionArgument::U8(type_move.unwrap()),
            "not sending expected type of transaction"
        );
        assert!(
            script.args()[2] == TransactionArgument::Address(destination),
            "not sending to expected destination"
        );
        assert!(
            script.args()[3] == TransactionArgument::U64(end_epoch.unwrap()),
            "not the same ending epoch"
        );
        assert!(
            script.args()[4]
                == TransactionArgument::U64(value_move.expect("cannot get value_move")),
            "not the same value being sent"
        );
        Ok(())
    }

    /// provide text information on the instruction
    pub fn text_instruction(&self) -> String {
        let times = match &self.duration_epochs {
            Some(d) => format!("{} times", d),
            None => "".to_owned(),
        };
        match self.type_of {
            InstructionType::PercentOfBalance => {
                format!(
            "Instruction {uid}: {note}\nSends {percent_balance:.2?}% of total balance every day {times} (until epoch {epoch_ending}) to address: {destination}?",
            uid = &self.uid.unwrap(),
            percent_balance = *&self.value_move.unwrap() as f64 /100f64,
            times = times,
            note = &self.note.clone().unwrap(),
            epoch_ending = &self.end_epoch.unwrap(),
            destination = &self.destination,
          )
            }
            InstructionType::PercentOfChange => {
                format!(
              "Instruction {uid}: {note}\nSends {percent_balance:.2?}% of new incoming funds every day {times} (until epoch {epoch_ending}) to address: {destination}?",
              uid = &self.uid.unwrap(),
              percent_balance = *&self.value_move.unwrap() as f64 /100f64,
              times = times,
              note = &self.note.clone().unwrap(),
              epoch_ending = &self.end_epoch.unwrap(),
              destination = &self.destination,
            )
            }
            InstructionType::FixedRecurring => {
                format!(
                "Instruction {uid}: {note}\nSend {total_val} every day {times} (until epoch {epoch_ending}) to address: {destination}?",
                uid = &self.uid.unwrap(),
                total_val = *&self.value_move.unwrap() / 1_000_000, // scaling factor
                times = times,
                note = &self.note.clone().unwrap(),
                epoch_ending = &self.end_epoch.unwrap(),
                destination = &self.destination,
            )
            }
            InstructionType::FixedOnce => {
                format!(
                    "Instruction {uid}: {note}\nSend {total_val} once to address: {destination}?",
                    uid = &self.uid.unwrap(),
                    note = &self.note.clone().unwrap(),
                    total_val = *&self.value_move.unwrap() / 1_000_000, // scaling factor
                    destination = &self.destination,
                )
            }
        }
    }
}

/// save a batch file of instructions
pub fn write_batch_file(file_path: PathBuf, vec_instr: Vec<PayInstruction>) -> Result<(), Error> {
    #[derive(Clone, Debug, Deserialize, Serialize)]
    struct Batch {
        autopay_instructions: Vec<PayInstruction>,
    }
    let mut buffer = File::create(file_path)?;
    // let data = serde_json::to_string(&vec_instr)?;

    let data = serde_json::to_string(&Batch {
        autopay_instructions: vec_instr,
    })?;

    buffer.write(data.as_bytes())?;
    Ok(())
}

// convert the decimals for Move.
// for autopay purposes percentages have two decimal places precision.
// No rounding is applied. The third decimal is trucated.
// the result is a integer of 4 bits.
fn scale_coin(coin_value: f64) -> Option<u64> {
    // the UI for the autopay_batch, allows 2 decimal precision for pecentages: 12.34%
    // multiply by 100 to get the desired decimal precision
    let scale = coin_value * 1000000 as f64;
    Some(scale as u64)
}

fn scale_percent(fract_percent: f64) -> Option<u64> {
    // the UI for the autopay_batch, allows 2 decimal precision for pecentages: 12.34%
    // multiply by 100 to get the desired decimal precision
    let scaled = fract_percent * 100 as f64;
    // drop the fractional part with trunc()
    let trunc = scaled.trunc() as u64; // return max 4 digits.
    if trunc < 9999 {
        Some(trunc)
    } else {
        println!("percent needs to have max four digits, skipping");
        None
    }
}

#[test]
fn parse_file() {
    let path = fixtures::get_demo_autopay_json().1;
    PayInstruction::parse_autopay_instructions(&path, Some(0), None).unwrap();
}

#[test]
fn parse_pct_balance_type() {
    let path = fixtures::get_demo_autopay_json().1;
    let inst = PayInstruction::parse_autopay_instructions(&path, Some(0), None).unwrap();
    let first = &inst[0];

    assert_eq!(first.uid, Some(1));
    assert_eq!(
        first.destination,
        "88E74DFED34420F2AD8032148280A84B"
            .parse::<AccountAddress>()
            .unwrap()
    );
    assert_eq!(first.type_move, Some(0));
    assert_eq!(first.duration_epochs, Some(100));
    assert_eq!(first.end_epoch, Some(100));
    assert_eq!(first.type_of, InstructionType::PercentOfBalance);
    assert_eq!(first.value, 10f64);
}

#[test]
fn parse_pct_change_type() {
    let path = fixtures::get_demo_autopay_json().1;
    let inst = PayInstruction::parse_autopay_instructions(&path, Some(0), None).unwrap();
    let second = &inst[1];

    assert_eq!(second.uid, Some(2));
    assert_eq!(
        second.destination,
        "88E74DFED34420F2AD8032148280A84B"
            .parse::<AccountAddress>()
            .unwrap()
    );
    assert_eq!(second.type_move, Some(1));
    assert_eq!(second.duration_epochs, Some(100));
    assert_eq!(second.end_epoch, Some(100));
    assert_eq!(second.type_of, InstructionType::PercentOfChange);
    assert_eq!(second.value, 12.34f64);
    assert_eq!(second.value_move, Some(1234u64));
}

#[test]
fn parse_fixed_recurr_type() {
    let path = fixtures::get_demo_autopay_json().1;
    let inst = PayInstruction::parse_autopay_instructions(&path, Some(0), None).unwrap();
    let third = &inst[2];

    assert_eq!(third.uid, Some(3));
    assert_eq!(
        third.destination,
        "88E74DFED34420F2AD8032148280A84B"
            .parse::<AccountAddress>()
            .unwrap()
    );
    assert_eq!(third.type_move, Some(2));
    assert_eq!(third.duration_epochs, Some(100));
    assert_eq!(third.end_epoch, Some(100));
    assert_eq!(third.type_of, InstructionType::FixedRecurring);
    assert_eq!(third.value_move.unwrap(), 5000000u64);
}

#[test]
fn parse_fixed_once_type() {
    let path = fixtures::get_demo_autopay_json().1;
    let inst = PayInstruction::parse_autopay_instructions(&path, Some(0), None).unwrap();
    let fourth = &inst[3];

    assert_eq!(fourth.uid, Some(4));
    assert_eq!(
        fourth.destination,
        "88E74DFED34420F2AD8032148280A84B"
            .parse::<AccountAddress>()
            .unwrap()
    );
    assert_eq!(fourth.type_move, Some(3));
    assert_eq!(fourth.duration_epochs, Some(2)); // TODO: This is temporary patch for v4.3.2
    assert_eq!(fourth.end_epoch, Some(1));
    assert_eq!(fourth.type_of, InstructionType::FixedOnce);
    assert_eq!(fourth.value_move.unwrap(), 22000000u64);
}

#[test]
fn parse_pct_balance_end_epoch_type() {
    let path = fixtures::get_demo_autopay_json().1;
    let inst = PayInstruction::parse_autopay_instructions(&path, Some(0), None).unwrap();
    let fifth = &inst[4];

    assert_eq!(fifth.uid, Some(5));
    assert_eq!(
        fifth.destination,
        "88E74DFED34420F2AD8032148280A84B"
            .parse::<AccountAddress>()
            .unwrap()
    );
    assert_eq!(fifth.type_move, Some(0));
    assert_eq!(fifth.duration_epochs, None);
    assert_eq!(fifth.end_epoch, Some(50));
    assert_eq!(fifth.type_of, InstructionType::PercentOfBalance);
    assert_eq!(fifth.value, 10f64);
}

#[test]
fn parse_pct_change_end_epoch_type() {
    let path = fixtures::get_demo_autopay_json().1;
    let inst = PayInstruction::parse_autopay_instructions(&path, Some(0), None).unwrap();
    let sixth = &inst[5];

    assert_eq!(sixth.uid, Some(6));
    assert_eq!(
        sixth.destination,
        "88E74DFED34420F2AD8032148280A84B"
            .parse::<AccountAddress>()
            .unwrap()
    );
    assert_eq!(sixth.type_move, Some(1));
    assert_eq!(sixth.duration_epochs, None);
    assert_eq!(sixth.end_epoch, Some(50));
    assert_eq!(sixth.type_of, InstructionType::PercentOfChange);
    assert_eq!(sixth.value, 12.34f64);
    assert_eq!(sixth.value_move.unwrap(), 1234u64);
}

#[test]
fn parse_fixed_recurr_end_epoch_type() {
    let path = fixtures::get_demo_autopay_json().1;
    let inst = PayInstruction::parse_autopay_instructions(&path, Some(0), None).unwrap();
    let seventh = &inst[6];

    assert_eq!(seventh.uid, Some(7));
    assert_eq!(
        seventh.destination,
        "88E74DFED34420F2AD8032148280A84B"
            .parse::<AccountAddress>()
            .unwrap()
    );
    assert_eq!(seventh.type_move, Some(2));
    assert_eq!(seventh.duration_epochs, None);
    assert_eq!(seventh.end_epoch, Some(50));
    assert_eq!(seventh.type_of, InstructionType::FixedRecurring);
    assert_eq!(seventh.value, 5f64);
    assert_eq!(seventh.value_move.unwrap(), 5000000u64);
}
