// This module is used to select the validators who would participate in LibraBFT protocol. Due to the restrictions on throughput with increasing validators above a threshold, 
// we rank nodes based on node weight (i.e., stake they own, previous participation trends) to select the validators for an epoch. 
address 0x0 {
  module NodeWeight {

    use 0x0::Vector;

    // Input: a vector of account addresses
    //Output: Top n according to weight (Just account balance for now) 
    public fun top_n_accounts(accounts: vector<address>, n: u64): vector<address> {
      
      let length = Vector::length<address>(&accounts);
      
      //BASE CASE
      // If n is greater than or equal to accounts vector length - return the vector.
       if(length<=n)
        return accounts
      
      // Now we rank to find out top n accounts based on weights.

      //Weight - currently function of account balance. 

      
      else
        return Vector::empty()
    } 
  }
}