// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

use diem_transaction_builder::stdlib::{
  self as transaction_builder, 
  encode_add_validator_and_reconfigure_script_function, 
  encode_create_validator_account_script_function, 
  encode_ol_reconfig_bulk_update_setup_script_function, 
  encode_peer_to_peer_with_metadata_script_function, 
  encode_register_validator_config_script_function,
  encode_create_validator_operator_account_script_function,
  encode_set_validator_operator_script_function,
};
use diem_types::{
  vm_status::KeptVMStatus,
  account_config::{gas_type_tag, from_currency_code_string},
};
use language_e2e_tests::{
  account::{Account, AccountData, AccountRoleSpecifier},
  executor::FakeExecutor,
  ol_oracle_setup::{oracle_helper_tx, upgrade_foo_tx},
};
use ol_types::fixtures;

pub const GAS_NAME: &str = "GAS";

fn set_up_validators(
  executor : &mut FakeExecutor, 
  diem_root: Account, 
) -> Vec<Account> {
    let mut sequence_number = 1u64;
  // creates five validator accounts
  let mut validators = vec![];
  for _i in 0..5 {
      validators.push(Account::new());
  }
  println!("created new validator accounts");

  // Register account data for diem root
  let diem_root_data = AccountData::with_account(
      diem_root, 1_000_000_000_000,
      from_currency_code_string(GAS_NAME).unwrap(), 
      sequence_number, 
      AccountRoleSpecifier::DiemRoot
  );
  executor.add_account_data(&diem_root_data);

  let names = vec!["alice", "bob", "carol", "sha", "ram"];
  // Create a transaction allowing the accounts to serve as validators
  for i in 0..5 {
      executor.execute_and_apply(
          diem_root_data.account().transaction()
              .payload(encode_create_validator_account_script_function(
                  sequence_number,
                  *validators.get(i).unwrap().address(),
                  validators.get(i).unwrap().auth_key_prefix(),
                  (**names.get(i).unwrap()).to_string().into_bytes(),
              ))
              .sequence_number(sequence_number)
              .sign(),
      );
      sequence_number+=1;
  }
  println!("registered new validator accounts");
  executor.new_block();
  
  //////////////////////////////////////////////////////////////////////////////////////////////
  // Transfer the validators some money
  let mint_amount = 1_000_000_000;
  for i in 0..5 {
      executor.execute_and_apply(
          diem_root_data.account().transaction()
              .payload(encode_peer_to_peer_with_metadata_script_function(
                  gas_type_tag(),
                  *validators.get(i).unwrap().address(),
                  mint_amount,
                  vec![],
                  vec![],
              ))
              .sequence_number(sequence_number)
              .sign(),
      );
      sequence_number+=1;      
  }
  println!("minted tokens for validators");
  executor.new_block();

  // Add operator
  let operator_account = executor.create_raw_account();
  
  executor.execute_and_apply(
      diem_root_data.account()
          .transaction()
          .payload(encode_create_validator_operator_account_script_function(
              sequence_number,
              *operator_account.address(),
              operator_account.auth_key_prefix(),
              b"operator".to_vec(),
          ))
          .sequence_number(sequence_number)
          .sign(),
  );
  sequence_number += 1;
  println!("created operator account");

  for i in 0..5 {
      // validators set operator
      executor.execute_and_apply(
          validators.get(i).unwrap()
              .transaction()
              .payload(encode_set_validator_operator_script_function(
                  b"operator".to_vec(),
                  *operator_account.address(),
              ))
              .sequence_number(0)
              .sign(),
      );
  }
  println!("validators set their operator account");

  executor.new_block();

  //////////////////////////////////////////////////////////////////////////////////////////////
  // register validator config
  for i in 0..5 {
      executor.execute_and_apply(
          operator_account
              .transaction()
              .payload(encode_register_validator_config_script_function(
                  *validators.get(i).unwrap().address(),
                  [
                      0xd7, 0x5a, 0x98, 0x01, 0x82, 0xb1, 0x0a, 0xb7, 0xd5, 0x4b, 0xfe, 0xd3, 0xc9,
                      0x64, 0x07, 0x3a, 0x0e, 0xe1, 0x72, 0xf3, 0xda, 0xa6, 0x23, 0x25, 0xaf, 0x02,
                      0x1a, 0x68, 0xf7, 0x07, 0x51, 0x1a,
                  ]
                  .to_vec(),
                  vec![254; 32],
                  vec![253; 32],
              ))
              .sequence_number(i as u64)
              .sign(),
      );
  }
  println!("registered validator configs");

  //////////////////////////////////////////////////////////////////////////////////////////////
  // Actually register the accounts as validators
  for i in 0..5 {
      executor.execute_and_apply(
          diem_root_data.account()
              .transaction()
              .payload(encode_add_validator_and_reconfigure_script_function(
                  sequence_number,
                  (**names.get(i).unwrap()).to_string().into_bytes(),
                  *validators.get(i).unwrap().address(),
              ))
              .sequence_number(sequence_number)
              .sign(),
      );
      sequence_number+=1;
  }
  println!("registered and reconfigured validators");

  executor.new_block();

  let payload = transaction_builder::encode_minerstate_helper_script_function();
  for i in 0..5 {
    executor.execute_and_apply(
        validators.get(i).unwrap()
            .transaction()
            .payload(payload.clone())
            .sequence_number(1)
            .sign(),
    );
  }
  println!("minerstate_helper_script executed successfully");

    // Fixture data for the VDF proof, using easy/test difficulty
    // This assumes that it is a proof_1.json a SUBSEQUENT proof, to an already committed genesis proof.
    // This test uses Alice's block_1 proof (../fixtures/proof_1.json.stage.alice), assuming she has participated in a genesis ceremony.

    let block = fixtures::get_persona_block_one("alice", "test");
    let payload = transaction_builder::encode_minerstate_commit_script_function(
        block.preimage,
        block.proof,
        block.difficulty.unwrap(),
        block.security.unwrap().into(),
    );


  for i in 0..5 {
    executor.execute_and_apply(
        validators.get(i).unwrap()
            .transaction()
            .payload(payload.clone())
            .sequence_number(2)
            .sign(),
    );
  }
  println!("minerstate_commit executed successfully");

  //////////////////////////////////////////////////////////////////////////////////////////////
  // Construct the signed tx script for test setup.
  let output = executor.execute_and_apply(
    diem_root_data.account()
        .transaction()
        .payload(encode_ol_reconfig_bulk_update_setup_script_function(
            *validators.get(0).unwrap().address(),
            *validators.get(1).unwrap().address(),
            *validators.get(2).unwrap().address(),
            *validators.get(3).unwrap().address(),
            *validators.get(4).unwrap().address(),
        ))
        .sequence_number(sequence_number)
        .sign(),
);

  // Assert success
  assert_eq!(output.status().status(), Ok(KeptVMStatus::Executed));
  
  println!("validator setup successful");

  validators
}

