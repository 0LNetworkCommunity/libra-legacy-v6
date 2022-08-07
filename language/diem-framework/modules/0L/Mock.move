// Some fixutres are complex and are repeatedly needed

address 0x1 {
module Mock {
  // use 0x1::DiemSystem;
  use 0x1::TowerState;
  use 0x1::Vector;
  use 0x1::Stats;
  use 0x1::Cases;

  use 0x1::Debug::print;

  public fun mock_case_1(vm: &signer, addr: address, start_height: u64, end_height: u64){
    print(&addr);
      // can only apply this to a validator
      // assert(DiemSystem::is_validator(addr) == true, 777701);
      // mock mining for the address
      // the validator would already have 1 proof from genesis
      TowerState::test_helper_mock_mining_vm(vm, addr, 10);

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
      
      // TODO: careful that the range of heights is within the test
      assert(Cases::get_case(vm, addr, start_height, end_height) == 1, 777703);

    }


    // did not do enough mining, but did validate.
    public fun mock_case_2(vm: &signer, addr: address, start_height: u64, end_height: u64){
      // can only apply this to a validator
      // assert(DiemSystem::is_validator(addr) == true, 777704);
      // mock mining for the address
      // insufficient number of proofs
      TowerState::test_helper_mock_mining_vm(vm, addr, 0);
      // assert(TowerState::get_count_in_epoch(addr) == 0, 777705);

      // mock the consensus votes for the address
      let voters = Vector::singleton<address>(addr);

      let num_blocks = end_height - start_height;
      // Overwrite the statistics to mock that all have been validating.
      let i = 1;
      let above_thresh = num_blocks / 2; // just be above 5% signatures

      while (i < above_thresh) {
          // Mock the validator doing work for 15 blocks, and stats being updated.
          Stats::process_set_votes(vm, &voters);
          i = i + 1;
      };
      
      // TODO: careful that the range of heights is within the test
      assert(Cases::get_case(vm, addr, start_height, end_height) == 2, 777706);

    }
}
}
