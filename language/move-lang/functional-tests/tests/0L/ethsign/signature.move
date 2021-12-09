// Tests for ethereum signature functions 
// Tests are ported from here: https://github.com/gakonst/ethers-rs/blob/master/ethers-core/src/types/signature.rs

//! account: alice

//! new-transaction
script{
    use 0x1::EthSignature;
    fun main() {
        // test1 : recover public key
        let sign = x"aa231fbe0ed2b5418e6ba7c19bee2522852955ec50996c02a2fe3e71d30ddaf1645baf4823fea7cb4fcc7150842493847cfb6a6d63ab93e8ee928ee3f61f503500";
        let pub = EthSignature::recover(copy sign);
        assert(sign == pub, 1);

    }
}
