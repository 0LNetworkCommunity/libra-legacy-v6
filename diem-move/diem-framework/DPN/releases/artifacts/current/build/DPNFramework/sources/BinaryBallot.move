
address DiemFramework {
    module BinaryBallot {
    
    // a binary ballot is a ballot that has only two vote options, approve and reject


    struct BinaryBallot<Issue, TallyType> has store, drop {
      cfg_deadline: BallotDeadline,
      cfg_enrollment_votes: u64, // max number of votes

      issue: Issue, // data for the issue being decided.
      tally: TallyType, // tally methodology
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