///////////////////////////////////////////////////////////////////////////
// 0L Module
// Jail
///////////////////////////////////////////////////////////////////////////
// Stores all the validators who submitted a vdf proof.
// File Prefix for errors: 1001
///////////////////////////////////////////////////////////////////////////

address 0x1 {
  module Jail {
    use 0x1::CoreAddresses;
    use 0x1::TowerState;
    use 0x1::Signer;
    use 0x1::Vector;
    use 0x1::Vouch;

    struct Jail has key {
        is_jailed: bool,
        
        // validator that was jailed and qualified to enter the set, but fails to complete epoch.
        // this resets as soon as they rejoin successfully.
        // this counter is used for ordering prospective validators entering a set.
        consecutive_failed_to_rejoin: u64,
        // number of times the validator was dropped from set. Does not reset.
        lifetime_jailed: u64,
        // number of times a downstream validator this user has vouched for has been jailed.
        // this is recursive. So if a validator I vouched for, vouched for a third validator that failed, this number gets incremented.
        lifetime_vouchees_jailed: u64,
    }

    public fun is_jailed(validator: address): bool acquires Jail {
      if (!exists<Jail>(validator)) {
        return false
      };
      borrow_global<Jail>(validator).is_jailed
    }

    public fun jail(vm: &signer, validator: address) acquires Jail{
      CoreAddresses::assert_vm(vm);

      assert(exists<Jail>(validator), 220101014011);

      let j = borrow_global_mut<Jail>(validator);
      j.is_jailed = true;
      j.lifetime_jailed = j.lifetime_jailed + 1;
      j.consecutive_failed_to_rejoin = j.consecutive_failed_to_rejoin + 1;
    }

    public fun remove_consecutive_fail(vm: &signer, validator: address) acquires Jail{
      CoreAddresses::assert_vm(vm);
      let j = borrow_global_mut<Jail>(validator);
      j.consecutive_failed_to_rejoin = 0;

    }

    public fun vouch_unjail(sender: &signer, addr: address) acquires Jail {
      // only a validator can un-jail themselves.
      let voucher = Signer::address_of(sender);

      let buddies = Vouch::buddies_in_set(addr);
      let (is_found, _idx) = Vector::index_of(&buddies, &voucher);
      assert(is_found, 100103);

      // check the node has been mining before unjailing.
      assert(TowerState::node_above_thresh(addr), 100104);
      unjail(addr);
    }

    // private function. User should not be able to unjail self.
    fun unjail(addr: address) acquires Jail {
      if (exists<Jail>(addr)) {
        borrow_global_mut<Jail>(addr).is_jailed = false;
      };
    }

    /////// Test helpers ////////
    public fun exists_jail(addr: address): bool {
      exists<Jail>(addr)
    }

  }
}