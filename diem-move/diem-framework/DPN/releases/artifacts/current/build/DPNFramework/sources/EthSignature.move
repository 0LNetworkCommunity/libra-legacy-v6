// 0L EthSignature MODULE 
address DiemFramework {
    // Support for Ethereum signatures 
    //
    module EthSignature {
        // obtain public key from signature
        // if signature is invalid, then zero key [0u8,20] is returned
        native public fun recover(signature: vector<u8>, message: vector<u8>): vector<u8>;
        // verify signature 
        native public fun verify(
            signature: vector<u8>, pubkey: vector<u8>, message: vector<u8>
        ): bool;
    }
}