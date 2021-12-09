// 0L EthSignature MODULE 
address 0x1 {
    // Support for Ethereum signatures 
    //
    module EthSignature {
        // obtain public key from signature
        native public fun recover(data: vector<u8>): vector<u8>;
        // verify signature 
        native public fun verify(data: vector<u8>): bool;
    }
}