// hardcoding a sender with seq_num = 1
fn test_foo (sender: &Account, executor: &mut FakeExecutor, should_pass: bool) {
  // NOTE: See documentation here: ol/documentation/devs/e2e_upgrade_test.md

  // Construct a valid and signed tx script.
  let txn = upgrade_foo_tx(sender, 3);

  // Force the test runner to create a new block before running the test.
  executor.new_custom_block(2);
  
  let output = &executor.execute_transaction(txn);
  if should_pass {
      assert_eq!(
          output.status().status(),
          Ok(KeptVMStatus::Executed)
      );
  } else {
      assert_eq!(
          output.status().status(),
          Ok(KeptVMStatus::MiscellaneousError)
      );
  };
}

#[test]
fn test_no_quorum_on_upgrade_tx() {
  // Run with: `/language/e2e_testsuite/ cargo t test_single_oracle_tx -- --nocapture`
  let mut executor = FakeExecutor::from_genesis_file();

  // create an association account and validator accounts
  let diem_root = Account::new_diem_root();
  let accounts = set_up_validators(&mut executor, diem_root);

  // Construct a valid and signed tx script.
  let txn = oracle_helper_tx(&accounts.get(0).unwrap(), 3);

  // Force the test runner to create a new block before running the test.
  executor.new_custom_block(2);
  
  // Execute and persist the transaction
  let output = executor.execute_and_apply(txn);

  assert_eq!(
    output.status().status(),
    Ok(KeptVMStatus::Executed)
  );

  // verify that the foo transaction should fail
  test_foo(&accounts.get(1).unwrap(), &mut executor, false);
}

#[test]
fn test_successful_upgrade_txs() {
  let mut executor = FakeExecutor::from_genesis_file();

  dbg!(&"1");
  // create an association account and validator accounts
  let diem_root = Account::new_diem_root();
  let accounts = set_up_validators(&mut executor, diem_root);

  executor.new_custom_block(2);
dbg!(&"2");
  // Construct a valid and signed tx script.
  let txn_0 = oracle_helper_tx(&accounts.get(0).unwrap(), 3);
  let output = executor.execute_and_apply(txn_0);
  assert_eq!(
    output.status().status(),
    Ok(KeptVMStatus::Executed)
  );
dbg!(&"3");
  executor.new_custom_block(2);
  let txn_1 = oracle_helper_tx(&accounts.get(1).unwrap(), 3);
  let output = executor.execute_and_apply(txn_1);
  assert_eq!(
    output.status().status(),
    Ok(KeptVMStatus::Executed)
  );
dbg!(&"4");

  executor.new_custom_block(2);
  let txn_2 = oracle_helper_tx(&accounts.get(2).unwrap(), 3);
  let output = executor.execute_and_apply(txn_2);
  dbg!(&"5");

  assert_eq!(
    output.status().status(),
    Ok(KeptVMStatus::Executed)
  );
  

  // verify that the foo transaction should fail w/o the updated stdlib
  test_foo(&accounts.get(3).unwrap(), &mut executor, false);
dbg!(&"6");

  // The creation of these blocks update the stdlib
  executor.new_custom_block(2);
dbg!(&"7");

  executor.new_custom_block(2);
dbg!(&"8");

  // verify that the foo transaction should pass with the updated stdlib
  test_foo(&accounts.get(4).unwrap(), &mut executor, true);
dbg!(&"9");

  // Checks update doesn't happen again
  executor.new_custom_block(2);
dbg!(&"9");

}