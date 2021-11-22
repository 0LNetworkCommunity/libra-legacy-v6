//! account: alice, 1000000, 0, validator

// check the thresholds for counting mining proofs toward delegation.
// Mock some mining data

//! new-transaction
//! sender: alice
script {
    use 0x1::TowerState;
    use 0x1::Signer;
    // use 0x1::Debug::print;

    fun main(sender: signer) {
        TowerState::test_helper_mock_mining(&sender, 500);
        let addr = Signer::address_of(&sender);
        let h = TowerState::tower_for_teams(addr);
        assert(h == 500, 735701);
        // print(&h);
    }
}
//check: EXECUTED

