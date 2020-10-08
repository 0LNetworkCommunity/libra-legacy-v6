
// Transaction script which miners use to submit proofs.
script {
use 0x0::MinerState;
use 0x0::Globals;
fun main(sender: &signer, challenge: vector<u8>, solution: vector<u8>) {

    
    let proof = MinerState::create_proof_blob(
      challenge,
      Globals::get_difficulty(),
      solution
    );

    MinerState::commit_state(sender, proof);

}
}
