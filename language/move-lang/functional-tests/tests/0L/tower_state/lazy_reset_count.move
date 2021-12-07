//! account: dummy-prevents-genesis-reload, 100000 ,0, validator
//! account: alice, 10000000GAS

// Alice Submit VDF Proof
//! new-transaction
//! sender: alice
script {
    use 0x1::TowerState;
    use 0x1::TestFixtures;
    use 0x1::DiemConfig;
    use 0x1::Debug::print;

    // SIMULATES A MINER ONBOARDING PROOF (proof_0.json)
    fun main(sender: signer) {
      print(&DiemConfig::get_current_epoch());

        TowerState::init_miner_state(
            &sender,
            &TestFixtures::alice_0_easy_chal(),
            &TestFixtures::alice_0_easy_sol(),
            TestFixtures::easy_difficulty(),
            TestFixtures::security(),
        );

        assert(TowerState::test_helper_get_height(@{{alice}}) == 0, 10008001);
        assert(TowerState::get_epochs_compliant(@{{alice}}) == 0, 735701);

        // initialization created one proof.
        // With Lazy computation, is number will not change on the next epochboundary.
        // if will only change after the next mining proof is submitted.
        assert(TowerState::get_count_in_epoch(@{{alice}}) == 1, 735702);

    }
}
// check: EXECUTED


//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//! block-prologue
//! proposer: dummy-prevents-genesis-reload
//! block-time: 61000000
//! round: 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////


//! new-transaction
//! sender: diemroot
script {
    use 0x1::DiemConfig;
    use 0x1::TowerState;
    use 0x1::Debug::print;

    // SIMULATES THE SECOND PROOF OF THE MINER (proof_1.json)
    fun main(_: signer) {
      // EpochBoundary::reconfigure(&vm, 100);
      print(&DiemConfig::get_current_epoch());
      print(&TowerState::get_count_in_epoch(@{{alice}}));
    
      // Lazy would mean no change from before epoch boundary
      assert(TowerState::get_count_in_epoch(@{{alice}}) == 1, 735703);

    }
}



// //! new-transaction
// //! sender: alice
// script {
//     use 0x1::TowerState;
//     use 0x1::TestFixtures;

//     // SIMULATES THE SECOND PROOF OF THE MINER (proof_1.json)
//     fun main(sender: signer) {
//         assert(TowerState::test_helper_get_height(@{{alice}}) == 0, 10008001);
//         let height_after = 1;
        
//         let proof = TowerState::create_proof_blob(
//             TestFixtures::alice_1_easy_chal(),
//             TestFixtures::alice_1_easy_sol(),
//             TestFixtures::easy_difficulty(),
//             TestFixtures::security(),
//         );
//         TowerState::commit_state(&sender, proof);

//         let verified_height = TowerState::test_helper_get_height(@{{alice}});
//         assert(verified_height == height_after, 10008002);
//     }
// }
// // check: EXECUTED


