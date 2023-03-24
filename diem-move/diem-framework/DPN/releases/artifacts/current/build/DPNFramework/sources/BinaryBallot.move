
address DiemFramework {
    module BinaryTally {
    
    // a binary ballot is a ballot that has only two vote options, approve and reject

    struct BinaryTally has store, drop {
      cfg_deadline: BallotDeadline,
      cfg_enrollment_votes: u64, // max number of votes

      votes_approve: u64,
      votes_reject: u64,
      passed: u64,
    }

    struct BallotDeadline has store, drop {
      cfg_deadline_epoch: u64,
      cfg_can_extend: bool,
      cfg_max_number_extensions: u64,
      extended_deadline: u64,
    }

  }
}