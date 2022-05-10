//# init --validators Alice

//# run --admin-script --signers DiemRoot Alice
script {
use DiemFramework::Decimal;

    fun main(_dr: signer, _s: signer) {
        // test pair function.
        let (sign, int, scale) = Decimal::pair(1, 0, true, 123, 2, true, 456, 2);
        assert!(sign, 7357001);
        assert!(int == 579, 7357002);
        assert!(scale == 2, 7357003);
    }
}