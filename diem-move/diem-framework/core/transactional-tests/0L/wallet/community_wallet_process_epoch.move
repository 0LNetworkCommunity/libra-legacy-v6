// Todo: These GAS values have no effect, all accounts start with 1M GAS
//! account: alice, 1000000GAS, 0, validator
//! account: bob,   1000000GAS, 0


//! new-transaction
//! sender: alice
script {
    use DiemFramework::Wallet;
    use Std::Vector;

    fun main(sender: signer) {
      Wallet::set_comm(&sender);
      let list = Wallet::get_comm_list();

      assert!(Vector::length(&list) == 1, 7357001);
      assert!(Wallet::is_comm(@{{alice}}), 7357002);

      let uid = Wallet::new_timed_transfer(&sender, @{{bob}}, 100, b"thanks bob");
      assert!(Wallet::transfer_is_proposed(uid), 7357003);
    }
}

// check: EXECUTED


//////////////////////////////////////////////
//// Trigger reconfiguration at 61 seconds ///
//! block-prologue
//! proposer: alice
//! block-time: 61000000
//! round: 15

////// TEST RECONFIGURATION IS HAPPENING /////
// check: NewEpochEvent
//////////////////////////////////////////////

//////////////////////////////////////////////
//// Trigger reconfiguration again         ///
//! block-prologue
//! proposer: alice
//! block-time: 125000000
//! round: 20

////// TEST RECONFIGURATION IS HAPPENING /////
// check: NewEpochEvent
//////////////////////////////////////////////


//////////////////////////////////////////////
//// Trigger reconfiguration again         ///
//! block-prologue
//! proposer: alice
//! block-time: 190000000
//! round: 20

////// TEST RECONFIGURATION IS HAPPENING /////
// check: NewEpochEvent
//////////////////////////////////////////////


//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    fun main(_vm: signer) {
      let bob_balance = DiemAccount::balance<GAS>(@{{bob}});
      assert!(bob_balance == 1000100, 7357005);
    }
}

// check: EXECUTED