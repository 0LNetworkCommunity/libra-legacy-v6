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
  // _miner_address: vector<u8>
) {

    Debug::print(&challenge);
    Debug::print(&difficulty);
    Debug::print(&solution);
    // Debug::print(&_miner_address);

    let proof = Redeem::create_proof_blob(challenge, difficulty, solution, tower_height);
    Redeem::begin_redeem(sender, proof);

}
}
