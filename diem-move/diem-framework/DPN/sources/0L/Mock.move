// Some fixutres are complex and are repeatedly needed

address DiemFramework {
module Mock {
  // use DiemFramework::TowerState;
  use Std::Vector;
  use DiemFramework::Stats;
  use DiemFramework::Cases;
  // use DiemFramework::Debug::print;
  use DiemFramework::Testnet;
  use DiemFramework::ValidatorUniverse;
  use DiemFramework::DiemAccount;
  use DiemFramework::ProofOfFee;
  use DiemFramework::DiemSystem;
  use DiemFramework::Diem;
  use DiemFramework::TransactionFee;
  use DiemFramework::GAS::GAS;

  public fun mock_case_1(vm: &signer, addr: address, start_height: u64, end_height: u64){
      Testnet::assert_testnet(vm);

      // can only apply this to a validator
      // assert!(DiemSystem::is_validator(addr) == true, 777701);
      // mock mining for the address
      // the validator would already have 1 proof from genesis
      // TowerState::test_helper_mock_mining_vm(vm, addr, 10);

      // mock the consensus votes for the address
      let voters = Vector::empty<address>();
      Vector::push_back<address>(&mut voters, addr);

      let num_blocks = end_height - start_height;
      // Overwrite the statistics to mock that all have been validating.
      let i = 1;
      let above_thresh = num_blocks / 2; // just be above 5% signatures

      while (i < above_thresh) {
          // Mock the validator doing work for 15 blocks, and stats being updated.
          Stats::process_set_votes(vm, &voters);
          i = i + 1;
      };
      
      // print(&addr);
      // print(&Cases::get_case(vm, addr, start_height, end_height));
      // TODO: careful that the range of heights is within the test
      assert!(Cases::get_case(vm, addr, start_height, end_height) == 1, 777703);
    }

    // V6: deprecated

    // // did not do enough mining, but did validate.
    // public fun mock_case_2(vm: &signer, addr: address, start_height: u64, end_height: u64){
    //   // can only apply this to a validator
    //   // assert!(DiemSystem::is_validator(addr) == true, 777704);
    //   // mock mining for the address
    //   // insufficient number of proofs
    //   // TowerState::test_helper_mock_mining_vm(vm, addr, 0);
    //   // assert!(TowerState::get_count_in_epoch(addr) == 0, 777705);

    //   // mock the consensus votes for the address
    //   let voters = Vector::singleton<address>(addr);

    //   let num_blocks = end_height - start_height;
    //   // Overwrite the statistics to mock that all have been validating.
    //   let i = 1;
    //   let above_thresh = num_blocks / 2; // just be above 5% signatures

    //   while (i < above_thresh) {
    //       // Mock the validator doing work for 15 blocks, and stats being updated.
    //       Stats::process_set_votes(vm, &voters);
    //       i = i + 1;
    //   };
      
    //   // TODO: careful that the range of heights is within the test
    //   assert!(Cases::get_case(vm, addr, start_height, end_height) == 2, 777706);

    // }

    // did not do enough mining, but did validate.
    public fun mock_case_4(vm: &signer, addr: address, start_height: u64, end_height: u64){
      Testnet::assert_testnet(vm);


      let voters = Vector::singleton<address>(addr);

      // Overwrite the statistics to mock that all have been validating.
      let i = 1;
      let above_thresh = 1; // just be above 5% signatures
      Stats::test_helper_remove_votes(vm, addr);
      while (i < above_thresh) {
          // Mock the validator doing work for 15 blocks, and stats being updated.
          
          Stats::process_set_votes(vm, &voters);
          i = i + 1;
      };
      // print(&Cases::get_case(vm, addr, start_height, end_height) );
      // TODO: careful that the range of heights is within the test
      assert!(Cases::get_case(vm, addr, start_height, end_height) == 4, 777706);

    }

    // Mockl all nodes being compliant case 1
    public fun all_good_validators(vm: &signer) {

      Testnet::assert_testnet(vm);
      let vals = DiemSystem::get_val_set_addr();

      let i = 0;
      while (i < Vector::length(&vals)) {

        let a = Vector::borrow(&vals, i);
        mock_case_1(vm, *a, 0, 15);
        i = i + 1;
      };

    }

    //////// PROOF OF FEE ////////
    public fun pof_default(vm: &signer): (vector<address>, vector<u64>, vector<u64>){

      Testnet::assert_testnet(vm);
      let vals = ValidatorUniverse::get_eligible_validators();

      let (bids, expiry) = mock_bids(vm, &vals);

      DiemAccount::slow_wallet_epoch_drip(vm, 100000); // unlock some coins for the validators

      // make all validators pay auction fee
      // the clearing price in the fibonacci sequence is is 1
      DiemAccount::vm_multi_pay_fee(vm, &vals, 1, &b"proof of fee");

      (vals, bids, expiry)
    }

    public fun mock_bids(vm: &signer, vals: &vector<address>): (vector<u64>, vector<u64>) {
      Testnet::assert_testnet(vm);

      let bids = Vector::empty<u64>();
      let expiry = Vector::empty<u64>();
      let i = 0;
      let prev = 0;
      let fib = 1;
      while (i < Vector::length(vals)) {

        Vector::push_back(&mut expiry, 1000);
        let b = prev + fib;
        Vector::push_back(&mut bids, b);

        let a = Vector::borrow(vals, i);
        let sig = DiemAccount::scary_create_signer_for_migrations(vm, *a);
        // initialize and set.
        ProofOfFee::set_bid(&sig, b, 1000);
        prev = fib;
        fib = b;
        i = i + 1;
      };

      (bids, expiry)

    }

    // function to deposit into network fee account
    public fun mock_network_fees(vm: &signer, amount: u64) {
      Testnet::assert_testnet(vm);
      let c = Diem::mint<GAS>(vm, amount);
      let c_value = Diem::value(&c);
      assert!(c_value == amount, 777707);
      TransactionFee::pay_fee(c);
    }

}
}