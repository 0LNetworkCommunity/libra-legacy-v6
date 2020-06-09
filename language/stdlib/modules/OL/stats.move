
// This module returns statistics about the network at any given block, or window of blocks. A number of core OL modules depend on Statistics. The relevant statistics in an MVP are "liveness accountability" statistics. From within the VM context the statistics available are those in the BlockMetadata type.

address 0x0 {
  module Stats {
    use 0x0::Debug;
    use 0x0::Vector;
    use 0x0::Transaction;

    // temporarily, the data struct is just going to be done in Move
    struct TreeNode{
      validator: u64,         // not sure the type of a validator
      start_epoch: u64,
      end_epoch: u64
    }

    resource struct Validator_Tree{
      val_list: vector<u64>,    // not sure the type, so I leave it generic rn. Not the most robust
      size: u64,              // number of blocks stored in this tree
      root: TreeNode,
    }

    // TODO: Check if libra core "leader reputation" can be wrapped or implemented in our own contract: https://github.com/libra/libra/pull/3026/files
    // pub fun Node_Heuristics(node_address: address type, start_blockheight: u32, end_blockheight: u32)  {
    // fun liveness(node_address){
        // Returns the percentage of blocks have been signed by the node within the range of blocks.

        // Accomplished by querying the data structue
    // }

    // pub fun Network_Heuristics() {
    //  fun signer_density_window(start_blockheight, end_blockheight) {
        // Find the min count of nodes that signed *every* block in the range.
    //  }

    //  fun signer_density_lookback(number_of_blocks: u32 ) {
        // Sugar Needed for subsidy contract. Counts back from current block that accepted transaction. E.g. 1,000 blocks.
    //  }
    // }

    struct Foo {}
    struct Bar { x: u128, y: Foo, z: bool }
    struct Box<T> { x: T }

    // Here, I experiment with persistence
    // Committing some code that worked successfully
    resource struct State{
      hist: vector<u8>,
    }

    public fun initialize(  ){
      let a = 0;
      move_to_sender<State>(State{ hist: Vector::empty() });
      Debug::print(&a);
    }

    public fun add_stuff() acquires State {
      let st = borrow_global_mut<State>(Transaction::sender());
      let s = &mut st.hist;

      Vector::push_back(s, 1);
      let a = 10;
      Debug::print(&a);
      Vector::push_back(s, 2);
      a = 20;
      Debug::print(&a);
      Vector::push_back(s, 3);
      a = 30;
      Debug::print(&a);

      let b = Transaction::sender();
      Debug::print(&b);
    }

    public fun remove_stuff() acquires State{
      let st = borrow_global_mut<State>(Transaction::sender());
      let s = *&st.hist;

      let a = Vector::pop_back<u8>(&mut s);
      Debug::print(&a);
      a = Vector::pop_back<u8>(&mut s);
      Debug::print(&a);
      a = Vector::pop_back<u8>(&mut s);
      Debug::print(&a);

      a = 255;
      Debug::print(&a);

      let b = Transaction::sender();
      Debug::print(&b);
    }

    public fun p_addr(a: address){
      Debug::print(&a);
    }

    // below are printing tests fo referrence

    public fun test()  {
        let x = 42;
        Debug::print(&x);

        let v = Vector::empty();
        Vector::push_back(&mut v, 100);
        Vector::push_back(&mut v, 200);
        Vector::push_back(&mut v, 300);
        Debug::print(&v);

        let foo = Foo {};
        Debug::print(&foo);

        let bar = Bar { x: 404, y: Foo {}, z: true };
        Debug::print(&bar);

        let box = Box { x: Foo {} };
        Debug::print(&box);

        let str = 12;
        Debug::print(&str);
    }

  }
}

