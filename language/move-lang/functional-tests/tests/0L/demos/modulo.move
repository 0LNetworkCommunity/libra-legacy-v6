//! account: alice, 1000000, 0, validator
// The data will be initialized and operated all through alice's account
// module Math {
//     fun div(x: u64, y: u64): (u64, u64) {
//         (x / y, x % y)
//     }
// }
//! new-transaction
//! sender: alice
script {
    // use 0x0::PersistenceTrial;
    use 0x0::Debug;
    // use 0x0::Math;

    fun main(){

    Debug::print(&0x01ee7);
    //         fun modulo(a: u64, b: u64) {
    //   a - (b * int(a/b))
    // }
    let a = 4 % 3;

    Debug::print(&a);


    }


}
// check: EXECUTED
