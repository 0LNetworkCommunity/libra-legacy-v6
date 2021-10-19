//! account: dummy-prevents-genesis-reload, 100000 ,0, validator

// Prepare the state for the next test.
// Bob Submits a CORRECT VDF Proof, and that updates the state.
//! account: alice, 10000000GAS
//! account: bob, 10000000GAS
//! new-transaction
//! sender: bob
script {
    use 0x1::TowerState;
    use 0x1::TestFixtures;

    fun main(sender: signer) {
        // Testing that state can be initialized, and a proof submitted as if it were genesis.
        // buildign block for other tests.
        let difficulty = 100;
        let security = 2048;
        TowerState::test_helper_init_miner(
            &sender,
            TestFixtures::easy_chal(),
            TestFixtures::easy_sol(),
            difficulty,
            security,
        );

        let height = TowerState::test_helper_get_height(@{{bob}});
        assert(height==0, 01);
    }
}
// check: EXECUTED