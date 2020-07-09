//! new-transaction
// Subsidy minting should work
//! sender: association
script {
use 0x0::OLConfig;
use 0x0::Debug;
fun main() {
    Debug::print(&OLConfig::get_ol_u64constant(0,0));
    Debug::print(&OLConfig::get_ol_u64constant(1,0));
}
}