//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: carol, 1000000, 0, validator
//! account: dave, 1000000, 0, validator
//! account: eve, 1000000, 0, validator
//! account: frank, 1000000, 0, validator
//! account: gene, 1000000, 0, validator


//! block-prologue
//! proposer: alice
//! block-time: 1

//! new-transaction
//! sender: association
script {
  use 0x0::Transaction;
  use 0x0::Subsidy;
  use 0x0::Vector;
  use 0x0::Stats;
  use 0x0::LibraAccount;
  use 0x0::GAS;

  fun main(vm: &signer) {
    // check the case of a network density of 4 active validators.

    let validators = Vector::singleton<address>({{alice}});
    Vector::push_back(&mut validators, {{bob}});
    Vector::push_back(&mut validators, {{carol}});
    Vector::push_back(&mut validators, {{dave}});

    // create mock validator stats for full epoch
    let i = 0;
    while (i < 16) {
      Stats::process_set_votes(&validators);
      i = i + 1;
    };

    LibraAccount::mint_to_address<GAS::T>(vm, 0xFEE, 100);

    Transaction::assert(Subsidy::calculate_Subsidy() == 196, 7357190101021000);

    }
}
// check: EXECUTED
