//! account: alice, 1000000GAS, 0, validator
//! account: bob, 1000000GAS, 0

//! new-transaction
//! sender: diemroot
script {
    use 0x1::Teams;
    use 0x1::MigrateInitDelegation;

    fun main(vm: signer) {
      MigrateInitDelegation::do_it(&vm);
      Teams::test_helper_set_thresh(&vm, 10);
      let t = Teams::get_member_thresh();
      assert(t == 10, 735701);

      // bob has not joined any team
      assert(!Teams::member_is_init(@{{bob}}), 735702);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: alice
//! args: b"for the win", 10
stdlib_script::TeamsScripts::create_team
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: bob
script {
    use 0x1::Teams;
    use 0x1::TowerState;
    use 0x1::TestFixtures;
    use 0x1::DiemAccount;
    // use 0x1::Vector;

    fun main(sender: signer) {
      TowerState::test_helper_init_val(
          &sender,
          TestFixtures::easy_chal(),
          TestFixtures::easy_sol(),
          TestFixtures::easy_difficulty(),
          TestFixtures::security(),
      );


      DiemAccount::set_slow(&sender);

      // alice's account is the ID of the team 
      Teams::join_team(&sender, @{{alice}}); 

    }
}
//check: EXECUTED



// //! new-transaction
// //! sender: alice
// //! args: b"for the win", 10
// stdlib_script::TeamsScripts::create_team
// // check: "Keep(EXECUTED)"


// //! new-transaction
// //! sender: bob
// script {
//     use 0x1::Teams;

//     fun main(sender: signer) {
//       let members = Teams::get_team_members(@{{alice}});
//       assert(Vector::contains<address>(&members, &@{{bob}}), 735703);
//     }
// }
// //check: EXECUTED
