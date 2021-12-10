// Tests for ethereum signature functions 
// Tests are ported from here: https://web3js.readthedocs.io/en/v1.2.2/web3-eth-accounts.html#sign 

//! account: alice

//! new-transaction
script{
    use 0x1::EthSignature;
    fun main() {

        let data = b"Some data";
        let expected_pubkey = x"2c7536E3605D9C16a7a3D7b1898e529396a65c23";
        let sign = x"b91467e570a6466aa9e9876cbcd013baba02900b8979d43fe208a4a4f339f5fd6007e74cd82e037b800186422fc2da167c747ef045e5d18a5f5d4300f8e1a0291c";

        // test1 : recover public key
        let pubkey = EthSignature::recover(copy sign, copy data);
        assert(expected_pubkey == pubkey, 1);

        // test2 : verify signature
        //let res = EthSignature::verify(copy sign, copy pubkey, copy data);
        //assert(res == true, 1);

    }
}
