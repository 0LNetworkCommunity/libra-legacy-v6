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
  let preimage = hex::decode("a3964fe3be43749e77b87f30d38cb8b18b689c7e4008ddcf3543af06f2ef2cd0").unwrap();
  let proof = hex::decode("001ad2af3d252dd7a54aec500cb51c151eed01e27dd3f8aa7021568abdc0d7600f24f516ba02a034dd1cabc6da747017c7e673d46e5347d6389c09967a7be719e818f454a2c2d9347b49394ab5efec2365d428bf97a5156f698ee019edd2a8483b4c2c839e831f9a5ac8d059a48c807d561fe893b5181c9ffa34e7bd4acdb60f09a3178a20f3f95c735bb47bfcdc1e9f05a4e16e1912de56f8aa97d4501c6dd8214cf6c3e716da7cae5874e8deb18546da3e653ef0337f25c2b329fcb69a181fa2ee5cac249d2c363f6e2da083bd1bb3d447a338cfaae0da8b30a57f749ed95ce57b5f2cc4426ecc5ed3e850a5947e1d6eddc72c863ce9183bfafe22a2399c2e6800088044be8bf013bcc072f25358db9ce770df965916db04799e957a1789bb7f8f6cdf5603228452cc872aaa601a5e769c88f750ab211758ab8051dcf012b65bfaaf1b40f01969dea081e198f984f2452a705dd98a66893b23fc3a4d15e60c158e63f4286f9b137dd48cf000dbb9b85f2f52405874f909bbc620882cfb8884743cd5bdfbf027acdabc4ec342b33e4ab01c8b4ab9b6a58cdc9aac6a515f251e0b6021ac150fe17be67f89e1779f91f4625e8e28e4975b42a9179e9fe2dc07feb5ad57c16bbb0886c70f7d298feb170705499b64fdeba3307e187b56776f3281e970993dbfcdca7ef0a58a3ddb8f58ed0c095f8b1f433191a2b75b278f8f4f7b161500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001").unwrap();

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
