//# init --parent-vasps Alice Bob X Carol
// Alice:          validators with 10M GAS
// Bob, Carol: non-validators with  1M GAS

// CAROL THE COMMUNITY WALLET TIMED TRANSFER
// Carol will send Bob funds from the community wallet. 
// It will be processed after three epoch boundaries complete.

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::Wallet;
    use Std::Vector;

    fun main(_dr: signer, sender: signer) {
      Wallet::set_comm(&sender);
      let list = Wallet::get_comm_list();

      assert!(Vector::length(&list) == 1, 7357001);
      assert!(Wallet::is_comm(@Carol), 7357002);

      let uid = Wallet::new_timed_transfer(&sender, @Bob, 100, b"thanks bob");
      assert!(Wallet::transfer_is_proposed(uid), 7357003);
    }
}

//////////////////////////////////////////////
//// Trigger reconfiguration at 61 seconds ///
//# block --proposer Alice --time 61000000 --round 15

////// TEST RECONFIGURATION IS HAPPENING /////
// check: NewEpochEvent
//////////////////////////////////////////////

//////////////////////////////////////////////
//// Trigger reconfiguration again         ///
//# block --proposer Alice --time 125000000 --round 30

////// TEST RECONFIGURATION IS HAPPENING /////
// check: NewEpochEvent
//////////////////////////////////////////////

//////////////////////////////////////////////
//// Trigger reconfiguration again         ///
//# block --proposer Alice --time 190000000 --round 90

////// TEST RECONFIGURATION IS HAPPENING /////
// check: NewEpochEvent
//////////////////////////////////////////////

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    fun main() {
      let bob_balance = DiemAccount::balance<GAS>(@Bob);
      assert!(bob_balance == 1000100, 7357005);
    }
}