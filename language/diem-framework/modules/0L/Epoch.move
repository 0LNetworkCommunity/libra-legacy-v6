/////////////////////////////////////////////////////////////////////////
// Error Code: 0500
/////////////////////////////////////////////////////////////////////////

address 0x1 {

/// # Summary 
/// This module allows the root to determine epoch boundaries, triggering 
/// epoch change operations (e.g. updating the validator set)
module Epoch {
  use 0x1::DiemTimestamp;
  use 0x1::CoreAddresses;
  use 0x1::Globals;
  use 0x1::DiemConfig;
  use 0x1::Roles;

  use 0x1::Debug::print;

  /// Contains timing info for the current epoch
  /// epoch: the epoch number
  /// height_start: the block height the epoch started at
  /// seconds_start: the start time of the epoch
  struct Timer has key { 
      epoch: u64,
      height_start: u64,
      seconds_start: u64
  }

  // Function code:01
  /// Called in genesis to initialize timer
  public fun initialize(vm: &signer) {
      Roles::assert_diem_root(vm);
      move_to<Timer>(
          vm, 
          Timer {
              epoch: 0,
              height_start: 0,
              seconds_start: DiemTimestamp::now_seconds()
          }
      );
  }

  /// Check to see if epoch is finished 
  /// Simply checks if the elapsed time is greater than the epoch time 
  public fun epoch_finished(height_now: u64): bool acquires Timer {
      let time = borrow_global<Timer>(CoreAddresses::DIEM_ROOT_ADDRESS());

      // we target 24hrs for block production.
      // there are failure cases when there is a halt, and nodes have been offline for all of the 24hrs, producing a new epoch upon restart leads to further failures. So we check that a meaninful amount of blocks have been created too.
      print(&9999999999999999);
      print(&Globals::get_min_blocks_epoch());
      print(&height_now);
      print(&time.height_start);
      let enough_blocks = height_now > (time.height_start + Globals::get_min_blocks_epoch());

      print(&enough_blocks);

      let time_now = DiemTimestamp::now_seconds();
      let len = Globals::get_epoch_length();
      print(&time_now);

      print(&len);

      let enough_time = (time_now > (time.seconds_start + len));

      print(&enough_time);

      (enough_blocks && enough_time)
      
  }

  // Function code:02
  /// Reset the timer to start the next epoch 
  /// Called by root in the reconfiguration process
  public fun reset_timer(vm: &signer, height: u64) acquires Timer {
      Roles::assert_diem_root(vm);
      let time = borrow_global_mut<Timer>(CoreAddresses::DIEM_ROOT_ADDRESS());
      time.epoch = DiemConfig::get_current_epoch() + 1;
      time.height_start = height;
      time.seconds_start = DiemTimestamp::now_seconds();
  }

  /// Accessor Function, returns the time (in seconds) of the start of the current epoch
  public fun get_timer_seconds_start(vm: &signer):u64 acquires Timer {
      Roles::assert_diem_root(vm);
      let time = borrow_global<Timer>(CoreAddresses::DIEM_ROOT_ADDRESS());
      time.seconds_start
  }

  /// Accessor Function, returns the block height of the start of the current epoch
  public fun get_timer_height_start(vm: &signer):u64 acquires Timer {
      Roles::assert_diem_root(vm);
      let time = borrow_global<Timer>(CoreAddresses::DIEM_ROOT_ADDRESS());
      time.height_start
  }
}
}