script {
use 0x0::Redeem;
use 0x0::Debug;
fun main(sender: &signer, challenge: vector<u8>, difficulty: u64, solution: vector<u8>, tower_height: u64) {

    Debug::print(&b"Parameters for Redeem Transaction:");
    Debug::print(&challenge);
    Debug::print(&difficulty);
    Debug::print(&solution);
    Debug::print(&tower_height);


    let proof = Redeem::create_proof_blob(challenge, difficulty, solution, tower_height);
    Redeem::begin_redeem(sender, proof);

}
}
