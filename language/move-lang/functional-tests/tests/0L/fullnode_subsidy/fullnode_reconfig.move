//! account: alice, 1000000GAS, 0, validator
//! account: bob, 1000000GAS, 0


// Bob is an end-user running th Carpe app, and submitting miner proofs.
// He is the only one in the epoch submitting proofs. He should get the entirety of the Identity Subsidy pool avaialable (one validator's worth)

//  0. Initialize Bob's miner state with a first proof

//! new-transaction
//! sender: bob
script {
    use 0x1::TowerState;
    use 0x1::TestFixtures;

    fun main(sender: signer) {
        TowerState::test_helper_init_miner(
            &sender,
            TestFixtures::easy_chal(),
            TestFixtures::easy_sol(),
            TestFixtures::easy_difficulty(),
            TestFixtures::security(),
        );
    }
}


// 2. Make sure there are validator subsidies available.
// so we need Alice to be a Case 1 validator so that there is a subsidy to be paid to validator set.

//! block-prologue
//! proposer: alice
//! block-time: 1
//! NewBlockEvent
//! new-transaction
//! sender: alice
script {
    use 0x1::DiemSystem;
    use 0x1::TowerState;
    use 0x1::NodeWeight;
    use 0x1::GAS::GAS;
    use 0x1::DiemAccount;

    fun main(sender: signer) {
        // Tests on initial size of validators
        // assert(DiemSystem::validator_set_size() == 5, 7357300101011000);
        assert(DiemSystem::is_validator(@{{alice}}) == true, 735701);

        assert(TowerState::get_count_in_epoch(@{{alice}}) == 1, 735702);
        assert(DiemAccount::balance<GAS>(@{{alice}}) == 1000000, 735703);
        assert(NodeWeight::proof_of_weight(@{{alice}}) == 0, 735704);

        // Alice continues to mine after genesis.
        // This test is adapted from chained_from_genesis.move
        // NOTE: these proofs do not count to fullnode proofs in epoch since Alice is a validator
        TowerState::test_helper_mock_mining(&sender, 5);
        assert(TowerState::get_count_in_epoch(@{{alice}}) == 5, 735705);

    }
}
// check: EXECUTED

// 3. continue mocking Alice as a compliant validator

//! new-transaction
//! sender: diemroot
script {
    use 0x1::Vector;
    use 0x1::Stats;

    fun main(vm: signer) {
        let voters = Vector::empty<address>();
        Vector::push_back<address>(&mut voters, @{{alice}});

        // Overwrite the statistics to mock that all have been validating.
        let i = 1;
        while (i < 16) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(&vm, &voters);
            i = i + 1;
        };
    }
}
//check: EXECUTED


// 4. Mock Bob (the end-user) submitting proofs above threshold.

//! new-transaction
//! sender: bob
script {
    use 0x1::DiemSystem;
    use 0x1::TowerState;
    use 0x1::Debug::print;
    use 0x1::GAS::GAS;
    use 0x1::DiemAccount;


    fun main(sender: signer) {
        // confirm bob is not a validator
        assert(DiemSystem::is_validator(@{{alice}}), 735706);
        assert(!DiemSystem::is_validator(@{{bob}}), 735707);
        // bring bob to 10 proofs. (Note: alice has one proof as a fullnode from genesis, so it will total 11 fullnode proofs.);

        print(&TowerState::get_fullnode_proofs_in_epoch());
        print(&TowerState::get_fullnode_proofs_in_epoch_above_thresh());

        // both Alice and Bob have a fullnode proof (Alice has one from Genesis)
        assert(TowerState::get_fullnode_proofs_in_epoch() == 2, 735708);
        // there should be no proofs above threshold at this point.
        assert(TowerState::get_fullnode_proofs_in_epoch_above_thresh() == 0, 735709);

        TowerState::test_helper_mock_mining(&sender, 10);

        // Since the threshold in test suite is 1 proof, all the 10 are counted above threshold.
        assert(TowerState::get_fullnode_proofs_in_epoch_above_thresh() == 10, 735710);

        print(&DiemAccount::balance<GAS>(@{{bob}}));
        print(&DiemAccount::balance<GAS>(@{{alice}}));

        
    }
}
// check: EXECUTED


//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 61000000
//! round: 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//! new-transaction
//! sender: diemroot
script {  
    use 0x1::GAS::GAS;
    use 0x1::DiemAccount;
    use 0x1::Subsidy;
    use 0x1::Globals;
    use 0x1::Debug::print;

    fun main(_vm: signer) {
        // We are in a new epoch.

        // we expect that Bob receives the share that one validator would get.
        let expected_subsidy = Subsidy::subsidy_curve(
          Globals::get_subsidy_ceiling_gas(),
          1, // alice is the only validator (but below 4 the reward is the same in testnet: 296000000)
          Globals::get_max_validators_per_set(),
        );

        let bob_starting_balance = 1000000;

        print(&expected_subsidy);

        let ending_balance = bob_starting_balance + expected_subsidy;

        print(&DiemAccount::balance<GAS>(@{{bob}}));
        print(&DiemAccount::balance<GAS>(@{{alice}}));

        // bob gets the whole subsidy
        assert(DiemAccount::balance<GAS>(@{{bob}}) == ending_balance, 735711);  
    }
}
//check: EXECUTED