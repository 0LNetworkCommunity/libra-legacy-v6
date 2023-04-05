//# init --validators Alice

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::ValidatorConfig;
  use DiemFramework::ValidatorUniverse;

  fun main(_vm: signer, _alice: signer) {
    // TODO: issue with using ValidatorConfig::is_valid at genesis.
    // aka before this transaction.
    
    ValidatorUniverse::is_in_universe(@Alice);
    ValidatorConfig::is_valid(@Alice);
  }
}