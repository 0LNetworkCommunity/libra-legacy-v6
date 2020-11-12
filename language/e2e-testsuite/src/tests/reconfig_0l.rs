// Copyright (c) 0lsf
// SPDX-License-Identifier: Apache-2.0

use language_e2e_tests::{
  account::{Account, AccountData, AccountRoleSpecifier},
  executor::FakeExecutor,
};
use libra_types::{
  account_config::from_currency_code_string,
  vm_status::KeptVMStatus,
};
use transaction_builder::*;
pub const LBR_NAME: &str = "GAS";

#[test]
fn reconfig_bulk_update_test () {
  // Run with: `cargo xtest -p language-e2e-testsuite reconfig_bulk_update_test -- --nocapture`
  let mut executor = FakeExecutor::from_genesis_file();
  let mut sequence_number = 1u64;

  // NOTE: While true that the VM will initialize with some validators, this 
  // test involving checking the size and members of the validator set in move.
  // So, even though there are some validators already created, this test is 
  // run with five new validators.

  // Create some accounts to be able to call a tx script and be validators
  let libra_root = Account::new_libra_root();
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
  let preimage = hex::decode("7ccfbe11759c6a348a09ebac903c312628cf89a971e73f1e0563930ab9271c69").unwrap();
  let proof = hex::decode("006408be2b99428c65d7a431a5e7a9e1657de1e8aae012274c43a744e3038a54a64cce4be427b64518b105f469d6c76eb7be7b2ee64acf5a786f2f2e7b7a3191f1c9ee0409a5780dfe9d979b48497abeab80cf985019363f83357ea64e57de3eb7c61411ea08467306ba7551317c871c8677e3af96d30fb1c33ffd5ce764e3dae4004c6930ef09561130b563b61cac4eb148a06c6d114a7531390edab64dbefeff99fd759ed32b0730a9a2a94fcb0032fc7740bab401a9af78f520150785d5093d38a020d330e875876d60e3aeaad7d10026a4a5fcc66553530b2ae6026c3ed8f3ff727cee3c0d2e96303594aa7a22df71cb8ac361ae687cc77ebae18e1b315a6e5d0001186b2b957c219389f3c4f7f3175332a0b3433ebff2f42a22d2a27b7615721d29ccded6a1a48171cb75b389cbbd5c1185d516e55578a3d0c343e643110eae5bfb244b783bc2ef394352f9c0d340df1397e594a553de0b4ae155eb1a0121ff9928f2318fa622bba08b9f9f21cc4294d58a70b5dd53b834b83fcc2f77d2729f03000001f0c19f6ee6000f09b39da694c6e1dd55bc365e298ec15fd863288565c8b0f06634d728b3e74443b5f365a3c14280795d41c921acbd67f25ee993d8fe2359545ef40191a193c2ff37df709a312573c904722753757cbbfc7b6f3c0cbfc7a21bcf72cec4bfccf640d4d93d1e4ceb54561e95b2cfaa4d964b32c7050ae097cb").unwrap();

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
}
