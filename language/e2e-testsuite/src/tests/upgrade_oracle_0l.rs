// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

use language_e2e_tests::{
  account::{Account, AccountData, AccountRoleSpecifier},
  executor::FakeExecutor,
  oracle_setup::{oracle_helper_tx, upgrade_foo_tx},
};
use libra_types::{
  vm_status::KeptVMStatus,
  account_config::{lbr_type_tag, from_currency_code_string},
};
use transaction_builder::*;
pub const LBR_NAME: &str = "GAS";

fn set_up_validators(
  executor : &mut FakeExecutor, 
  libra_root: Account, 
) -> Vec<Account> {
    let mut sequence_number = 1u64;
  // creates five validator accounts
  let mut accounts = vec![];
  for _i in 0..5 {
      accounts.push(Account::new());
  }
  println!("created new validator accounts");

  // Register account data for libra root
  let libra_root_data = AccountData::with_account(
      libra_root, 1_000_000_000_000,
      from_currency_code_string(LBR_NAME).unwrap(), sequence_number, AccountRoleSpecifier::LibraRoot);
  executor.add_account_data(&libra_root_data);

  let names = vec!["alice", "bob", "carol", "sha", "ram"];
  // Create a transaction allowing the accounts to serve as validators
  for i in 0..5 {
      executor.execute_and_apply(
          libra_root_data.account().transaction()
              .script(encode_create_validator_account_script(
                  sequence_number,
                  *accounts.get(i).unwrap().address(),
                  accounts.get(i).unwrap().auth_key_prefix(),
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
          libra_root_data.account().transaction()
              .script(encode_peer_to_peer_with_metadata_script(
                  lbr_type_tag(),
                  *accounts.get(i).unwrap().address(),
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

  //////////////////////////////////////////////////////////////////////////////////////////////
  // register validator config
  for i in 0..5 {
      executor.execute_and_apply(
          accounts.get(i).unwrap()
              .transaction()
              .script(encode_register_validator_config_script(
                  *accounts.get(i).unwrap().address(),
                  [
                      0xd7, 0x5a, 0x98, 0x01, 0x82, 0xb1, 0x0a, 0xb7, 0xd5, 0x4b, 0xfe, 0xd3, 0xc9,
                      0x64, 0x07, 0x3a, 0x0e, 0xe1, 0x72, 0xf3, 0xda, 0xa6, 0x23, 0x25, 0xaf, 0x02,
                      0x1a, 0x68, 0xf7, 0x07, 0x51, 0x1a,
                  ]
                  .to_vec(),
                  vec![254; 32],
                  vec![253; 32],
              ))
              .sequence_number(0)
              .sign(),
      );
  }
  println!("registered validators");
  executor.new_block();

  //////////////////////////////////////////////////////////////////////////////////////////////
  // Actually register the accounts as validators
  for i in 0..5 {
      executor.execute_and_apply(
          libra_root_data.account()
              .transaction()
              .script(encode_add_validator_and_reconfigure_script(
                  sequence_number,
                  (**names.get(i).unwrap()).to_string().into_bytes(),
                  *accounts.get(i).unwrap().address(),
              ))
              .sequence_number(sequence_number)
              .sign(),
      );
      sequence_number+=1;
  }
  println!("registered and reconfiged validators");
  executor.new_block();

  //////////////////////////////////////////////////////////////////////////////////////////////
  // borrowed from minerstate commit test, register the minerstate for the new validators

  // This test uses Alice's block_1 proof (../fixtures/block_1.json.stage.alice), assuming she has participated in a genesis ceremony.
  let preimage = hex::decode("c3de80a6d29ee233e8d12ff2bf65c67d0306ea16b46720dfa0829fa85e900701").unwrap();
  let proof = hex::decode("003b75d7f51101287bf2d6ac7ac8d1169a0e89f4bc5cebe36c612c6e6aab557ca2083cdf477f856657e62a6a1e2e26ed40521198e74cb7babeeb86e94ea1dd03388d3c9296a9cd073389fe09331ac59d085bfb78b5e52fc20d4df27f8f63853dd4ecfeee230e9aa4615433f8fcb783dd03d689c284575cf082a1783e99a44379de002ff2ea1f1e8915dc6b631ba6ce102542632df5f91320f4bc95e786e0d7c08d727245597da98d1b363750483897e859396b40b0b2a54a000a10a4000ddea250f667f8a782aa26bbc7490deb6efcf2af36749d55118e4122d904fc928f1fd256ea744316169b4f01c06094c133088b12e5f5fd692dce51124f3cab2206bda00355000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001").unwrap();

  let script_help = transaction_builder::encode_minerstate_helper_script();
  for i in 0..5 {
    executor.execute_and_apply(
        accounts.get(i).unwrap()
            .transaction()
            .script(script_help.clone())
            .sequence_number(1)
            .sign(),
    );
  }
  println!("minerstate_helper_script executed successfully");

  let script = transaction_builder::encode_minerstate_commit_script(
      preimage,
      proof,
  );

  for i in 0..5 {
    executor.execute_and_apply(
        accounts.get(i).unwrap()
            .transaction()
            .script(script.clone())
            .sequence_number(2)
            .sign(),
    );
  }
  println!("minerstate_commit executed successfully");

  //////////////////////////////////////////////////////////////////////////////////////////////
  // Construct the signed tx script for test setup.
  let output = executor.execute_and_apply(
    libra_root_data.account()
        .transaction()
        .script(encode_ol_reconfig_bulk_update_setup_script(
            *accounts.get(0).unwrap().address(),
            *accounts.get(1).unwrap().address(),
            *accounts.get(2).unwrap().address(),
            *accounts.get(3).unwrap().address(),
            *accounts.get(4).unwrap().address(),
        ))
        .sequence_number(sequence_number)
        .sign(),
);

  // Assert success
  assert_eq!(output.status().status(), Ok(KeptVMStatus::Executed));

  accounts
}

// hardcoding a sender with seq_num = 1
fn test_foo (sender: &Account, executor: &mut FakeExecutor, should_pass: bool) {
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
fn test_single_oracle_tx() {
  // Run with: `cargo xtest -p language-e2e-tests test_single_oracle_tx -- --nocapture`
  let mut executor = FakeExecutor::from_genesis_file();

  // create an association account and validator accounts
  let libra_root = Account::new_libra_root();
  let accounts = set_up_validators(&mut executor, libra_root);

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
fn test_validators_oracle_tx() {
  let mut executor = FakeExecutor::from_genesis_file();

  // create an association account and validator accounts
  let libra_root = Account::new_libra_root();
  let accounts = set_up_validators(&mut executor, libra_root);

  executor.new_custom_block(2);

  // Construct a valid and signed tx script.
  let txn_0 = oracle_helper_tx(&accounts.get(0).unwrap(), 3);
  let output = executor.execute_and_apply(txn_0);
  assert_eq!(
    output.status().status(),
    Ok(KeptVMStatus::Executed)
  );

  executor.new_custom_block(2);
  let txn_1 = oracle_helper_tx(&accounts.get(1).unwrap(), 3);
  let output = executor.execute_and_apply(txn_1);
  assert_eq!(
    output.status().status(),
    Ok(KeptVMStatus::Executed)
  );

  executor.new_custom_block(2);
  let txn_2 = oracle_helper_tx(&accounts.get(2).unwrap(), 3);
  let output = executor.execute_and_apply(txn_2);
  assert_eq!(
    output.status().status(),
    Ok(KeptVMStatus::Executed)
  );
  

  // verify that the foo transaction should fail
  test_foo(&accounts.get(3).unwrap(), &mut executor, false);

  // The creation of these blocks update the stdlib
  executor.new_custom_block(2);
  executor.new_custom_block(2);

  // verify that the foo transaction should pass with the updated stdlib
  test_foo(&accounts.get(4).unwrap(), &mut executor, true);

  // Checks update doesn't happen again
  executor.new_custom_block(2);
}
