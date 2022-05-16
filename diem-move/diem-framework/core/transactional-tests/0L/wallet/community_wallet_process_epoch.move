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
      assert!(Wallet::is_comm(@Alice), 7357002);

      let uid = Wallet::new_timed_transfer(&sender, @Bob, 100, b"thanks bob");
      assert!(Wallet::transfer_is_proposed(uid), 7357003);
    }
}

// check: EXECUTED


//////////////////////////////////////////////
//// Trigger reconfiguration at 61 seconds ///
//# block --proposer Alice --time 61000000 --round 15

////// TEST RECONFIGURATION IS HAPPENING /////
// check: NewEpochEvent
//////////////////////////////////////////////

//////////////////////////////////////////////
//// Trigger reconfiguration again         ///
//# block --proposer Alice --time 1 --round 025000000
//! round: 20

////// TEST RECONFIGURATION IS HAPPENING /////
// check: NewEpochEvent
//////////////////////////////////////////////


//////////////////////////////////////////////
//// Trigger reconfiguration again         ///
//# block --proposer Alice --time 1 --round 090000000
//! round: 20

////// TEST RECONFIGURATION IS HAPPENING /////
// check: NewEpochEvent
//////////////////////////////////////////////


//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    fun main(_vm: signer) {
      let bob_balance = DiemAccount::balance<GAS>(@Bob);
      assert!(bob_balance == 1000100, 7357005);
    }
}

// check: EXECUTED