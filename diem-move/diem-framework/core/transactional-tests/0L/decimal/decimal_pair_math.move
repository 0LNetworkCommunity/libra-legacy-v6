//# init --validators Alice

//# run --admin-script --signers DiemRoot Alice
script {
use DiemFramework::Decimal;

    fun main(_dr: signer, _s: signer) {
        let (sign, int, scale) = Decimal::pair(1, 0, true, 123, 2, true, 456, 2);
        assert!(sign, 7357001);
        assert!(int == 579, 7357002);
        assert!(scale == 2, 7357003);

        //////// ADD ////////

        let left = Decimal::new(true, 123, 2);
        let right = Decimal::new(true, 456, 2);

        let sum = Decimal::add(&left, &right);
        assert!(Decimal::borrow_int(&sum) == &579, 7357004);

        //////// SUB ////////

        let left = Decimal::new(true, 500, 2);
        let right = Decimal::new(true, 200, 2);

        let res = Decimal::sub(&left, &right);
        assert!(Decimal::borrow_int(&res) == &3, 7357005);

        //////// MULT ////////

        let two = Decimal::new(true, 2, 0);
        let mul = Decimal::mul(&two, &two);
        assert!(Decimal::borrow_int(&mul) == &4, 7357006);

        let neg_one = Decimal::new(false, 1, 0);
        let res = Decimal::mul(&two, &neg_one);
        assert!(Decimal::borrow_int(&res) == &2, 7357007);
        assert!(Decimal::borrow_sign(&res) == &false, 7357008);

        //////// DIV ////////

        let hundred = Decimal::new(true, 100, 0);
        let res = Decimal::div(&hundred, &two);
        assert!(Decimal::borrow_int(&res) == &50, 7357009);
    }
}
