// Todo: These GAS values have no effect, all accounts start with 1M GAS
//! account: alice, 10000000GAS, 0, validator
//! account: bob,   1000000GAS, 0
//! account: carol,   1000000GAS, 0

// CAROL THE COMMUNITY WALLET TIMED TRANSFER
// Carol will send Bob funds from the community wallet. It will be processed after three epoch boundaries complete.

//! new-transaction
//! sender: carol
script {
    use 0x1::Wallet;
    use 0x1::Vector;

    fun main(sender: signer) {
      Wallet::set_comm(&sender);
      let list = Wallet::get_comm_list();

      assert(Vector::length(&list) == 1, 7357001);
      assert(Wallet::is_comm(@{{carol}}), 7357002);

      let uid = Wallet::new_timed_transfer(&sender, @{{bob}}, 100, b"thanks bob");
      assert(Wallet::transfer_is_proposed(uid), 7357003);
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
//! round: 30

////// TEST RECONFIGURATION IS HAPPENING /////
// check: NewEpochEvent
//////////////////////////////////////////////


//////////////////////////////////////////////
//// Trigger reconfiguration again         ///
//! block-prologue
//! proposer: alice
//! block-time: 190000000
//! round: 90

////// TEST RECONFIGURATION IS HAPPENING /////
// check: NewEpochEvent
//////////////////////////////////////////////


//! new-transaction
//! sender: diemroot
script {
    use 0x1::DiemAccount;
    use 0x1::GAS::GAS;
    fun main(_vm: signer) {
      let bob_balance = DiemAccount::balance<GAS>(@{{bob}});

      assert(bob_balance == 1000100, 7357005);
    }
}

// check: EXECUTED