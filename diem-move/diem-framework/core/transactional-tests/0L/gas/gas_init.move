//# init --validators Alice

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::Diem;
    use DiemFramework::GAS::GAS;

    fun main() {
        assert!(Diem::approx_xdx_for_value<GAS>(10) == 10, 1);
        assert!(Diem::scaling_factor<GAS>() == 1000000, 2);
        assert!(Diem::fractional_part<GAS>() == 1000, 3);
    }
}
// check: "Keep(EXECUTED)"