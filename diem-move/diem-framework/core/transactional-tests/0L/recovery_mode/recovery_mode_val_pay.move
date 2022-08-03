//# init --validators Alice Bob Carol Dave Eve

// This tests consensus Case 1.
// ALICE is a validator.
// DID validate successfully.
// DID mine above the threshold for the epoch.

//# block --proposer Alice --time 1 --round 0

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::RecoveryMode;
    use Std::Vector;

    fun main(vm: signer, _: signer){
      RecoveryMode::test_init_recovery(&vm, Vector::empty<address>(), 2);
      assert!(RecoveryMode::is_recovery(), 7357001);
    }
}

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::TowerState;
    use DiemFramework::NodeWeight;
    use DiemFramework::GAS::GAS;
    use DiemFramework::DiemAccount;
    use DiemFramework::Debug::print;

    fun main(_: signer, sender: signer) {
        // Tests on initial size of validators
        assert!(DiemSystem::validator_set_size() == 5, 7357300101011000);
        assert!(DiemSystem::is_validator(@Alice) == true, 7357300101021000);
        assert!(DiemSystem::is_validator(@Eve) == true, 7357300101031000);

        assert!(TowerState::get_count_in_epoch(@Alice) == 0, 7357300101041000);
        assert!(DiemAccount::balance<GAS>(@Alice) == 1000000, 7357300101051000);
        assert!(NodeWeight::proof_of_weight(@Alice) == 0, 7357300101051000);

        // Alice continues to mine after genesis.
        // This test is adapted from chained_from_genesis.move
        TowerState::test_helper_mock_mining(&sender, 5);
        let a = TowerState::get_epochs_compliant(@Alice);
        print(&a);

        assert!(TowerState::get_count_in_epoch(@Alice) == 5, 7357300101071000);
        assert!(TowerState::node_above_thresh(@Alice), 7357300101081000);

    }
}

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use Std::Vector;
    use DiemFramework::Stats;

    // This is the the epoch boundary.
    fun main(vm: signer, _: signer) {
        // This is not an onboarding case, steady state.
        // FullnodeState::test_set_fullnode_fixtures(
        //     &vm, @Alice, 0, 0, 0, 200, 200, 1000000
        // );

        let voters = Vector::empty<address>();
        Vector::push_back<address>(&mut voters, @Alice);
        Vector::push_back<address>(&mut voters, @Bob);
        Vector::push_back<address>(&mut voters, @Carol);
        Vector::push_back<address>(&mut voters, @Dave);
        Vector::push_back<address>(&mut voters, @Eve);

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

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::Cases;
    use Std::Vector;
    use DiemFramework::DiemSystem;
    
    fun main(vm: signer, _: signer) {
        // We are in a new epoch.
        // Check alice is in the the correct case during reconfigure
        assert!(Cases::get_case(&vm, @Alice, 0, 15) == 1, 735700018010901);
        assert!(Cases::get_case(&vm, @Bob, 0, 15) == 2, 735700018010902);
        assert!(Cases::get_case(&vm, @Carol, 0, 15) == 2, 735700018010903);
        assert!(Cases::get_case(&vm, @Dave, 0, 15) == 2, 735700018010904);
        assert!(Cases::get_case(&vm, @Eve, 0, 15) == 2, 735700018010905);

        // check only 1 val is getting the subsidy
        let (vals, _) = DiemSystem::get_fee_ratio(&vm, 0, 100);
        assert!(Vector::length<address>(&vals) == 1, 7357000180111);

    }
}

//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//# block --proposer Alice --time 61000000 --round 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//# run --admin-script --signers DiemRoot DiemRoot
script {  
    use DiemFramework::GAS::GAS;
    use DiemFramework::DiemAccount;
    use DiemFramework::Subsidy;
    use DiemFramework::Globals;
    use DiemFramework::Debug::print;

    fun main() {
        // We are in a new epoch.

        let expected_subsidy = Subsidy::subsidy_curve(
          Globals::get_subsidy_ceiling_gas(),
          1,
          Globals::get_max_validators_per_set(),
        );

        let starting_balance = 1000000;

        let operator_refund = 4336 * 5; // BASELINE_TX_COST * proofs = 21680
        
        // Note since there's only 1 validator and the reward to alice was
        // the entirety of subsidy available.
        let burn = expected_subsidy/2; // 50% of the rewrd to validator. 


        let usual_ending_balance 
            = starting_balance + expected_subsidy - operator_refund - burn;

        // let recovery_ending_balance = starting_balance - operator_refund - burn;

        // print(&ending_balance);
        print(&DiemAccount::balance<GAS>(@Alice));

        //////// RESCUE MODE SHOULD NOT PAY EXPECTED AMOUNT //////////////
        assert!(DiemAccount::balance<GAS>(@Alice) != usual_ending_balance, 7357000180113);

        // the operator_refund and burn depleted the account, and there was no new reward.
        assert!(DiemAccount::balance<GAS>(@Alice) == 0, 7357000180114);
    }
}