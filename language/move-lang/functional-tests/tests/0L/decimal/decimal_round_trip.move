//! account: alice

//! new-transaction
//! sender: alice
script {
use 0x1::Decimal;
fun main(_s: signer) {
    let (sign, num, scale) = Decimal::decimal_demo(true, 100, 2);
    assert(sign, 7357001);
    assert(num == 100, 7357002);
    assert(scale == 2, 7357003);
}
}