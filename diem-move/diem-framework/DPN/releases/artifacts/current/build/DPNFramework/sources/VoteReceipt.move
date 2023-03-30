///////////////////////////////////////////////////////////////////////////
// 0L Module
// VoteLib
// Intatiate different types of user-interactive voting
///////////////////////////////////////////////////////////////////////////

// TODO: Move this to a separate address. Potentially has separate governance.
address DiemFramework { 

  module VoteReceipt {
    
    // Votes that allow retracting will need to store state of the user's
    // vote. This is a simple struct that stores the vote and the weight
    // Yes we know there are lots of game theoretical problems exposing this data, but the votes are visible in transaction logs anyways. Wen Zkp?

    use Std::Vector;
    use Std::Signer;
    use Std::GUID::{Self, ID};

    struct VoteReceipt has key, store, drop, copy { 
      guid: GUID::ID,
      approve_reject: bool,
      weight: u64,
    }
    struct IVoted has key {
      elections: vector<VoteReceipt>,
    }

    public fun make_receipt(user_sig: &signer, vote_id: &ID, approve_reject: bool, weight: u64) acquires IVoted {

      let user_addr = Signer::address_of(user_sig);

      let receipt = VoteReceipt {
        guid: *vote_id,
        approve_reject: approve_reject,
        weight: weight,
      };

      if (!exists<IVoted>(user_addr)) {
        let ivoted = IVoted {
          elections: Vector::empty(),
        };
        move_to<IVoted>(user_sig, ivoted);
      };

      let (idx, is_found) = find_prior_vote_idx(user_addr, vote_id);

      // for safety remove the old vote if it exists.
      let ivoted = borrow_global_mut<IVoted>(user_addr);
      if (is_found) {
        Vector::remove(&mut ivoted.elections, idx);
      };
      Vector::push_back(&mut ivoted.elections, receipt);
    }


    public fun find_prior_vote_idx(user_addr: address, vote_id: &ID): (u64, bool) acquires IVoted {
      if (!exists<IVoted>(user_addr)) {
        return (0, false)
      };
      
      let ivoted = borrow_global<IVoted>(user_addr);
      let len = Vector::length(&ivoted.elections);
      let i = 0;
      while (i < len) {
        let receipt = Vector::borrow(&ivoted.elections, i);
        if (&receipt.guid == vote_id) {
          return (i, true)
        };
        i = i + 1;
      };

      return (0, false)
    }

    fun get_vote_receipt(user_addr: address, idx: u64): VoteReceipt acquires IVoted {
      let ivoted = borrow_global<IVoted>(user_addr);
      let r = Vector::borrow(&ivoted.elections, idx);
      return *r
    }

    public fun remove_vote_receipt(sig: &signer, vote_id: &GUID::ID) acquires IVoted {
      let user_addr = Signer::address_of(sig);
      let (idx, is_found) = find_prior_vote_idx(user_addr, vote_id);

      let ivoted = borrow_global_mut<IVoted>(user_addr);
      if (is_found) {
        Vector::remove(&mut ivoted.elections, idx);
      };
    }

    /// gets the receipt data
    // should return an OPTION.
    public fun get_receipt_data(user_addr: address, vote_id: &ID): (bool, u64) acquires IVoted {
      let (idx, found) = find_prior_vote_idx(user_addr, vote_id);
      if (found) {
          let v = get_vote_receipt(user_addr, idx);
          return (v.approve_reject, v.weight)
        };
      return (false, 0)
    } 
  }

}