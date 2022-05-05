//! account: alice

//! new-transaction
//! sender: alice
script {
use DiemFramework::Decimal;

fun main(_s: signer) {
    //////// POWER ////////
    let left = Decimal::new(true, 200, 2);
    let right = Decimal::new(true, 2, 0);

    let res = Decimal::power(&left, &right);
    assert!(Decimal::borrow_int(&res) == &4, 7357005);


    // test negative powers with decimals
    let left = Decimal::new(true, 2, 0);
    let right = Decimal::new(false, 123, 2);

    let res = Decimal::power(&left, &right);
    assert!(Decimal::borrow_int(&res) == &4263174467315223084025448727, 7357006);
}
}
