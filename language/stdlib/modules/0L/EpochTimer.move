address 0x1 {

module EpochTimer {
  use 0x1::LibraTimestamp;
  use 0x1::CoreAddresses;
  use 0x1::Signer;
  use 0x1::Globals;
  use 0x1::Debug::print;
  resource struct Timer { 
    epoch: u64,
    seconds_start: u64
  }


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

  public fun epoch_finished(): bool acquires Timer {
    let epoch_secs = Globals::get_epoch_length();
    print(&epoch_secs);
    let time = borrow_global<Timer>(CoreAddresses::LIBRA_ROOT_ADDRESS());
    print(&time.seconds_start);
    print(&LibraTimestamp::now_seconds());
    LibraTimestamp::now_seconds() > (epoch_secs + time.seconds_start)
  }

  public fun reset_timer(vm: &signer) acquires Timer {
    let sender = Signer::address_of(vm);
    assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 190201014010);
    let time = borrow_global_mut<Timer>(CoreAddresses::LIBRA_ROOT_ADDRESS());
    time.epoch = time.epoch + 1;
    time.seconds_start = LibraTimestamp::now_seconds();
  }
}
}