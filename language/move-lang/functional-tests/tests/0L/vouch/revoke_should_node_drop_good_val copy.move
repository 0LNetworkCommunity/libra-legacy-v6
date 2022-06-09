// This tests consensus Case 1.
// ALICE is a validator.
// DID validate successfully.
// DID mine above the threshold for the epoch.

//! account: alice, 1000000GAS, 0, validator
//! account: bob, 1000000GAS, 0, validator
//! account: carol, 1000000GAS, 0, validator
//! account: dave, 1000000GAS, 0, validator
//! account: eve, 1000000GAS, 0, validator

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
    use 0x1::Debug::print;

    fun main(sender: signer) {
        // Tests on initial size of validators
        assert(DiemSystem::validator_set_size() == 5, 7357300101011000);
        assert(DiemSystem::is_validator(@{{alice}}) == true, 7357300101021000);
        assert(DiemSystem::is_validator(@{{eve}}) == true, 7357300101031000);

        assert(TowerState::get_count_in_epoch(@{{alice}}) == 0, 7357300101041000);
        assert(DiemAccount::balance<GAS>(@{{alice}}) == 1000000, 7357300101051000);
        assert(NodeWeight::proof_of_weight(@{{alice}}) == 0, 7357300101051000);

        // Alice continues to mine after genesis.
        // This test is adapted from chained_from_genesis.move
        TowerState::test_helper_mock_mining(&sender, 5);
        let a = TowerState::get_epochs_compliant(@{{alice}});
        print(&a);

        assert(TowerState::get_count_in_epoch(@{{alice}}) == 5, 7357300101071000);
        assert(TowerState::node_above_thresh(@{{alice}}), 7357300101081000);

    }
}
// check: EXECUTED


//! new-transaction
//! sender: diemroot
script {
    use 0x1::Vector;
    use 0x1::Stats;

    // This is the the epoch boundary.
    fun main(vm: signer) {
        // This is not an onboarding case, steady state.
        // FullnodeState::test_set_fullnode_fixtures(
        //     &vm, @{{alice}}, 0, 0, 0, 200, 200, 1000000
        // );

        let voters = Vector::empty<address>();
        Vector::push_back<address>(&mut voters, @{{alice}});
        Vector::push_back<address>(&mut voters, @{{bob}});
        Vector::push_back<address>(&mut voters, @{{carol}});
        Vector::push_back<address>(&mut voters, @{{dave}});
        Vector::push_back<address>(&mut voters, @{{eve}});

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

//! new-transaction
//! sender: diemroot
script {
    use 0x1::Cases;
    use 0x1::Vector;
    use 0x1::DiemSystem;
    
    fun main(vm: signer) {
        // We are in a new epoch.
        // Check alice is in the the correct case during reconfigure
        assert(Cases::get_case(&vm, @{{alice}}, 0, 15) == 1, 735700018010901);
        assert(Cases::get_case(&vm, @{{bob}}, 0, 15) == 2, 735700018010902);
        assert(Cases::get_case(&vm, @{{carol}}, 0, 15) == 2, 735700018010903);
        assert(Cases::get_case(&vm, @{{dave}}, 0, 15) == 2, 735700018010904);
        assert(Cases::get_case(&vm, @{{eve}}, 0, 15) == 2, 735700018010905);

        // check only 1 val is getting the subsidy
        let (vals, _) = DiemSystem::get_fee_ratio(&vm, 0, 100);
        assert(Vector::length<address>(&vals) == 1, 7357000180111);

    }
}

//! new-transaction
//! sender: bob
script {
    use 0x1::Vouch;
    
    fun main(sender: signer) {
      Vouch::revoke(&sender, @{{alice}});
    }
}


//! new-transaction
//! sender: carol
script {
    use 0x1::Vouch;
    
    fun main(sender: signer) {
      Vouch::revoke(&sender, @{{alice}});
    }
}

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
    use 0x1::NodeWeight;
    use 0x1::GAS::GAS;
    use 0x1::DiemAccount;
    use 0x1::Subsidy;
    use 0x1::Globals;
    use 0x1::TowerState;
    use 0x1::DiemSystem;

    use 0x1::Debug::print;
    fun main(_vm: signer) {
        // We are in a new epoch.
        assert(DiemSystem::is_validator(@{{alice}}) == true, 7357300101021000);

        let expected_subsidy = Subsidy::subsidy_curve(
          Globals::get_subsidy_ceiling_gas(),
          1,
          Globals::get_max_validators_per_set(),
        );

        let starting_balance = 1000000;

        let operator_refund = 4336 * 5; // BASELINE_TX_COST * proofs = 21680
        
        // Note since there's only 1 validator and the reward to alice was the entirety of subsidy available.
        let burn = expected_subsidy/2; // 50% of the rewrd to validator. 


        let ending_balance = starting_balance + expected_subsidy - operator_refund - burn;
        print(&ending_balance);
        print(&DiemAccount::balance<GAS>(@{{alice}}));

        assert(DiemAccount::balance<GAS>(@{{alice}}) == ending_balance, 7357000180113);  
        assert(NodeWeight::proof_of_weight(@{{alice}}) == 5, 7357000180114);

        // Case 1, increments the epochs_validating_and_mining, which is used for rate-limiting onboarding
        assert(TowerState::get_epochs_compliant(@{{alice}}) == 1, 7357000180115);  

    }
}
//check: EXECUTED