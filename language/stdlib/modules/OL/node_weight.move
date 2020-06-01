// This module is to rank nodes based on node weight (i.e., stake they own)
address 0x0 {
  module NodeWeight {

        fun hi(): bool {
              return true
        }

        // This function returns balance given an account number
        fun get_balance(): u64 {
            return 100
        }

        //This function takes the list of verified nodes (validator candidates) and rank them based on node weights.
        fun rank_nodes(): u64 {
            // Sort the list based on account balances.

            //return the list of top 100 nodes 
            return 100
        }
  }
}