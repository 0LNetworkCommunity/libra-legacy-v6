//! account: dummy-prevents-genesis-reload, 100000 ,0, validator

// Alice Submit VDF Proof
//! new-transaction
//! account: alice, 10000000GAS
//! sender: alice
script {
use 0x1::MinerState;
use 0x1::Debug::print;

fun main(sender: &signer) {

    MinerState::init_miner_state(sender);
    print(&MinerState::test_helper_get_height({{alice}}));

}
}
// check: EXECUTED


