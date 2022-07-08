// VDF VERIFIER MODULE
// challenge is a byte string like 'aa'(e.g. address of the user)
// difficulty is the amount of work/time the vdf proof ran, usually milliseconds. Is an integer (e.g. '100' milliseconds)
// alleged_solution is the result of the proof that was run on the user's computer of type Vec<u8>. (e.g. '005271e8f9ab2eb')

address DiemFramework {
  module VDF {

      // verifies a VDF proof with security parameters.
      native public fun verify(
        challenge: &vector<u8>,
        solution: &vector<u8>,
        difficulty: &u64,
        security: &u64,
      ): bool;

      // For the 0th proof of a Delay Tower, this is used to check the tower belongs to an authorization key and address.
      native public fun extract_address_from_challenge(challenge: &vector<u8>): (address, vector<u8>);
  }
}
