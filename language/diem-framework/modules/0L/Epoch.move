address 0x1 {
/////////////////////////////////////////////////////////////////////////
// Error Code: 0500
/////////////////////////////////////////////////////////////////////////

module Epoch {
  use 0x1::DiemTimestamp;
  use 0x1::CoreAddresses;
  use 0x1::Signer;
  use 0x1::Globals;
  use 0x1::DiemConfig;
  use 0x1::Errors;

  struct Timer has key { 
      epoch: u64,
      height_start: u64,
      seconds_start: u64
  }

    //Function code:01
  public fun initialize(vm: &signer) {
      let sender = Signer::address_of(vm);
      assert(sender == CoreAddresses::DIEM_ROOT_ADDRESS(), Errors::requires_role(050001));
      move_to<Timer>(
      vm, 
      Timer {
          epoch: 0,
          height_start: 0,
          seconds_start: DiemTimestamp::now_seconds()
          }
      );
  }

  public fun epoch_finished(): bool acquires Timer {
      let epoch_secs = Globals::get_epoch_length();
      let time = borrow_global<Timer>(CoreAddresses::DIEM_ROOT_ADDRESS());
      DiemTimestamp::now_seconds() > (epoch_secs + time.seconds_start)
  }

    //Function code:02
  public fun reset_timer(vm: &signer, height: u64) acquires Timer {
      let sender = Signer::address_of(vm);
      assert(sender == CoreAddresses::DIEM_ROOT_ADDRESS(), Errors::requires_role(050002));
      let time = borrow_global_mut<Timer>(CoreAddresses::DIEM_ROOT_ADDRESS());
      time.epoch = DiemConfig::get_current_epoch();
      time.height_start = height;
      time.seconds_start = DiemTimestamp::now_seconds();
  }

  public fun get_timer_seconds_start(vm: &signer):u64 acquires Timer {
      let sender = Signer::address_of(vm);
      assert(sender == CoreAddresses::DIEM_ROOT_ADDRESS(),  Errors::requires_role(050003));
      let time = borrow_global<Timer>(CoreAddresses::DIEM_ROOT_ADDRESS());
      time.seconds_start
  }

    public fun get_timer_height_start(vm: &signer):u64 acquires Timer {
      let sender = Signer::address_of(vm);
      assert(sender == CoreAddresses::DIEM_ROOT_ADDRESS(),  Errors::requires_role(050004));
      let time = borrow_global<Timer>(CoreAddresses::DIEM_ROOT_ADDRESS());
      time.height_start
  }
}
}