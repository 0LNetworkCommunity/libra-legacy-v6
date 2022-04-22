//! account: alice

//! new-transaction
//! sender: alice
script {
use DiemFramework::Decimal;

fun main(_s: signer) {
    // MUL
    let two = Decimal::new(true, 2, 0);
    let neg_one = Decimal::new(false, 1, 0);
    let res = Decimal::mul(&two, &neg_one);
    assert!(Decimal::borrow_sign(&res) == &false, 7357007);
    assert!(Decimal::borrow_int(&res) == &2, 7357008);
    assert!(Decimal::borrow_scale(&res) == &0, 7357009);

    let neg_two = Decimal::new(false, 2, 0);
    let neg_one = Decimal::new(false, 1, 0);
    let res = Decimal::mul(&neg_two, &neg_one);
    assert!(Decimal::borrow_sign(&res) == &true, 7357007);
    assert!(Decimal::borrow_int(&res) == &2, 7357008);
    assert!(Decimal::borrow_scale(&res) == &0, 7357009);

}
}
