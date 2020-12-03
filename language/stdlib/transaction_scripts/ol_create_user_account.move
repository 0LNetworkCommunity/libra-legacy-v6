// Transaction script FOR ONBOARDING. Assumes tower-height 0, and that the challenge has a public key which will be turned into an auth_key and subsequently an address.
// The same algortihm for generating account addresses is available offline. This transaction confirms the address.
script {
  use 0x1::LibraAccount;
  use 0x1::GAS::GAS;

  fun create_user_account(    
    _sender: &signer,
    challenge: vector<u8>,
    solution: vector<u8>,
  ) {

    let new_account_address = LibraAccount::create_user_account_with_proof(
      &challenge,
      &solution,
    );

    // Check the account exists and the balance is 0
    assert(LibraAccount::balance<GAS>(new_account_address) == 0, 01);
}
}
