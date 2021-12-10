// 0L EthSignature MODULE 
address 0x1 {
    // Support for Ethereum signatures 
    //
    module EthSignature {
        // obtain public key from signature
        native public fun recover(signature: vector<u8>, message: vector<u8>): vector<u8>;
        // verify signature 
        native public fun verify(signature: vector<u8>, pubkey: vector<u8>, message: vector<u8>): bool;
    }
}
