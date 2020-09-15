// Transaction script FOR ONBOARDING. Assumes tower-height 0, and that the challenge has a public key which will be turned into an auth_key and subsequently an address.
// The same algortihm for generating account addresses is available offline. This transaction confirms the address.
script {
use 0x0::MinerState;
use 0x0::LibraAccount;
use 0x0::GAS;
use 0x0::Transaction;
use 0x0::VDF;
fun main(
  sender: &signer,
  challenge: vector<u8>,
  difficulty: u64,
  solution: vector<u8>,
  _expected_address: address // TODO: add this to doubly check the user knows his address.
) {
    // Parse key and check
    let (parsed_address, auth_key_prefix) = VDF::extract_address_from_challenge(&challenge);
    // TODO: uncomment the following line to ensure that user knows his address
    // Transaction::assert(_expected_address == parsed_address);
    LibraAccount::create_validator_account_from_mining_0L<GAS::T>(sender, parsed_address, auth_key_prefix);
    // Check the account exists and the balance is 0
    Transaction::assert(LibraAccount::balance<GAS::T>(parsed_address) == 0, 12);

    // submit vdf proof blob.
    // the sender is not the miner in this case.
    let proof = MinerState::create_proof_blob(challenge, difficulty, solution, 0);
    MinerState::commit_state(sender, proof);

}
}
