// Testing if EVE a CASE 3 Validator gets dropped.

// ALICE is CASE 1
//! account: alice, 1000000, 0, validator
// BOB is CASE 1
//! account: bob, 1000000, 0, validator
// CAROL is CASE 1
//! account: carol, 1000000, 0, validator
// DAVE is CASE 1
//! account: dave, 1000000, 0, validator
// EVE is CASE 3
//! account: eve, 1000000, 0, validator
// FRANK is CASE 1
//! account: frank, 1000000, 0, validator

// GERTIE is CASE 1
//! account: gertie, 1000000, 0, validator

//! block-prologue
//! proposer: alice
//! block-time: 1
//! NewBlockEvent

//! new-transaction
//! sender: eve
script {
    use 0x1::TowerState;
    use 0x1::Vouch;

    fun main(sender: signer) {
        // Mock some mining so Eve can send rejoin tx
        TowerState::test_helper_mock_mining(&sender, 100);
        Vouch::init(&sender);
    }
}

//! new-transaction
//! sender: alice
script {
    use 0x1::Vouch;

    fun main(sender: signer) {
      Vouch::vouch_for(&sender, @{{eve}});
    }
}

//! new-transaction
//! sender: diemroot
script {
    use 0x1::Jail;

    fun main(vm: signer) {
      
      Jail::jail(&vm, @{{eve}});
      assert(Jail::is_jailed(@{{eve}}), 7357001);
      assert(Jail::get_vouchee_jail(@{{alice}}) > 0, 7357002);
    }
}
//check: EXECUTED


//! new-transaction
//! sender: alice
script {
    use 0x1::Jail;

    fun main(sender: signer) {
      
      Jail::vouch_unjail(&sender, @{{eve}});
      assert(!Jail::is_jailed(@{{eve}}), 7357001);
    }
}
