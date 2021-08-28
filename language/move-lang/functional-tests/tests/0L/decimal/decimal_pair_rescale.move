//! account: alice

//! new-transaction
//! sender: alice
script {
use 0x1::Decimal;
use 0x1::Debug::print;

fun main(_s: signer) {
    //////// RESCALE ////////
    let left = Decimal::new(true, 123, 2);
    let right = Decimal::new(true, 6, 0);

    let res = Decimal::rescale(&left, &right);
    print(&res);
    assert(Decimal::borrow_int(&res) == &1230000, 7357007);
}
}
