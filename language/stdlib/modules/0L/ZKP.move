// ZKP VERIFIER MODULE
// Description... todo

address 0x1 {
  module ZKP {
      native public fun verify(
        proof_hex:            &vector<u8>,
        public_input_json:    &vector<u8>,
        parameters_json:      &vector<u8>,
        annotation_file_name: &vector<u8>
      ) : bool;
  }
}