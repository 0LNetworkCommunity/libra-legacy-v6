// Transaction script FOR ONBOARDING. Assumes tower-height 0, and that the 
// challenge has a public key which will be turned into an auth_key and 
// subsequently an address.
// The same algortihm for generating account addresses is available offline. 
// This transaction confirms the address.

address 0x1 {
module AccountScripts {
    use 0x1::DiemAccount;
    use 0x1::GAS::GAS;
    use 0x1::ValidatorConfig;
    use 0x1::Globals;
    use 0x1::VDF;
    use 0x1::Errors;
    use 0x1::MakeWhole;

    const ACCOUNT_ALREADY_EXISTS: u64 = 0;

    public(script) fun create_user_by_coin_tx(
        sender: signer,
        account: address,
        authkey_prefix: vector<u8>,
        unscaled_value: u64,
    ) {
        // check if the account already exists.
        assert(!DiemAccount::exists_at(account), Errors::invalid_state(ACCOUNT_ALREADY_EXISTS));

        // IMPORTANT: the human representation of a value is unscaled. The user which expects to send 10 coins, will input that as an unscaled_value. This script converts it to the Move internal scale by multiplying by COIN_SCALING_FACTOR.
        let value = unscaled_value * Globals::get_coin_scaling_factor();
        let new_account_address = DiemAccount::create_user_account_with_coin(
            &sender,
            account,
            authkey_prefix,
            value,
        );

        // Check the account exists and the balance is 0
        assert(DiemAccount::balance<GAS>(new_account_address) > 0, 01);
    }

    public(script) fun create_acc_user(
        sender: signer,
        challenge: vector<u8>,
        solution: vector<u8>,
        difficulty: u64,
        security: u64,
    ) {
        let new_account_address = DiemAccount::create_user_account_with_proof(
            &sender,
            &challenge,
            &solution,
            difficulty,
            security
        );

        // Check the account exists and the balance is 0
        assert(DiemAccount::balance<GAS>(new_account_address) > 0, 01);
    }

    public(script) fun create_acc_val(
        sender: signer,
        challenge: vector<u8>,
        solution: vector<u8>,
        difficulty: u64,
        security: u64,
        ow_human_name: vector<u8>,
        op_address: address,
        op_auth_key_prefix: vector<u8>,
        op_consensus_pubkey: vector<u8>,
        op_validator_network_addresses: vector<u8>,
        op_fullnode_network_addresses: vector<u8>,
        op_human_name: vector<u8>,
    ) {

      // check if this account exists
      let (new_account_address, _) = VDF::extract_address_from_challenge(&challenge);
      // assert(!DiemAccount::exists_at(new_account_address), Errors::invalid_state(ACCOUNT_ALREADY_EXISTS));


      DiemAccount::create_validator_account_with_proof(
            &sender,
            &challenge,
            &solution,
            difficulty,
            security,
            ow_human_name,
            op_address,
            op_auth_key_prefix,
            op_consensus_pubkey,
            op_validator_network_addresses,
            op_fullnode_network_addresses,
            op_human_name,
        );
        
        // Check the account has the Validator role
        assert(ValidatorConfig::is_valid(new_account_address), 03);
        
        // Check the account exists and the balance is greater than 0
        assert(DiemAccount::balance<GAS>(new_account_address) > 0, 04);
    }
    /// claim a make whole payment, requires the index of the payment 
    /// in the MakeWhole module, which can be found using the 
    /// query_make_whole_payment, which should not be run as part of 
    /// the tx as it is relatively resource intensive (linear search)
    public(script) fun claim_make_whole(
        sender: signer,
        index: u64
    ) {
        let _ = MakeWhole::claim_make_whole_payment(&sender, index);
    }

}
}