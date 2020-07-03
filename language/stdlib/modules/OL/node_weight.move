// This module is used to select the validators who would participate in LibraBFT protocol. Due to the restrictions on throughput with increasing validators above a threshold,
// we rank nodes based on node weight (i.e., stake they own, previous participation trends) to select the validators for an epoch.
address 0x0 {
  module NodeWeight {

    use 0x0::Vector;
    use 0x0::ValidatorUniverse;
    use 0x0::Signer;
    use 0x0::Transaction;
    use 0x0::Option;
    use 0x0::Debug;

    // Recommend a new validator set. This uses a Proof of Weight calculation in
    // ValidatorUniverse::get_validator_weight. Every miner that has performed a VDF proof-of-work offline
    // is now eligible for the second step of the proof of work of running a validator.
    // the validator weight will determine the subsidy and transaction fees.
    public fun top_n_accounts(account: &signer, n: u64): (vector<address>, u64) {
      Debug::print(&0x110DE00111E161170000000000001001);


      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0xA550C18 || sender == 0x0, 8001);

      //Get eligible validators from Validator Universe
      let eligible_validators = ValidatorUniverse::get_eligible_validators(account);
      Debug::print(&0x110DE00111E161170000000000001002);

      let length = Vector::length<address>(&eligible_validators);

      // Base Case: The universe of validators is under the limit of the BFT consensus.
      // If n is greater than or equal to accounts vector length - return the vector.
      if(length<=n)
        return (eligible_validators, ValidatorUniverse::get_total_voting_power());

      // Vector to store the addrees's node_weight
      let weights = Vector::empty<u64>();
      let total_voting_power = 0;
      let k = 0;
      while (k < length) {
        Debug::print(&0x110DE00111E161170000000000001003);

        let cur_address = *Vector::borrow<address>(&eligible_validators, k);
        // Ensure that this address is an active validator
        let validator_weight_vec = ValidatorUniverse::get_validator_weight(cur_address);
        Transaction::assert(Option::is_some(&validator_weight_vec), 8002);
        let validator_weight = *Option::borrow(&validator_weight_vec);
        Vector::push_back<u64>(&mut weights, validator_weight);
        total_voting_power = total_voting_power + validator_weight;
        k = k + 1;
      };
      Debug::print(&0x110DE00111E161170000000000001004);

      // Sorting the accounts vector based on value (weights).
      // Bubble sort algorithm
      let i = 0;
      while (i < length){
        let j = 0;
        while(j < length-i-1){
          Debug::print(&0x110DE00111E161170000000000001005);

          let value_j = *(Vector::borrow<u64>(&weights, j));
          let value_jp1 = *(Vector::borrow<u64>(&weights, j+1));
          if(value_j > value_jp1){
            Vector::swap<u64>(&mut weights, j, j+1);
            Vector::swap<address>(&mut eligible_validators, j, j+1);
          };
          j = j + 1;
        };
        i = i + 1;
      };

      Debug::print(&0x110DE00111E161170000000000001006);

      // Reverse to have sorted order - high to low.
      Vector::reverse<address>(&mut eligible_validators);
      let index = n;
      while(index < length){
        Vector::pop_back<address>(&mut eligible_validators);
        index = index + 1;
      };
      Debug::print(&0x110DE00111E161170000000000001007);
      return (eligible_validators, total_voting_power)
    }
  }
}
