// Transaction script which miners use to submit proofs.
script {
use 0x0::MinerState;
// use 0x0::Debug;
fun main(sender: &signer, challenge: vector<u8>,
  difficulty: u64, solution: vector<u8>) {

    let proof = MinerState::create_proof_blob(challenge, difficulty, solution);
    MinerState::commit_state(sender, proof);

}
}
