//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0
//! account: eve, 1000000, 0

// NOTE: alice is validator, she will become a tribal elder.
// then Bob will join her tribe.


//! block-prologue
//! proposer: alice
//! block-time: 1

//! new-transaction
//! sender: diemroot
script {
  
  use 0x1::Teams;
  use 0x1::EpochBoundary;

  fun main(vm: signer) {
    // nothing is initialized yet
    assert(!Teams::vm_is_init(), 735701);
    assert(!Teams::team_is_init(@{{alice}}), 735702);
    EpochBoundary::reconfigure(&vm, 0);
  }
}
// check: EXECUTED


// now that the vm has been initialized for delegation. Initialize an elder.

//! new-transaction
//! sender: alice
script {
  
  use 0x1::Teams;

  fun main(alice: signer) {
    // nothing is initialized yet

    let team_name = b"for the win";
    Teams::team_init(&alice, team_name, 10); // 10% operator reward.

    assert(Teams::team_is_init(@{{alice}}), 735703);
    assert(Teams::get_operator_reward(@{{alice}}) == 10, 735704);

    
  }
}
// check: EXECUTED


//! new-transaction
//! sender: bob
script {
  
  use 0x1::Teams;
  use 0x1::DiemAccount;
  use 0x1::Vector;
  use 0x1::Debug::print;
  use 0x1::TowerState;
  use 0x1::TestFixtures;

  fun main(bob: signer) {
    DiemAccount::set_slow(&bob);
    Teams::join_team(&bob, @{{alice}}); // alice's account is the ID of the team 

    // Bob is not a member of the team until he mines enough proofs in an epoch.
    let members = Teams::get_team_members(@{{alice}});
    print(&members);
    assert(Vector::length<address>(&members) == 0, 735705);


    // new epoch, Bob mined above the threshold and is activated to team.
    TowerState::test_helper_init_val(
        &bob,
        TestFixtures::easy_chal(),
        TestFixtures::easy_sol(),
        TestFixtures::easy_difficulty(),
        TestFixtures::security(),
    );
    TowerState::test_helper_mock_mining(&bob, 5);
    Teams::maybe_activate_member_to_team(&bob);

    let members = Teams::get_team_members(@{{alice}});
    print(&members);
    assert(Vector::length<address>(&members) == 1, 735706);



  }
}
// check: EXECUTED


// //! new-transaction
// //! sender: eve
// script {
  
//   use 0x1::Teams;
//   use 0x1::DiemAccount;
//   use 0x1::Vector;
//   use 0x1::Debug::print;

//   fun main(eve: signer) {
//     DiemAccount::set_slow(&eve);
//     Teams::join_team(&eve, @{{alice}}); // alice's account is the ID of the team 
//     assert(Teams::member_is_init(&eve), 735706);



//     let members = Teams::get_team_members(@{{alice}});
//     print(&members);
//     assert(Vector::length<address>(&members) == 2, 735707);
//   }
// }
// // check: EXECUTED