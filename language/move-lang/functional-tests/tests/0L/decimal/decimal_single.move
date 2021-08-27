//! account: alice

//! new-transaction
//! sender: alice
script {
use 0x1::Decimal;

fun main(_s: signer) {
    let (sign, int, scale) = Decimal::single_op(5, true, 100, 0);

    assert(sign, 7357001);
    assert(int == 10, 7357002);
    assert(scale == 0, 7357003);

    let hundred = Decimal::new(true, 100, 0);
    let ten = Decimal::sqrt(&hundred);
    assert(Decimal::borrow_int(&ten) == &10, 7357004);

    let (sign, int, scale) = Decimal::unwrap(&ten);
    assert(sign, 7357005);
    assert(int == 10, 7357006);
    assert(scale == 0, 7357007);
}
}
