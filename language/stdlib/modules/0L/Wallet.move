address 0x1 {
module Wallet {
    use 0x1::CoreAddresses;
    use 0x1::Vector;
    use 0x1::Signer;
    use 0x1::Errors;
    use 0x1::LibraConfig;
    use 0x1::Option::{Self,Option};
    use 0x1::LibraSystem;
    use 0x1::NodeWeight;

    const ERR_PREFIX: u64 = 023;
    //////// COMMUNITY WALLETS ////////

    resource struct CommunityWallets {
        list: vector<address>
    }

    resource struct CommunityFreeze {
        consecutive_rejections: u64
    }


    public fun init_comm_list(vm: &signer) {
      CoreAddresses::assert_libra_root(vm);
      if (!exists<CommunityWallets>(0x0)) {
        move_to<CommunityWallets>(vm, CommunityWallets {
          list: Vector::empty<address>()
        });  
      }
    }

    public fun set_comm(sig: &signer) acquires CommunityWallets {
      if (exists<CommunityWallets>(0x0)) {
        let addr = Signer::address_of(sig);
        let list = get_comm_list();
        if (!Vector::contains<address>(&list, &addr)) {
            let s = borrow_global_mut<CommunityWallets>(0x0);
            Vector::push_back(&mut s.list, addr);
        };

        move_to<CommunityFreeze>(sig, CommunityFreeze {
          consecutive_rejections: 0
        })
      }
    }

    public fun remove_comm(sig: &signer) acquires CommunityWallets {
      if (exists<CommunityWallets>(0x0)) {
        let addr = Signer::address_of(sig);
        let list = get_comm_list();
        let (yes, i) = Vector::index_of<address>(&list, &addr);
        if (yes) {
            let s = borrow_global_mut<CommunityWallets>(0x0);
            Vector::remove(&mut s.list, i);
          }
      }
    }

    public fun vm_set_comm(vm: &signer, addr: address) acquires CommunityWallets {
      CoreAddresses::assert_libra_root(vm);
      if (exists<CommunityWallets>(0x0)) {
        let list = get_comm_list();
        if (!Vector::contains<address>(&list, &addr)) {
        
          let s = borrow_global_mut<CommunityWallets>(0x0);
          Vector::push_back(&mut s.list, addr);
        }
      } else {
        init_comm_list(vm);
      }
    }

    public fun get_comm_list(): vector<address> acquires CommunityWallets{
      if (exists<CommunityWallets>(0x0)) {
        let s = borrow_global<CommunityWallets>(0x0);
        return *&s.list
      } else {
        return Vector::empty<address>()
      }
    }

    public fun is_comm(addr: address): bool acquires CommunityWallets{
      let s = borrow_global<CommunityWallets>(0x0);
      Vector::contains<address>(&s.list, &addr)
    }


    // Timed transfer submission
    resource struct CommunityTransfers {
      proposed: vector<TimedTransfer>,
      approved: vector<TimedTransfer>,
      rejected: vector<TimedTransfer>,
      max_uid: u64,

    }
    struct TimedTransfer {
      uid: u64,
      expire_epoch: u64,
      payer: address,
      payee: address,
      value: u64,
      description: vector<u8>,
      veto: vector<address>,
    }

  public fun init_comm_transfers(vm: &signer) {
    CoreAddresses::assert_libra_root(vm);
    move_to<CommunityTransfers>(vm, CommunityTransfers{
      proposed: Vector::empty<TimedTransfer>(),
      approved: Vector::empty<TimedTransfer>(),
      rejected: Vector::empty<TimedTransfer>(),
      max_uid: 0,
    })
  }

  fun find_proposed(uid: u64): Option<TimedTransfer> acquires CommunityTransfers {
    let list = &borrow_global<CommunityTransfers>(0x0).proposed;
    let len = Vector::length(list);
    let i = 0;
    while (i < len) {
      let t = *Vector::borrow<TimedTransfer>(list, i);
      if (t.uid == uid) {
        return Option::some<TimedTransfer>(t)
      };
      i = i + 1;
    };
    Option::none<TimedTransfer>()
  }

  public fun new_timed_transfer(sender: &signer, payee: address, value: u64, description: vector<u8>): u64 acquires CommunityTransfers, CommunityWallets {
      let sender_addr = Signer::address_of(sender);
      let list = get_comm_list();
        
      assert(
        Vector::contains<address>(&list, &sender_addr), Errors::requires_role(ERR_PREFIX + 001)
      );

      let d = borrow_global_mut<CommunityTransfers>(0x0);
      d.max_uid = d.max_uid + 1;
      
      // add current epoch + 1
      let current_epoch = LibraConfig::get_current_epoch();

      let t = TimedTransfer {
          uid: d.max_uid,
          expire_epoch: current_epoch + 7,
          payer: sender_addr,
          payee: payee,
          value: value,
          description: description,
          veto: Vector::empty<address>(),
      };

      Vector::push_back<TimedTransfer>(&mut d.proposed, t);
      return d.max_uid
    }

    public fun transfer_is_proposed(uid: u64): bool acquires  CommunityTransfers {
      Option::is_some<TimedTransfer>(&find_proposed(uid))
    }


  public fun veto(sender: &signer, uid: u64) acquires CommunityTransfers {
     let addr = Signer::address_of(sender);
    assert(
      LibraSystem::is_validator(addr),
      Errors::requires_role(ERR_PREFIX + 001)
    );
    let opt = find_proposed(uid);
    if (Option::is_some<TimedTransfer>(&opt)) {
      let t = Option::extract<TimedTransfer>(&mut opt);
      Vector::push_back<address>(&mut t.veto, addr);
      if (tally_veto(t)) {
        reject(uid)
      }
    };
  }

  // reject a transaction and removed from proposed list if vetoed
  fun reject(uid: u64) acquires CommunityTransfers {
    let c = borrow_global_mut<CommunityTransfers>(0x0);
    let list = *&c.proposed;
    let len = Vector::length(&list);
    let i = 0;
    while (i < len) {
      let t = *Vector::borrow<TimedTransfer>(&list, i);
      if (t.uid == uid) {
        Vector::remove<TimedTransfer>(&mut c.proposed, 1);
      };
      Vector::push_back(&mut c.rejected, t);
      i = i + 1;
    };
    
  }
  fun tally_veto(t: TimedTransfer): bool {
    let votes = 0;
    let threshold = calculate_proportional_voting_threshold();

    let k = 0;
    let len = Vector::length<address>(&t.veto);
    while (k < len) {
      let addr = *Vector::borrow<address>(&t.veto, k);
      // ignore votes that are no longer in the validator set,
      // BUT DON'T REMOVE, since they may rejoin the validator set, and shouldn't need to vote again.
      if (LibraSystem::is_validator(addr)) {
        votes = votes + NodeWeight::proof_of_weight(addr)
      };
      k = k + 1;
    };

    return votes > threshold
  }

  // get the total voting power of the validator set, and find the 2/3rds threshold
  fun calculate_proportional_voting_threshold(): u64 {
      let val_set_size = LibraSystem::validator_set_size();
      let i = 0;
      let voting_power = 0;
      while (i < val_set_size) {
        let addr = LibraSystem::get_ith_validator_address(i);
        voting_power = voting_power + NodeWeight::proof_of_weight(addr);
        i = i + 1;
      };
      let threshold = voting_power * 2 / 3;
      threshold
  }

    // Process Transactions
    // reset approved list
    // clear the freeze count.
    // pop off proposed list
    // add to approved list
    // transfer funds


    // Freeze()
    /// after consecutive freezes
    // reset freeze count


    // Vote to unfreeze a wallet.




    //////// SLOW WALLETS ////////
    resource struct SlowWallet {
        is_slow: bool
    }

    public fun set_slow(sig: &signer) {
      if (!exists<SlowWallet>(Signer::address_of(sig))) {
        move_to<SlowWallet>(sig, SlowWallet {
          is_slow: true
        });  
      }
    }

    public fun is_slow(addr: address): bool {
      exists<SlowWallet>(addr)
    }
}
}