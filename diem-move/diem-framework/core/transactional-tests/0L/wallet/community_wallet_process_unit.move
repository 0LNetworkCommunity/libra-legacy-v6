//# init --parent-vasps Dummy Alice Dummy2 Bob Dummy3 Carol Dummy4 Dave
// Dummy, Dummy2:     validators with 10M GAS
// Alice, Bob:    non-validators with  1M GAS

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::DonorDirected;
    use Std::Vector;

    fun main(_dr: signer, sender: signer) {
      DonorDirected::init_donor_directed(&sender, @Bob, @Carol, @Dave, 2);
      DonorDirected::finalize_init(&sender);
      let list = DonorDirected::get_root_registry();
      assert!(Vector::length(&list) == 1, 7357001);

      assert!(DonorDirected::is_donor_directed(@Alice), 7357002);

      let uid = DonorDirected::new_timed_transfer_multisig(&sender, @Alice, @Bob, 100, b"thanks bob");
      assert!(DonorDirected::is_pending(@Alice, &uid), 7357003);
    }
}
// check: EXECUTED




// //# run --admin-script --signers DiemRoot DiemRoot
// script {
//     use DiemFramework::DiemAccount;
//     use DiemFramework::GAS::GAS;
//     use DiemFramework::DonorDirected;
//     use Std::Vector;

//     fun main(vm: signer, _: signer) {
//       let bob_balance = DiemAccount::balance<GAS>(@Bob);
//       assert!(bob_balance == 1000000, 7357004);

//       DiemAccount::process_community_wallets(&vm, 3);

//       let bob_balance = DiemAccount::balance<GAS>(@Bob);
//       assert!(bob_balance == 1000100, 7357005);

//       // assert the community wallet queue has moved the pending transfer to the completed
//       let list: vector<DonorDirected::TimedTransfer> = DonorDirected::list_transfers(0);
//       assert!(Vector::length(&list) == 0, 7357006);

//       let list: vector<DonorDirected::TimedTransfer> = DonorDirected::list_transfers(1);
//       assert!(Vector::length(&list) == 1, 7357007);

//       let list: vector<DonorDirected::TimedTransfer> = DonorDirected::list_transfers(2);
//       assert!(Vector::length(&list) == 0, 7357008);
//     }
// }
// // check: EXECUTED