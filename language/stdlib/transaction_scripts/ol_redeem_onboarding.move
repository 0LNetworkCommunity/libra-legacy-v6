// Transaction script FOR ONBOARDING. Assumes tower-height 0, and that the challenge has a public key which will be turned into an auth_key and subsequently an address.
// The same algortihm for generating account addresses is available offline. This transaction confirms the address.
script {
use 0x0::Redeem;
use 0x0::Debug;
use 0x0::LibraAccount;
use 0x0::GAS;
use 0x0::Transaction;
fun main(
  sender: &signer,
  challenge: vector<u8>,
  difficulty: u64,
  solution: vector<u8>,
  // expected_address: address TODO: add this to doubly check the user knows his address.
) {

    Debug::print(&challenge);
    Debug::print(&difficulty);
    Debug::print(&solution);
    // Debug::print(&_miner_address);

    // GOAL: it would be ideal that these accounts could be created by any Alice, for any Bob, i.e.
    // if it didn't need to be the association or system account.

    // Parse key and check

    let (parsed_address, auth_key_prefix) = Redeem::address_from_challenge(&challenge);
    // TODO: Check parsed_address matches expected_address
    // Debug::print(&expected_address);
    LibraAccount::create_validator_account_from_mining_0L<GAS::T>(sender, parsed_address, auth_key_prefix);
    // Check the account exists and the balance is 0
    Transaction::assert(LibraAccount::balance<GAS::T>(parsed_address) == 0, 0);

    // submit vdf proof blob.
    // the sender is not the miner in this case.
    let proof = Redeem::create_proof_blob(challenge, difficulty, solution, 0);
    Redeem::begin_redeem(sender, proof);

}
}
