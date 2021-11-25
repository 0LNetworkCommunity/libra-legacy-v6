//! account: alice, 0GAS, 0, validator
//! account: eve, 0GAS, 0

// NOTE: alice is validator, she will become a tribal elder.
// then eve will join her tribe.


// 1. Initialize the teams struct in VM

//! block-prologue
//! proposer: alice
//! block-time: 1
//! new-transaction
//! sender: diemroot

script {
  use 0x1::Teams;
  use 0x1::EpochBoundary;

  fun main(vm: signer) {
    // nothing is initialized yet
    assert(!Teams::vm_is_init(), 735701);
    assert(!Teams::team_is_init(@{{alice}}), 735702);
    EpochBoundary::reconfigure(&vm, 0);
  }
}
// check: EXECUTED


// 2. Alice creates one Team

//! new-transaction
//! sender: alice
script {
  use 0x1::Teams;

  fun main(alice: signer) {
    // nothing is initialized yet

    let team_name = b"for the win";
    Teams::team_init(&alice, team_name, 10); // 10% operator bonus.

    assert(Teams::team_is_init(@{{alice}}), 735703);
    assert(Teams::get_operator_reward(@{{alice}}) == 10, 735704);

    
  }
}
// check: EXECUTED

// 3. eve joins the team

//! new-transaction
//! sender: eve
script {

  use 0x1::Teams;
  use 0x1::DiemAccount;
  use 0x1::TowerState;
  use 0x1::TestFixtures;

  fun main(eve: signer) {
    DiemAccount::set_slow(&eve);
    Teams::join_team(&eve, @{{alice}}); // alice's account is the ID of the tribe 

    // eve initializes miner state, will later mine
    TowerState::init_miner_state(
        &eve,
        &TestFixtures::eve_0_easy_chal(),
        &TestFixtures::eve_0_easy_sol(),
        TestFixtures::easy_difficulty(),
        TestFixtures::security(),
    );

  }
}
// check: EXECUTED


//! new-transaction
//! sender: diemroot
script {
    use 0x1::Stats;
    use 0x1::Vector;
    use 0x1::Cases;
    use 0x1::TowerState;
    use 0x1::DiemAccount;
    // use 0x1::EpochBoundary;
    use 0x1::Debug::print;
    use 0x1::GAS::GAS;
    use 0x1::TransactionFee;
    use 0x1::Teams;
    use 0x1::Subsidy;

    fun main(sender: signer) {
        let sender = &sender;
        let members = Teams::get_team_members(@{{alice}});
        print(&members);

        let member_tower_minimum_const = 336;

        let captain_balance = DiemAccount::balance<GAS>(@{{alice}});
        print(&captain_balance);
        // mock mining above threshold
        TowerState::test_helper_mock_mining_vm(sender, @{{alice}}, 500); // alice above thresh

        // mock votes above threshold
        let voters = Vector::singleton<address>(@{{alice}});
        let i = 1;
        while (i < 16) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(sender, &voters);
            i = i + 1;
        };

        // check alice is a case 1 valdator
        assert(Cases::get_case(sender, @{{alice}}, 0 , 15) == 1, 735701);
        
        // Mock BELOW THRESHOLD
        TowerState::test_helper_mock_mining_vm(sender, @{{eve}}, member_tower_minimum_const - 10); // below threshold
        
        let txn_fee_amount = TransactionFee::get_amount_to_distribute(sender);

        print(&txn_fee_amount);

        // process subsidy (without running all reconfig logic)
        Subsidy::process_subsidy(sender, 1000000, &Vector::singleton<address>(@{{alice}}));

        let captain_balance = DiemAccount::balance<GAS>(@{{alice}});
        print(&captain_balance);

        let team_member_balance = DiemAccount::balance<GAS>(@{{eve}});
        print(&team_member_balance);

        // note: rounding of 1
        assert(captain_balance == 99999, 735703);
        assert(team_member_balance == 0, 735704);

    }
}
//check: EXECUTED