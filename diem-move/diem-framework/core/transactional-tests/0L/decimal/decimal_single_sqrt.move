//! account: alice

//! new-transaction
//! sender: alice
script {
use DiemFramework::Decimal;

fun main(_s: signer) {
    // do a square root directly with single
    let (sign, int, scale) = Decimal::single(100, true, 100, 0);

    assert!(sign, 7357001);
    assert!(int == 10, 7357002);
    assert!(scale == 0, 7357003);

    // use sqrt helper
    let hundred = Decimal::new(true, 100, 0);
    let ten = Decimal::sqrt(&hundred);
    assert!(Decimal::borrow_int(&ten) == &10, 7357004);

    let (sign, int, scale) = Decimal::unwrap(&ten);
    assert!(sign, 7357005);
    assert!(int == 10, 7357006);
    assert!(scale == 0, 7357007);
}
}
