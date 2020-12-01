//! account: bob, 100000, 0, validator

//! new-transaction
//! sender: bob
script {
  use 
  fun main(sender: &signer) {
    // let new_op_account = create_signer(new_account_address);
    Roles::new_validator_operator_role_with_proof(&new_op_account);
    Event::publish_generator(&new_account);
    ValidatorOperatorConfig::publish_with_proof(&new_account, human_name);
    add_currencies_for_account<GAS>(&new_account, false);
    make_account(new_account, auth_key_prefix);
  }
}