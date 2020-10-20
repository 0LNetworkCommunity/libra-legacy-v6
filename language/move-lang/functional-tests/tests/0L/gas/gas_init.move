
//! new-transaction
//! sender: blessed
script {
use 0x1::Libra;
use 0x1::GAS::GAS;
fun main() {
    assert(Libra::approx_lbr_for_value<GAS>(10) == 10, 1);
    assert(Libra::scaling_factor<GAS>() == 1000000, 2);
    assert(Libra::fractional_part<GAS>() == 1000, 3);
}
}
// check: "Keep(EXECUTED)"