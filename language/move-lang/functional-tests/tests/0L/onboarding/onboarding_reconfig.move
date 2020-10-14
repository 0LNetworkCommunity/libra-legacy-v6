// Module to test bulk validator updates function in LibraSystem.move
//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: carol, 1000000, 0, validator
//! account: dave, 1000000, 0, validator
//! account: eve, 1000000, 0, validator


//! new-transaction
//! sender: association
script {
  use 0x0::Transaction::assert;
  use 0x0::LibraAccount;
  use 0x0::GAS;
  use 0x0::ValidatorConfig;
  use 0x0::TestFixtures;
  use 0x0::VDF;
  // use 0x0::Debug::print;

  fun main(_account: &signer) {
    let challenge = TestFixtures::alice_1_easy_chal();
    let solution = TestFixtures::alice_1_easy_sol();
    let (parsed_address, _auth_key_prefix) = VDF::extract_address_from_challenge(&challenge);    

    LibraAccount::create_validator_account_with_vdf<GAS::T>(
      &challenge,
      &solution,
      x"deadbeef", // consensus_pubkey: vector<u8>,
      x"20d1ac", //validator_network_identity_pubkey: vector<u8>,
      b"192.168.0.1", //validator_network_address: vector<u8>,
      x"1ee7", //full_node_network_identity_pubkey: vector<u8>,
      b"192.168.0.1", //full_node_network_address: vector<u8>,
    );

    // Check the account has the Validator role
    assert(LibraAccount::is_certified<LibraAccount::ValidatorRole>(parsed_address), 02);

    assert(ValidatorConfig::is_valid(parsed_address), 03);

    // Check the account exists and the balance is 0
    assert(LibraAccount::balance<GAS::T>(parsed_address) == 0, 04);
  }
}
//check: EXECUTED

//! block-prologue
//! proposer: alice
//! block-time: 1

//! new-transaction
//! sender: association
script {
    use 0x0::Transaction;
    use 0x0::LibraSystem;
    fun main(_account: &signer) {
        // Tests on initial size of validators 
        Transaction::assert(LibraSystem::validator_set_size() == 5, 7357000180101);
        Transaction::assert(LibraSystem::is_validator({{alice}}) == true, 7357000180102);
        Transaction::assert(LibraSystem::is_validator({{bob}}) == true, 7357000180103);
    }
}
// check: EXECUTED

//! block-prologue
//! proposer: alice
//! block-time: 2

//! block-prologue
//! proposer: alice
//! block-time: 3

//! block-prologue
//! proposer: alice
//! block-time: 4

//! block-prologue
//! proposer: alice
//! block-time: 5

//! block-prologue
//! proposer: alice
//! block-time: 6

//! block-prologue
//! proposer: alice
//! block-time: 7

//! block-prologue
//! proposer: alice
//! block-time: 8

//! block-prologue
//! proposer: alice
//! block-time: 9

//! block-prologue
//! proposer: alice
//! block-time: 10

//! block-prologue
//! proposer: alice
//! block-time: 11

//! block-prologue
//! proposer: alice
//! block-time: 12

//! block-prologue
//! proposer: alice
//! block-time: 13

//! block-prologue
//! proposer: alice
//! block-time: 14

//! new-transaction
//! sender: association
script {
    use 0x0::Vector;
    use 0x0::Stats;
    // This is the the epoch boundary.
    fun main() {
        let voters = Vector::empty<address>();
        Vector::push_back<address>(&mut voters, {{alice}});
        Vector::push_back<address>(&mut voters, {{bob}});
        Vector::push_back<address>(&mut voters, {{carol}});
        Vector::push_back<address>(&mut voters, {{dave}});
        Vector::push_back<address>(&mut voters, {{eve}});

        // Overwrite the statistics to mock that all have been validating.
        let i = 1;
        while (i < 16) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(&voters);
            i = i + 1;
        };
    }
}
//! block-prologue
//! proposer: alice
//! block-time: 15
//! round: 15