//! account: dummy-prevents-genesis-reload, 100000 ,0, validator

//! new-transaction
//! sender: association
script {
use 0x0::Libra;
use 0x0::GAS;
use 0x0::Transaction;
fun main() {
    Transaction::assert(Libra::approx_lbr_for_value<GAS::T>(10) == 10, 1);
    Transaction::assert(Libra::scaling_factor<GAS::T>() == 1000000, 2);
    Transaction::assert(Libra::fractional_part<GAS::T>() == 1000, 3);
}
}
// check: EXECUTED