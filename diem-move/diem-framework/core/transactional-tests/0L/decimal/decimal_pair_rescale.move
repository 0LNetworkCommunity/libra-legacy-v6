//! account: alice

//! new-transaction
//! sender: alice
script {
use DiemFramework::Decimal;

fun main(_s: signer) {
    //////// RESCALE ////////
    let left = Decimal::new(true, 123, 2);
    let right = Decimal::new(true, 6, 0);

    let res = Decimal::rescale(&left, &right);
    assert!(Decimal::borrow_int(&res) == &1230000, 7357007);
}
}
