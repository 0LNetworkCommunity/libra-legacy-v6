//! account: alice

//! new-transaction
//! sender: alice
script {
use DiemFramework::Decimal;

fun main(_s: signer) {
    // test pair_op function.
    let (sign, int, scale) = Decimal::pair_op(1, 0, true, 123, 2, true, 456, 2);
    assert!(sign, 7357001);
    assert!(int == 579, 7357002);
    assert!(scale == 2, 7357003);
}
}
