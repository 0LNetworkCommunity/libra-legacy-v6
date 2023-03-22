// 0L HASH MODULE 
address DiemFramework {
    // Hash functions for 0L project 
    //
    module XHash {
        // Ethereum keccak_256 hash function
        native public fun keccak_256(data: vector<u8>): vector<u8>;
    }
}