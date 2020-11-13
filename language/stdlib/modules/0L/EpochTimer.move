address 0x1 {

module EpochTimer {
  use 0x1::LibraTimestamp;
  use 0x1::CoreAddresses;
  use 0x1::Signer;

  resource struct Timer { 
    epoch: u64,
    seconds_start: u64
  }

  // const EPOCH_LENGTH: u64 = 60 * 60 * 24;
  const EPOCH_LENGTH: u64 = 1;

  public fun initialize(vm: &signer) {
    let sender = Signer::address_of(vm);
    assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 190201014010);
      move_to<Timer>(
      vm, 
      Timer {
          epoch: 0,
          seconds_start: LibraTimestamp::now_seconds()
        }
      );
  }

  public fun is_up(): bool acquires Timer {
    let time = borrow_global<Timer>(CoreAddresses::LIBRA_ROOT_ADDRESS());
    LibraTimestamp::now_seconds() > (EPOCH_LENGTH + time.seconds_start)
  }

  public fun set(_vm: &signer) acquires Timer {
    let time = borrow_global_mut<Timer>(CoreAddresses::LIBRA_ROOT_ADDRESS());
    time.seconds_start = LibraTimestamp::now_seconds();
  }
}
}