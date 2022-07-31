//# init --validators Alice

// Tests for ethereum signature functions 
// Tests are ported from here: 
// https://web3js.readthedocs.io/en/v1.2.2/web3-eth-accounts.html#sign 

//# run --admin-script --signers DiemRoot Alice
script{
    use DiemFramework::EthSignature;

    fun main() {
        // positive: recover public key
        let data = b"Some data";
        let valid_pubkey = x"2c7536E3605D9C16a7a3D7b1898e529396a65c23";
        let valid_signature = x"b91467e570a6466aa9e9876cbcd013baba02900b8979d43fe208a4a4f339f5fd6007e74cd82e037b800186422fc2da167c747ef045e5d18a5f5d4300f8e1a0291c";
        assert!(copy valid_pubkey == EthSignature::recover(copy valid_signature, copy data), 1);

        // positive : verify valid signature
        assert!(EthSignature::verify(copy valid_signature, copy valid_pubkey, copy data) == true, 2);

        // negative: bad keys
        let zero_pubkey = x"0000000000000000000000000000000000000000";
        let short_pubkey = x"0100";
        // concatenation of the two above
        let long_pubkey = x"2c7536E3605D9C16a7a3D7b1898e529396a65c232c7536E3605D9C16a7a3D7b1898e529396a65c23";
        let invalid_pubkey = x"0000000000000000000000000000000000001111";

        // recover
        assert!(EthSignature::recover(copy short_pubkey, copy data) == copy zero_pubkey, 1001);
        assert!(EthSignature::recover(copy long_pubkey, copy data) == copy zero_pubkey, 1002);
        assert!(EthSignature::recover(copy invalid_pubkey, copy data) == copy zero_pubkey, 1002);

        // verify 
        assert!(!EthSignature::verify(copy valid_signature, copy short_pubkey, copy data), 1003);
        assert!(!EthSignature::verify(copy valid_signature, copy long_pubkey, copy data), 1004);
        assert!(!EthSignature::verify(copy valid_signature, copy invalid_pubkey, copy data), 1005);

        // negative: bad signature
        let short_signature = x"0100";
        let long_signature = x"0062d6be393b8ec77fb2c12ff44ca8b5bd8bba83b805171bc99f0af3bdc619b20b8bd529452fe62dac022c80752af2af02fb610c20f01fb67a4d72789db2b8b703";
        let invalid_signature = x"cc1467e570a6466aa9e9876cbcd013baba02900b8979d43fe208a4a4f339f5fd6007e74cd82e037b800186422fc2da167c747ef045e5d18a5f5d4300f8e1a0291c";
        assert!(!EthSignature::verify(copy short_signature, copy valid_pubkey, copy data), 1006);
        assert!(!EthSignature::verify(copy long_signature, copy valid_pubkey, copy data), 1007);
        assert!(!EthSignature::verify(copy invalid_signature, copy valid_pubkey, copy data), 1008);

        // negative : bad data
        let invalid_data = b"hello";
        // recover
        assert!(EthSignature::recover(copy valid_pubkey, copy invalid_data) == copy zero_pubkey, 1009);
        // verify
        assert!(!EthSignature::verify(copy valid_signature, copy valid_pubkey, invalid_data), 1010);
    }
}