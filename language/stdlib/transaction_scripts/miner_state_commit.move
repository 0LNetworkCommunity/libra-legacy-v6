
// Transaction script which miners use to submit proofs.
script {
use 0x1::MinerState;
use 0x1::Globals;
fun minerstate_commit(sender: &signer, challenge: vector<u8>, solution: vector<u8>) {

    
    let proof = MinerState::create_proof_blob(
      challenge,
      Globals::get_difficulty(),
      solution
    );

    MinerState::commit_state(sender, proof);

}
}
