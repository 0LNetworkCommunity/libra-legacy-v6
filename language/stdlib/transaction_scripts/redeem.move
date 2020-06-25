script {
use 0x0::Redeem;
use 0x0::Debug;
fun main(challenge: vector<u8>, difficulty: u64, solution: vector<u8>) {

    Debug::print(&b"Parameters for Redeem Transaction:");
    Debug::print(&challenge);
    Debug::print(&difficulty);
    Debug::print(&solution);

    let proof = Redeem::create_proof_blob(challenge, difficulty, solution);
    Redeem::begin_redeem(proof);

}
}