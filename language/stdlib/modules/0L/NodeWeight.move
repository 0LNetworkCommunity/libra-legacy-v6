/////////////////////////////////////////////////////////////////////////
// 0L Module
// Node Weight
/////////////////////////////////////////////////////////////////////////
// Node Weight - used for reconfiguring the network, for selecting top N validators to new validator set.
// This module is used to select the validators who would participate in LibraBFT protocol. Due to the restrictions on throughput with increasing validators above a threshold,
// we rank nodes based on node weight (i.e. previous participation heuristics and mining) to select the validators for an epoch.
// File Prefix for errors: 1401
///////////////////////////////////////////////////////////////////////////

address 0x0 {
  module NodeWeight {

    use 0x0::Vector;
    use 0x0::ValidatorUniverse;
    use 0x0::Signer;
    use 0x0::Transaction;
    use 0x0::MinerState;
    use 0x0::Globals;


    // Recommend a new validator set. This uses a Proof of Weight calculation in
    // ValidatorUniverse::get_validator_weight. Every miner that has performed a VDF proof-of-work offline
    // is now eligible for the second step of the proof of work of running a validator.
    // the validator weight will determine the subsidy and transaction fees.
    // Function code: 01 Prefix: 140101
    // Permissions: Public, VM Only
    public fun top_n_accounts(account: &signer, n: u64, current_block_height: u64): vector<address> {

      Transaction::assert(Signer::address_of(account) == 0x0, 140101014010);

      let eligible_validators = Vector::empty<address>();

      //Get all validators from Validator Universe and then find the eligible validators 
      let validators_universe = ValidatorUniverse::get_eligible_validators(account);
      let val_uni_length = Vector::length<address>(&validators_universe);
     
      let k = 0;
      while(k < val_uni_length){
        let addr = *Vector::borrow<address>(&validators_universe, k);
        if(ValidatorUniverse::check_if_active_validator(addr, Globals::get_epoch_length(), current_block_height)){
          Vector::push_back<address>(&mut eligible_validators, addr);    
        };
        k = k + 1;
      };

      let length = Vector::length<address>(&eligible_validators);

      // Base Case: The universe of validators is under the limit of the BFT consensus.
      // If n is greater than or equal to accounts vector length - return the vector.
      if(length <= n)
        return eligible_validators;

      // Vector to store each address's node_weight
      let weights = Vector::empty<u64>();
      let k = 0;
      while (k < length) {

        let cur_address = *Vector::borrow<address>(&eligible_validators, k);
        // Ensure that this address is an active validator
        let validator_weight= MinerState::get_validator_weight(cur_address);
        Vector::push_back<u64>(&mut weights, validator_weight);
        k = k + 1;
      };

      // Sorting the accounts vector based on value (weights).
      // Bubble sort algorithm
      let i = 0;
      while (i < length){
        let j = 0;
        while(j < length-i-1){

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

      // Reverse to have sorted order - high to low.
      Vector::reverse<address>(&mut eligible_validators);

      let diff = length - n; 
      while(diff>0){
        Vector::pop_back(&mut eligible_validators);
        diff =  diff - 1;
      };

      return eligible_validators
    }
  }
}
