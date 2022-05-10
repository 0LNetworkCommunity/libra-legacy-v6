//# init --validators Alice

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::Decimal;

    fun main(_dr: signer, _s: signer) {
        // Irrational numbers 28 decimal point precision
        let three = Decimal::new(true, 3, 0);
        let root = Decimal::sqrt(&three);
        // assert!(Decimal::borrow_int(&root) == &17320508075688772935274463415, 7357008);

        let (sign, int, scale) = Decimal::unwrap(&root);
        assert!(sign, 7357009); 
        assert!(int == 17320508075688772935274463415, 7357010);
        assert!(scale == 28, 7357011);
    }
}