//! account: alice

//! new-transaction
//! sender: alice
script {
use 0x1::Decimal;
use 0x1::Debug::print;

fun main(_s: signer) {
    // Irrational numbers 28 decimal point precision
    let three = Decimal::new(true, 3, 0);
    let root = Decimal::sqrt(&three);
    print(&root);
    assert(Decimal::borrow_int(&root) == &17320508075688772935274463415, 7357008);

    let (sign, int, scale) = Decimal::unwrap(&ten);
    assert(sign, 7357009); 
    assert(int == 17320508075688772935274463415, 7357010);
    assert(scale == 28, 7357011);
}
}
