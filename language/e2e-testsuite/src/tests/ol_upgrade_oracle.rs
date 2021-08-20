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

  //////////////////////////////////////////////////////////////////////////////////////////////
  // borrowed from minerstate commit test, register the minerstate for the new validators

  // This test uses Alice's block_1 proof (../fixtures/block_1.json.stage.alice), 
  // assuming she has participated in a genesis ceremony.

  // TODO: Get this directly from the fixtues library.
  
  let preimage = hex::decode(
      "3190cef88aa2fb86fbfa062f62be33d08d1493e982597d7be286ab5b6d01e4b0"
  ).unwrap();
  let proof = hex::decode(
    "006e33a9542693512b59aa04081bb2a87f0bf07328c62cfc5dafdebf57c35ddd6a75664ddfa7ebfe0b9cbc6c5d19f03f77841cef9923d32bea8a4a642adfd94a31d2b523cb32e8adc27ee63ec2d793f3c224c0be2c4258dcb7ba5b74ee78d21f1d045165c9bd7e41a42085ea4cdb95fb8ffd437448ad93610d4d445f339807fffbffb3a77ab38d67e301889a7d83a789895fa5a12113213b4674ec4dbd6037bcd7c9e8c5edb6f7bf738e19845aa25c0cd3cf258f978c406195c2a8d7edf8785d1697653d213add8cb632680f167dbb1a6a4716a2b174a91c5319c9b5224504975e94e7b751b55bad30b27678fa9c46d94d02f5bf757d27305b1283c542ca02927427000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"
  ).unwrap();

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

  let payload = transaction_builder::encode_minerstate_commit_script_function(
      preimage,
      proof,
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
  // This tests if the new Stdlib includes a function Upgrade::foo(). This is a dummy function.
  // if the function is not found, that means the upgrade did not take place.
  // The fixtures for creating this test are complex. We need:
  // 1. A "proposed" stdlib compile
  // 2. The tx scripts to call the ::foo() function

  // 1. First there needs to be a "proposed" new Stdlib compile.
  // To create the compile, the Upgrade.move file, needs to contain the ::foo() function.
  // for convenience we keep an Upgrade.move.e2e file, which can be used in an alternate build of the stdlib.mv. This happens rarely, so the dev should just rename the files (removeing the .e2e), and build the stdlib.
  // The Stdlib compile should be placed in ol/fixtures/upgrade
  // 2. The tx scripts which are used by client or SDK are used only for testing purposes.
  // these do not need to change, and can be found alongside other tx scripts.

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

  // create an association account and validator accounts
  let diem_root = Account::new_diem_root();
  let accounts = set_up_validators(&mut executor, diem_root);

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
