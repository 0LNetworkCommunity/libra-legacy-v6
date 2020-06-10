//! account: alice, 1000000, 0, empty
//! account: vivian, 1000000, 0, empty
//! account: bob, 1000000, 0, empty
//! account: alex, 1000000, 0, empty
//! account: bobby
//! account: roberta
//! account: roberto

//! new-transaction
//! sender: roberta
script {
use 0x0::LBR;
use 0x0::LibraAccount;
// send a transaction with metadata and make sure we see it in the PaymentReceivedEvent
fun main() {
    LibraAccount::pay_from_sender_with_metadata<LBR::T>({{roberto}}, 1000, x"deadbeef", x"");
}
}
// check: SentPaymentEvent
// check: deadbeef
// check: ReceivedPaymentEvent
// check: deadbeef
// check: EXECUTED

//! new-transaction
//! sender alice
script {
use 0x0::Stats;
    fun main() {
        Stats::test();
    }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
script {
use 0x0::Stats;
    fun main() {
        Stats::initialize();
    }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
script {
    use 0x0::Stats;
    fun main(){
        Stats::add_stuff();
        Stats::p_addr({{default}});
    }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
script {
    use 0x0::Stats;
    use 0x0::Transaction;
    use 0x0::Debug;
    fun main(){
        Stats::remove_stuff();
        Stats::p_addr({{alice}});
        let a = 200;
        Debug::print(&a);
        let b = Transaction::sender();
        Debug::print(&b);
    }
}
// check: EXECUTED
