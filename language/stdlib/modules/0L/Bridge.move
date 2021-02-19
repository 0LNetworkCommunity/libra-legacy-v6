
/////////////////////////////////////////////////////////////////////////
// 0L Module
// Demo Persistence
/////////////////////////////////////////////////////////////////////////

address 0x1{
    module Bridge{
        use 0x1::Vector;
        use 0x1::CoreAddresses;
        use 0x1::Testnet::is_testnet;
        use 0x1::Libra;
        use 0x1::GAS::GAS;
        use 0x1::Signer;

        // TODO: Demoware, Change this to EventHandle
        resource struct EthBridge{
          lock: vector<Details>,
          unlock: vector<Details>,
          balance: Libra::Libra<GAS>
        }

        struct Details {
          sender: address,
          value: u64,
        }

        public fun initialize_eth(vm: &signer){
          assert(is_testnet(), 01);
          CoreAddresses::assert_libra_root(vm);
          move_to<EthBridge>(vm, EthBridge{
            lock: Vector::empty<Details>(),
            unlock: Vector::empty<Details>(),
            balance: Libra::zero<GAS>()
          });
        }

        // TODO: Eth_Receipient is a hex.
        public fun lock_from(sender: &signer, _eth_recipient: address, coin: Libra::Libra<GAS>) acquires EthBridge {
          let state = borrow_global_mut<EthBridge>(CoreAddresses::LIBRA_ROOT_ADDRESS());
          
          Vector::push_back<Details>(&mut state.lock, Details {
            sender: Signer::address_of(sender),
            value: Libra::value<GAS>(&coin)
          });
          Libra::deposit(&mut state.balance, coin);
        }

    }
}