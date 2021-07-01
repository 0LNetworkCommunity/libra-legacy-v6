address 0x1 {
    module Wallet{
    use 0x1::CoreAddresses;
    use 0x1::Vector;

    resource struct CommunityWallets {
        list: vector<address>
    }

    public fun init_comm_list(vm: &signer) {
      CoreAddresses::assert_libra_root(vm);
      move_to<CommunityWallets>(vm, CommunityWallets {
        list: Vector::empty<address>()
      });  
    }

    }
}