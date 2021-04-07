
// Transaction script which miners use to submit proofs.
script {
use 0x1::MinerState;
use 0x1::Globals;
fun minerstate_commit_by_operator(operator_sig: &signer, owner_address: address, challenge: vector<u8>, solution: vector<u8>) {

    
    let proof = MinerState::create_proof_blob(
      challenge,
      Globals::get_difficulty(),
      solution
    );

    
    MinerState::commit_state_by_operator(operator_sig, owner_address, proof);

}
}
