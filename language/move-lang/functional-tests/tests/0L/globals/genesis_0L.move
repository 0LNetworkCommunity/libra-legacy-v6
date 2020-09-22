//! account: alice, 100000,0, validator
//! new-transaction
//! sender: association
script {
// use 0x0::Globals;
// use 0x0::Debug;
use 0x0::Transaction;
use 0x0::LibraSystem;
use 0x0::MinerState;
use 0x0::Vector;


    fun main(_sender: &signer) {
        Transaction::assert(LibraSystem::is_validator({{alice}}) == true, 98);

        let verified_proof_history = MinerState::get_miner_state({{alice}});
        // should be atleast 1 at genesis, and never more than 1.
        let proof_len = Vector::length<vector<u8>>(&verified_proof_history);
        // Debug::print(&proof_len);
        Transaction::assert(proof_len == 1u64, 73570002);
    }
}
// check: EXECUTED
