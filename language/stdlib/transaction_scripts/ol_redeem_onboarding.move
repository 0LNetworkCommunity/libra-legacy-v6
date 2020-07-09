// Transaction script FOR ONBOARDING. Assumes tower-height 0, and that the challenge has a public key which will be turned into an auth_key and subsequently an address.
// The same algortihm for generating account addresses is available offline. This transaction confirms the address.
script {
use 0x0::Redeem;
use 0x0::Debug;
fun main(
  sender: &signer,
  challenge: vector<u8>,
  difficulty: u64,
  solution: vector<u8>,
  tower_height: u64,
  expected_address: address
) {

    Debug::print(&challenge);
    Debug::print(&difficulty);
    Debug::print(&solution);
    // Debug::print(&_miner_address);

    // GOAL: it would be ideal that these accounts could be created by any Alice, for any Bob, i.e.
    // if it didn't need to be the association or system account.

    // Parse key and check
    Redeem::first_challenge_includes_address(expected_address, challenge);
    //create an account if it doesn't yet exist.
    let proof = Redeem::create_proof_blob(challenge, difficulty, solution, tower_height);

    LibraAccount::create_validator_account_from_mining_0L<GAS::T>(sender, new_account_address, auth_key_prefix);
    // Check the account exists and the balance is 0
    Transaction::assert(LibraAccount::balance<GAS::T>(0xDEADBEEF) == 0, 0);

    // submit vdf proof blob.
    // the sender is not the miner in this case.
    Redeem::begin_redeem(sender, proof);

}
}
