// This module returns statistics about the network at any given block, or window of blocks. A number of core OL modules depend on Statistics. The relevant statistics in an MVP are "liveness accountability" statistics. From within the VM context the statistics available are those in the BlockMetadata type.

address 0x0 {
  module Stats {
    use 0x0::Vector;
    use 0x0::Signer;

    // Each Chunk represents one set of contiguous blocks which the validator voted on
    struct Chunk {
      start_block: u64,
      end_block: u64
    }

    // Each Node represents one validator
    struct Node {
      validator: address,
      chunks: vector<Chunk>
    }

    // This stores the full history. For proof of concept (POC), it is a vector
    // which stores one entry for each validator.
    resource struct History {
      val_list: vector<Node>,
    }

    public fun initialize(association: &signer): u64 {
      // TODO: OL: (nelaturuk) This should happen only once in genesis
      if (Signer::address_of(association) == 0xA550C18) {
        move_to_sender<History>(History{ val_list: Vector::empty() });
        return 1u64
      } else {
        return 0u64
      }
    }

    // This should actually return a float as a percentage, but this hasn't been implemented yet.
    // For now, it will be returned as an unsigned int and be a confidence level
    public fun node_heuristics(node_addr: address, start_height: u64,
      end_height: u64): u64 acquires History{
      if (start_height > end_height) return 0;
      let history = borrow_global<History>(0xA550C18);

      // This is the case where the validator has voted on nothing and does not have a Node
      if (!exists(history, node_addr)) return 0;

      let node = get_node(history, node_addr);
      let chunks = &node.chunks;
      let i = 0;
      let len = Vector::length<Chunk>(chunks);
      let num_voted = 0;
      if(node_addr == 0xA550C18) return 1;

      // Go though all the chunks of the validator's node and accumulate
      while (i < len) {
        let chunk = Vector::borrow<Chunk>(chunks, i);
        // Check if the chunk has segments in desired region
        if (chunk.end_block >= start_height && chunk.start_block <= end_height) {
          // Find the lower and upper blockheights within desired region
          let lower = chunk.start_block;
          if (start_height >= lower) lower = start_height;

          let upper = chunk.end_block;
          if (end_height <= upper) upper = end_height;

          // +1 because bounds are inclusive.
          // E.g. a node which participated in only block 30 would have
          // upper - lower = 0 even though it voted in a block.
          num_voted = num_voted + (upper - lower + 1);
        };
        i = i + 1;
      };
      num_voted
    }

    // TODO: OL: (dranade) This should actually return a fixed decimal as a percentage, but this hasn't been implemented yet.
    // For now, it will be returned as an unsigned int and be a confidence level
    public fun network_heuristics(start_height: u64, end_height: u64): u64 acquires History {
      if (start_height > end_height) return 0;
      let history = borrow_global<History>(0xA550C18);
      let val_list = &history.val_list;

      // This keeps track of how many voters voted on every single block in the range
      let num_voters = 0;
      let num_nodes = Vector::length<Node>(val_list);
      if (num_nodes == 0) return 0;
      let i = 0;

      // Go though all the nodes and find the ones which paticipated
      while (i < num_nodes) {
        let j = 0;
        let node = Vector::borrow<Node>(val_list, i);
        let chunks = &node.chunks;
        let num_chunks = Vector::length<Chunk>(chunks);

        // If the node has participated in every single block in a range, then that entire
        // range will be a subset of one of the chunks in the data structure. So, we need
        // only to find the chunk whose start_block is just below (or equal to) the start_height
        // This is faster in a BST, but we do a linear search for the POC implementation
        if (num_chunks == 0) {
          i = i + 1;
          continue
        };

        // Go through all chunks for the node
        let chunk = Vector::borrow<Chunk>(chunks, 0);
        while (j < num_chunks) {
          let cand_chunk = Vector::borrow<Chunk>(chunks, j);
          if (cand_chunk.start_block <= start_height && cand_chunk.start_block > chunk.start_block) {
            chunk = cand_chunk;
          };
          j = j + 1;
        };

        // This is the case that this voter has voted for all blocks in the range
        if (chunk.start_block <= start_height && chunk.end_block >= end_height){
          num_voters = num_voters + 1;
        };
        i = i + 1;
      };
      num_voters
    }

    public fun insert_voter_list(height: u64, votes: &vector<address>) acquires History {
        // TODO: OL: (Nelaturuk) This needs a capability/permission to prevent the general public from calling this function.
      let i = 0;
      let len = Vector::length<address>(votes);
      while (i < len) {
        insert(*Vector::borrow(votes, i), height, height);
        i = i + 1;
      };
    }

    fun insert(node_addr: address, start_block: u64, end_block: u64) acquires History {
      let history = borrow_global_mut<History>(0xA550C18);

      // Add the a Node for the validator if one doesn't aleady exist
      if (!exists(history, node_addr)) {
        Vector::push_back(&mut history.val_list, Node{ validator: node_addr, chunks: Vector::empty() });
      };

      let node = get_node_mut(history, node_addr);
      let i = 0;
      let len = Vector::length<Chunk>(&node.chunks);

      if (len == 0) {
        Vector::push_back(&mut node.chunks, Chunk{ start_block: start_block, end_block: end_block });
        return
      };

      // This is a temporary reference to an existing chunk. Assuming there are no
      // conflicts and it is not adjacent to an existing chunk, it will be discarded.
      // If it is adjacent, we will assign this reference to the adjacent chunk so
      // we don't have to search for it again.
      // This should all be simpler in the final implementation in Rust since we will
      // be able to use binary trees and the Option<T> type.
      let adjacent = false;
      let chunk = Vector::borrow_mut(&mut node.chunks, 0);

      // Check to see if the insert conflicts with what is already stored
      while (i < len) {
        chunk = Vector::borrow_mut(&mut node.chunks, i);

        if ((chunk.start_block > end_block) || (chunk.end_block < start_block - 1)){
          // This is the case where the new block is not connected to the old
          // one we are comparing with
          i = i + 1;
          continue
        };
        // If chunk.end_block == start_block, then we are just adding on to the last block
        if (chunk.end_block == start_block - 1) {
          adjacent = true;
          break
        };
        i = i + 1;
      };

      // Add in the new chunk
      if (adjacent){
        chunk.end_block = end_block
      } else {
        Vector::push_back(&mut node.chunks, Chunk{ start_block: start_block, end_block: end_block });
      }
    }

    // This function goes through the vector in history and gets the desired node (immutable reference).
    // By the time this runs, we already know that the node exists in the history
    fun get_node(hist: &History, add: address): &Node {
      let i = 0;
      let node_list = &hist.val_list;
      let len = Vector::length<Node>(node_list);
      let node = Vector::borrow<Node>(node_list, i);

      while (i < len) {
        node = Vector::borrow<Node>(node_list, i);
        i = i + 1;
        if (node.validator == add) break;
      };
      node
    }

    // This function goes through the vector in history and gets the desired node (mutable reference).
    // By the time this runs, we already know that the node exists in the history
    fun get_node_mut(hist: &mut History, add: address): &mut Node {
      let i = 0;
      let node_list = &mut hist.val_list;
      let len = Vector::length<Node>(node_list);
      let node = Vector::borrow_mut<Node>(node_list, i);

      while (i < len) {
        node = Vector::borrow_mut<Node>(node_list, i);
        i = i + 1;
        if (node.validator == add) break;
      };
      node
    }

    // This must be included since does not suppot the Option<T> data type.
    // Since there is no way to return Some<Node> or None, we must do this check separately.
    fun exists(hist: &History, add: address): bool {
      let i = 0;
      let node_list = &hist.val_list;
      let len = Vector::length<Node>(node_list);

      while (i < len) {
        if (Vector::borrow<Node>(node_list, i).validator == add) return true;
        i = i + 1;
      };
      false
    }
  }
}


// Code which might be useful when moving beyond POC stage

//     struct TreeNode{
//       validator: address,
//       start_block: u32,
//       end_block: u32
//     }

//     resource struct Validator_Tree{
//       val_list: vector<u64>,    // not sure the type, so I leave it generic rn. Not the most robust
//       size: u64,              // number of blocks stored in this tree
//       root: TreeNode,
//     }
