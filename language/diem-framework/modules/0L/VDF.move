// VDF VERIFIER MODULE
// challenge is a byte string like 'aa'(e.g. address of the user)
// difficulty is the amount of work/time the vdf proof ran, usually milliseconds. Is an integer (e.g. '100' milliseconds)
// alleged_solution is the result of the proof that was run on the user's computer of type Vec<u8>. (e.g. '005271e8f9ab2eb')

address 0x1 {
  module VDF {
      native public fun verify(
        challenge: &vector<u8>,
        difficulty: &u64,
        alleged_solution: &vector<u8>
      ): bool;
      native public fun extract_address_from_challenge(challenge: &vector<u8>): (address, vector<u8>);
  }
}
