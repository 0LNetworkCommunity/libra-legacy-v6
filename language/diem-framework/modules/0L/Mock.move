// Some fixutres are complex and are repeatedly needed

address 0x1 {
module Mock {
  use 0x1::DiemSystem;
  use 0x1::TowerState;
  use 0x1::Vector;
  use 0x1::Stats;
  use 0x1::Cases;

  public fun mock_case_1(vm: &signer, addr: address){
      // can only apply this to a validator
      assert(DiemSystem::is_validator(addr) == true, 735701);
      // mock mining for the address
      TowerState::test_helper_mock_mining_vm(vm, addr, 5);
      assert(TowerState::get_count_in_epoch(addr) == 5, 735702);

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
      assert(Cases::get_case(vm, addr, 0 , 1000) == 1, 735703);

    }
}
}
