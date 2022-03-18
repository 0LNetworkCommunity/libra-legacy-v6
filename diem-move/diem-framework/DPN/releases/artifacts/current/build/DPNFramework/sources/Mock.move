// Some fixutres are complex and are repeatedly needed

address DiemFramework {
module Mock {
  use DiemFramework::DiemSystem;
  use DiemFramework::TowerState;
  use Std::Vector;
  use DiemFramework::Stats;
  use DiemFramework::Cases;

  public fun mock_case_1(vm: &signer, addr: address){
      // can only apply this to a validator
      assert!(DiemSystem::is_validator(addr) == true, 777701);
      // mock mining for the address
      // the validator would already have 1 proof from genesis
      TowerState::test_helper_mock_mining_vm(vm, addr, 10);

      // mock the consensus votes for the address
      let voters = Vector::empty<address>();
      Vector::push_back<address>(&mut voters, addr);

      // Overwrite the statistics to mock that all have been validating.
      let i = 1;
      while (i < 16) {
          // Mock the validator doing work for 15 blocks, and stats being updated.
          Stats::process_set_votes(vm, &voters);
          i = i + 1;
      };
      
      // TODO: careful that the range of heights is within the test
      assert!(Cases::get_case(vm, addr, 0 , 1000) == 1, 777703);

    }


    // did not do enough mining, but did validate.
    public fun mock_case_2(vm: &signer, addr: address){
      // can only apply this to a validator
      assert!(DiemSystem::is_validator(addr) == true, 777704);
      // mock mining for the address
      // insufficient number of proofs
      TowerState::test_helper_mock_mining_vm(vm, addr, 0);
      // assert!(TowerState::get_count_in_epoch(addr) == 0, 777705);

      // mock the consensus votes for the address
      let voters = Vector::empty<address>();
      Vector::push_back<address>(&mut voters, addr);

      // Overwrite the statistics to mock that all have been validating.
      let i = 1;
      while (i < 16) {
          // Mock the validator doing work for 15 blocks, and stats being updated.
          Stats::process_set_votes(vm, &voters);
          i = i + 1;
      };
      
      // TODO: careful that the range of heights is within the test
      assert!(Cases::get_case(vm, addr, 0 , 1000) == 2, 777706);

    }
}
}
