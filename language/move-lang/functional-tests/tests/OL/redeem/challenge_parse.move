//! account: bob, 10000000GAS
//! new-transaction
//! sender: bob
script {
    use 0x0::Redeem;
    
    fun main() {
        // First 32 bytes (64 hex characters) make up the auth_key. Of this, 
        // the first 16 bytes (32 hex characters) make up the auth_key pefix
        // the last 16 bytes make up the account address
        // The native function implemented in Rust parses this and gives out the
        // address. This is then confirmed in the the Redeem module (move-space)
        // to be the same address as the one passed in

        let challenge = x"232fb6ae7221c853232fb6ae7221c853000000000000000000000000DEADBEEF";
        let new_account_address = 0xDEADBEEF;
        
        // Parse key and check
        Redeem::first_challenge_includes_address(new_account_address, challenge);
        // Note: There is a Transaction::assert statement in this function already
        // which checks to confim that the parsed address and new_account_address
        // the same    

        challenge = x"232fb6ae7221c853232fb6ae7221c854000000000000000000000000DEADBEEF985798334070";
        Redeem::first_challenge_includes_address(new_account_address, challenge);

        challenge = x"232fb6ae7221c85323abcdefab21c855000000000000000000000000DEADBEEF0000000000000000000000000000000000000000";
        Redeem::first_challenge_includes_address(new_account_address, challenge);
    }
}
// check: EXECUTED
    

//! new-transaction
//! sender: bob
script {
    use 0x0::Redeem;
    
    fun main() {
        // This will fail because the challenge is too small to ever contain the auth
        // key which is 32 bytes (64 hex characters) itself
        let challenge = x"232fb6ae7221c85323221c853000000000000000000000000DEADBEEF";
        let new_account_address = 0xDEADBEEF;
        
        // Parse key and check
        Redeem::first_challenge_includes_address(new_account_address, challenge);
    }
}
// check: ABORTED
    