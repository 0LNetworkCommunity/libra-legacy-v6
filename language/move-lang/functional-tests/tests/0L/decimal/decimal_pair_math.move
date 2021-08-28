//! account: alice

//! new-transaction
//! sender: alice
script {
use 0x1::Decimal;
use 0x1::Debug::print;

fun main(_s: signer) {
    let (sign, int, scale) = Decimal::pair_op(1, 0, true, 123, 2, true, 456, 2);
    assert(sign, 7357001);
    assert(int == 579, 7357002);
    assert(scale == 2, 7357003);


    //////// ADD ////////
    let left = Decimal::new(true, 123, 2);
    let right = Decimal::new(true, 456, 2);

    let sum = Decimal::add(&left, &right);
    assert(Decimal::borrow_int(&sum) == &579, 7357004);

    //////// SUB ////////

    // let left = Decimal::new(true, 123, 2);
    // let right = Decimal::new(true, 456, 2);

    // let sum = Decimal::add(&left, &right);
    // assert(Decimal::borrow_int(&sum) == &579, 7357004);

    //////// MULT ////////

    let two = Decimal::new(true, 2, 0);
    let sqrt_two = Decimal::sqrt(&two);
    // print(&mul);
    let mul = Decimal::mul(&two, &sqrt_two);
    print(&mul);
    let multwo = Decimal::mul(&sqrt_two, &sqrt_two);
    print(&multwo);

    //////// DIV ////////

    // let two = Decimal::new(true, 2, 0);
    // let sqrt_two = Decimal::sqrt(&two);
    // // print(&mul);
    // let mul = Decimal::mul(&two, &sqrt_two);
    // print(&mul);
    // let multwo = Decimal::mul(&sqrt_two, &sqrt_two);
    // print(&multwo);

}
}
