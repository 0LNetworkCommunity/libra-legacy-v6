/////////////////////////////////////////////////////////////////////////
// Error Code: 0500
/////////////////////////////////////////////////////////////////////////

address DiemFramework {

/// # Summary 
/// This module allows the root to determine epoch boundaries, triggering 
/// epoch change operations (e.g. updating the validator set)
module Epoch {
  use DiemFramework::DiemTimestamp;
  use DiemFramework::Globals;
  use DiemFramework::DiemConfig;
  use DiemFramework::Roles;

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

  // TODO: Unclear if we want to migrate epoch number
  /// Migrate the timer in a fork.
  // fun fork_migrate(vm: &signer, epoch: u64) {
  //     CoreAddresses::assert_vm(vm);
  //     let time = borrow_global<Timer>(@VMReserved);
  //     time.epoch = epoch;
  //     time.height_start = 0;
  //     time.seconds_start = DiemTimestamp::now_seconds();
  // }

  /// Check to see if epoch is finished 
  /// Simply checks if the elapsed time is greater than the epoch time 
  public fun epoch_finished(height_now: u64): bool acquires Timer {
      let time = borrow_global<Timer>(@DiemRoot);
      // we target 24hrs for block production.
      // there are failure cases when there is a halt, and nodes have been
      // offline for all of the 24hrs, producing a new epoch upon restart
      // leads to further failures. So we check that a meaninful amount of
      // blocks have been created too.
      let enough_blocks = height_now > (time.height_start + Globals::get_min_blocks_epoch());
      let time_now = DiemTimestamp::now_seconds();
      let len = Globals::get_epoch_length();
      let enough_time = (time_now > (time.seconds_start + len));

      (enough_blocks && enough_time)
  }

  // Function code:02
  /// Reset the timer to start the next epoch 
  /// Called by root in the reconfiguration process
  public fun reset_timer(vm: &signer, height: u64) acquires Timer {
      Roles::assert_diem_root(vm);
      let time = borrow_global_mut<Timer>(@DiemRoot);
      time.epoch = DiemConfig::get_current_epoch() + 1;
      time.height_start = height;
      time.seconds_start = DiemTimestamp::now_seconds();
  }

  /// Accessor Function, returns the time (in seconds) of the start of the current epoch
  public fun get_timer_seconds_start():u64 acquires Timer {
      // Roles::assert_diem_root(vm);
      let time = borrow_global<Timer>(@DiemRoot);
      time.seconds_start
  }

  /// Accessor Function, returns the block height of the start of the current epoch
  public fun get_timer_height_start():u64 acquires Timer {
      // Roles::assert_diem_root(vm);
      let time = borrow_global<Timer>(@DiemRoot);
      time.height_start
  }
}
}