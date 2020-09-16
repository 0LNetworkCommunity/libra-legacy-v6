///////////////////////////////////////////////////////////////////////////
// 0L Module
// Stats
///////////////////////////////////////////////////////////////////////////
// This module returns statistics about the network at any given block,
// or window of blocks. A number of core 0L modules depend on Statistics.
// The relevant statistics in an MVP are "liveness accountability" statistics.
// From within the VM context the statistics available are those in the
// BlockMetadata type.


address 0x0 {
  module Stats {
    use 0x0::Vector;
    use 0x0::Signer;
    use 0x0::Transaction;


    // Each Chunk represents one set of contiguous blocks which the validator voted on
    // NOTE: As currently written, boundaries are inclusive
    struct Chunk {
      start_block: u64,
      end_block: u64
    }


    // Each Node represents one validator. Each node will store a vector of chunks
    // on which the node voted
    struct Node {
      validator: address,
      chunks: vector<Chunk>
    }


    // This stores the full history. For proof of concept (POC), it is a vector
    // which stores one entry for each validator.
    // When moving beyond the POC, this should be turned into a self-balancing
    // BST for speed reasons.
    resource struct History {
      val_list: vector<Node>,
    }


    // Initialize the storage mechanism in a specific account
    public fun initialize(storage_acc: &signer): u64 {
      if (Signer::address_of(storage_acc) == 0x0) {
        move_to_sender<History>(History{ val_list: Vector::empty() });
        1u64
      } else {
        0u64
      }
    }


    // Returns the number of blocks this node has signed in the period of
    // start_height to end_height
    public fun node_heuristics(node_addr: address, start_height: u64,
      end_height: u64): u64 acquires History {

      // Edge case
      if(node_addr == 0x0) return 1;

      // Ensue inputs (start_height and end_height) are valid
      if (start_height > end_height) return 0;

      // Obtain read access to the storage
      let history = borrow_global<History>(0x0);

      // If the validator hasn't voted on anything, they will not have a Node
      // stored in the storage. Retun 0 if this is the case since they didn't vote
      if (!exists(history, node_addr)) return 0;

      // Get read access to the vector storing info for the validator requested
      let node = get_node(history, node_addr);
      let chunks = &node.chunks;

      // This is an accumulator variable keeping track of the number of votes
      let num_voted = 0;

      // Iterate through the chunks of the validator's node and accumulate
      let i = 0;
      let len = Vector::length<Chunk>(chunks);
      while (i < len) {
        let chunk = Vector::borrow<Chunk>(chunks, i);
        // Check if the chunk has segments in desired region. In a timeline
        // where |        | represents the desired region and \        \ represents
        // a chunk, we are looking for situations of the following format
        // --> \   |  \   |  -->         or      -->  |         \    |            \
        if (chunk.end_block >= start_height && chunk.start_block <= end_height) {
          // Compute the lower blockheights for only the overlapping region
          let lower = chunk.start_block;
          if (start_height >= lower) lower = start_height;

          // Compute the upper blockheights for only the overlapping region
          let upper = chunk.end_block;
          if (end_height <= upper) upper = end_height;

          // Compute the size of the overlapping region, adding 1 because
          // the bounds are inclusive. Then, increment the accumulator
          // E.g. a node which participated in only block 30 would have
          // upper - lower = 0 even though it voted in a block.
          num_voted = num_voted + (upper - lower + 1);
        };
        i = i + 1;
      };
      num_voted
    }


    // Returns the number of nodes which have voted on every block in the input range
    public fun network_heuristics(start_height: u64,
      end_height: u64): u64 acquires History {

      // Ensure inputs (start_height, end_height) are a valid range.
      if (start_height > end_height) return 0;

      // Obtain read access to the storage.
      let history = borrow_global<History>(0x0);
      let val_list = &history.val_list;

      // This accumulator keeps track of how many voters voted on every single block
      // in the range.
      let num_voters = 0;

      // Iterate though all the nodes and accumulate the ones that participated
      let node_idx = 0;
      let num_nodes = Vector::length<Node>(val_list);
      while (node_idx < num_nodes) {
        // Get read access to the node's chunks
        let node = Vector::borrow<Node>(val_list, node_idx);
        let chunks = &node.chunks;

        let num_chunks = Vector::length<Chunk>(chunks);
        let chunk_idx = 0;

        // If the node has participated in every single block in a range, then that entire
        // range will be a subset of one of the chunks in the data structure since the chunks
        // are contiguous. So, we need only to find the chunk whose start_block is just below
        // (or equal to) the start_height. This will be faster in a BST, but we do a linear
        // search for the POC implementation

        // Case where this node hasn't voted in anything. Just skip to the next node
        if (num_chunks == 0) {
          node_idx = node_idx + 1;
          continue
        };

        // Case where node has voted. Iterate through its chunks and find one that overlaps
        // the range. As described above, if this node actually participated in all blocks
        // in the desired range, this chunk will be unique. If we find an overlapping chunk
        // and it doesn't include the entire range specified, the node cannot possibly have
        // voted on all blocks in the range

        // chunk is a vector that keeps track of the latest chunk (biggest height) visited
        // whose start is still before (or equal to) the range in question. After iterating
        // though all the chunks, this variable will be the desired ovelapping chunk (if it
        // exists)
        let chunk = Vector::borrow<Chunk>(chunks, 0);
        while (chunk_idx < num_chunks) {
          // cand_chunk serves to find a chunk which starts later than chunk but still before
          // (or with) the start of the desired region.
          let cand_chunk = Vector::borrow<Chunk>(chunks, chunk_idx);

          // if cand_chunk meets the criteria, update chunk
          if (cand_chunk.start_block <= start_height && cand_chunk.start_block > chunk.start_block) {
            chunk = cand_chunk;
          };
          chunk_idx = chunk_idx + 1;
        };

        // This is the case that this voter has voted for all blocks in the range
        if (chunk.start_block <= start_height && chunk.end_block >= end_height){
          num_voters = num_voters + 1;
        };
        node_idx = node_idx + 1;
      };
      num_voters
    }


    // Performs a number of batch inserts input through a vector votes
    public fun insert_voter_list(height: u64, votes: &vector<address>) acquires History {
      // Check permission
      Transaction::assert(Transaction::sender() == 0x0, 190204014010);

      // Iterate through the input vector
      let i = 0;
      let len = Vector::length<address>(votes);
      while (i < len) {
        // Insert each element using the private insert function
        insert(*Vector::borrow(votes, i), height, height);
        i = i + 1;
      };
    }


    // Insert one chunk into the storage
    fun insert(node_addr: address, start_block: u64, end_block: u64) acquires History {
      // Get write access to the storage.
      let history = borrow_global_mut<History>(0x0);

      // Add a new Node for the validator if one doesn't aleady exist.
      if (!exists(history, node_addr)) {
        Vector::push_back(&mut history.val_list, Node{ validator: node_addr, chunks: Vector::empty() });
      };

      // Get read write access to the node.
      let node = get_node_mut(history, node_addr);
      let len = Vector::length<Chunk>(&node.chunks);

      // If node has no chunks stored, add a new chunk and return.
      if (len == 0) {
        Vector::push_back(&mut node.chunks, Chunk{ start_block: start_block, end_block: end_block });
        return
      };

      // To do the actual insert, we must consider the case where an existing chunk can
      // simply be modified. For example, if a chunk exists with end=5 and we need to add
      // a new chunk which has start=6, it doesn't make sense to add a new chunk. We should
      // just find the adjacent node and modify it.
      //
      // `chunk` is a temporary reference to an existing (possibly adjacent) chunk.
      // it will be discarded if there are no conflicts and the new chunk is not adjacent
      // to an existing chunk.
      //
      // If an adjacent chunk exists, we will assign this reference to the adjacent chunk
      // so we don't have to search for it again.
      // This should all be simpler if the final implementation is in Rust since we will
      // be able to use binary trees and the Option<T> type instead of this complex setup.
      let chunk = Vector::borrow_mut(&mut node.chunks, 0);

      // This boolean is a flag which keeps track of whether or not the new chunk has
      // an adjacent chunk existing in the structure
      let adjacent = false;

      let i = 0;
      // Iterate through chunks to find conflicts and/or adjacent chunks
      while (i < len) {
        // Get a write access reference to an existing chunk.
        chunk = Vector::borrow_mut(&mut node.chunks, i);

        // This is the case where the new block is not connected to the old
        // one we are comparing with. Continue searching.
        if ((chunk.start_block > end_block) || (chunk.end_block < start_block - 1)){
          i = i + 1;
          continue

          // Note: The case where chunk.start_block - 1 = end_block does not need
          // consideration because this would imply that an insert is being done
          // regarding chunks in the past (since the existing chunk is ahead of the
          // chunk being inserted). This will never happen since only 0x0 can insert
          // and it inserts in order of height periodically.
        };

        // If chunk.end_block == start_block, then we are just adding on to the last block.
        if (chunk.end_block == start_block - 1) {
          adjacent = true;
          break
        };
        i = i + 1;
      };

      // Add in the new chunk (or update an existing chunk depending)
      if (adjacent){
        chunk.end_block = end_block
      } else {
        Vector::push_back(&mut node.chunks, Chunk{ start_block: start_block, end_block: end_block });
      }
    }


    // Goes through the vector in history and gets the desired node (immutable reference).
    // By the time this runs, we already know that the node exists in the history so we
    // don't need to run existence checks again.
    fun get_node(hist: &History, add: address): &Node {
      // Get an immutable reference to the vector of nodes.
      let node_list = &hist.val_list;

      // Grab an immutable reference to a candidate node.
      let node = Vector::borrow<Node>(node_list, 0);

      // Iterate through the vector of nodes seaching for desired address.
      let i = 0;
      let len = Vector::length<Node>(node_list);
      while (i < len) {
        node = Vector::borrow<Node>(node_list, i);
        i = i + 1;
        if (node.validator == add) break;
      };
      node
    }


    // Goes through the vector in history and gets the desired node (mutable reference).
    // By the time this runs, we already know that the node exists in the history so we
    // don't need to run existence checks again.
    fun get_node_mut(hist: &mut History, add: address): &mut Node {
      // Get a mutable reference to the vector of nodes.
      let node_list = &mut hist.val_list;

      // Length borrow must happen before mutable borrow because ownership rules
      let len = Vector::length<Node>(node_list);

      // Grab a mutable eference to a candidate node.
      let node = Vector::borrow_mut<Node>(node_list, 0);

      // Iterate through the vector of nodes searching for desired address.
      let i = 0;
      while (i < len) {
        node = Vector::borrow_mut<Node>(node_list, i);
        i = i + 1;
        if (node.validator == add) break;
      };
      node
    }


    // Checks for existence of a node in the storage.
    // Since there is no way to return Some<Node> or None (using Rust's Option<T>),
    // we must do this check and actually get the object separately.
    fun exists(hist: &History, add: address): bool {
      // Get read access to the list of nodes
      let node_list = &hist.val_list;

      // Iterate through them to check if desired node exists
      let i = 0;
      let len = Vector::length<Node>(node_list);
      while (i < len) {
        if (Vector::borrow<Node>(node_list, i).validator == add) return true;
        i = i + 1;
      };
      false
    }
  }
}


// Code which might be useful when moving beyond POC stage (when lists are turned
// into trees)

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
