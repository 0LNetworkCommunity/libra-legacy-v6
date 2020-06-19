script {
use 0x0::Redeem;
fun main(challenge: vector<u8>, difficulty: u64, solution: vector<u8>) {

    let proof = Redeem::create_proof_blob(challenge, difficulty, solution);
    Redeem::begin_redeem(proof);

}
}