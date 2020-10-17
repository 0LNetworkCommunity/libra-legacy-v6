// Transaction script which miners use to submit proofs.
script {
use 0x1::MinerState;
// use 0x0::Debug;
fun ol_miner_state(sender: &signer, challenge: vector<u8>,
  difficulty: u64, solution: vector<u8>, _tower_height: u64) {
    //
    // Debug::print(&b"Parameters for MinerState Transaction:");
    // Debug::print(&challenge);
    // Debug::print(&difficulty);
    // Debug::print(&solution);
    // Debug::print(&tower_height);

    let proof = MinerState::create_proof_blob(challenge, difficulty, solution);
    MinerState::commit_state(sender, proof);

}
}
