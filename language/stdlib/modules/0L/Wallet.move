address 0x1 {
module Wallet {
    use 0x1::CoreAddresses;
    use 0x1::Vector;
    use 0x1::Signer;  
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
}
}