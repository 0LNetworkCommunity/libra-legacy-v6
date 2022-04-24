///////////////////////////////////////////////////////////////////////////
// 0L Module
// Recovery Mode
///////////////////////////////////////////////////////////////////////////
// For when an admin upgrade or network halt recovery needs to be exectuted.
// For use for example in preventing front running by miners and validators 
// for rewards while the network is unstable.
///////////////////////////////////////////////////////////////////////////



address 0x1 {
module RecoveryMode {

    use 0x1::CoreAddresses;
    use 0x1::DiemConfig;
    use 0x1::DiemSystem;
    use 0x1::Vector;

    struct RecoveryMode has copy, key, drop, store{
      // set this if a validator set needs to be overriden
      // if list is empty, it will use validator set.
      fixed_set: vector<address>, 
      epoch_ends: u64,
    }

    // private function so that it can only be called by vm session.
    // should never be used in production.
    fun init_recovery(vm: &signer, vals: vector<address>, epoch_ends: u64) {
      if (!is_recovery()) {
        move_to<RecoveryMode>(vm, RecoveryMode {
          fixed_set: vals,
          epoch_ends,
        });
      }
    }

    public fun maybe_remove_debug_at_epoch(vm: &signer) acquires RecoveryMode {
      CoreAddresses::assert_vm(vm);
      let d = borrow_global<RecoveryMode>(CoreAddresses::VM_RESERVED_ADDRESS());
      if (
        DiemConfig::get_current_epoch() >= d.epoch_ends &&
        DiemSystem::validator_set_size() >= 21
      ){
        remove_debug(vm);
      }
    }

    fun remove_debug(vm: &signer) acquires RecoveryMode {
      CoreAddresses::assert_vm(vm);
      if (is_recovery()) {
        _ = move_from<RecoveryMode>(CoreAddresses::VM_RESERVED_ADDRESS());
      }
    }

    public fun is_recovery(): bool {
      exists<RecoveryMode>(CoreAddresses::VM_RESERVED_ADDRESS())
    }

    public fun get_debug_vals(): vector<address> acquires RecoveryMode  {
      if (is_recovery()) {
        let d = borrow_global<RecoveryMode>(CoreAddresses::VM_RESERVED_ADDRESS());
        *&d.fixed_set
      } else {
        Vector::empty<address>()
      }
    }
}
} 