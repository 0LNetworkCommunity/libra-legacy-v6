address 0x1 {
module Wallet {
    use 0x1::CoreAddresses;
    use 0x1::Vector;
    use 0x1::Signer;
    use 0x1::Errors;
    use 0x1::LibraConfig;
    use 0x1::Option::{Self,Option};
    use 0x1::LibraSystem;

    const ERR_PREFIX: u64 = 023;
    //////// COMMUNITY WALLETS ////////

    resource struct CommunityWallets {
        list: vector<address>
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
          }
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
    }
    // check sender is in validator set
    // check all votes are still in validator set
  }
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