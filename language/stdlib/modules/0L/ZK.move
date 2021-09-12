// ZK - Zero Knowldege
//TODO: Make Markdown Documentation
address 0x1 {
  module ZK {
      native public fun verify(
        proof: vector<u8>,
        proof_params: vector<u8>,
        task_meta_data: vector<u8>,
        cairo_aux_input: vector<u8>,
        fact: vector<u8>
      ): bool;
      native public fun prove(
        name: vector<u8>,
        value: u128
      ): (vector<u8>, vector<u8>, vector<u8>, vector<u8>, vector<u8>);
  }
}