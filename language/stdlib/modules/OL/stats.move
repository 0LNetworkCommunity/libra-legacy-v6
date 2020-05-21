
// This module returns statistics about the network at any given block, or window of blocks. A number of core OL modules depend on Statistics. The relevant statistics in an MVP are "liveness accountability" statistics. From within the VM context the statistics available are those in the BlockMetadata type.

address 0x0 {
  module Stats {

    // TODO: Check if libra core "leader reputation" can be wrapped or implemented in our own contract: https://github.com/libra/libra/pull/3026/files
    // pub fun Node_Heuristics(node_address: address type, start_blockheight: u32, end_blockheight: u32)  {
    // fun liveness(node_address){
        // Returns the percentage of blocks have been signed by the node within the range of blocks.
    // }

    // pub fun Network_Heuristics() {
    //  fun signer_density_window(start_blockheight, end_blockheight) {
        // Find the min count of nodes that signed *every* block in the range.
    //  }

    //  fun signer_density_lookback(number_of_blocks: u32 ) {
        // Sugar Needed for subsidy contract. Counts back from current block that accepted transaction. E.g. 1,000 blocks.
    //  }
    // }
  }
}
