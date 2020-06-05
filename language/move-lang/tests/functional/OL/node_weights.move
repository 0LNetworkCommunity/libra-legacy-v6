//! account: alice, 8
//! account: bob, 7
//! account: carol, 6
//! account: sha, 9
//! account: hola, 10

// Base Case: If n is greater than or equal to vector length, return vector itself    
// N equal to vector - lengths are the same.
 
//! new-transaction
script {
use 0x0::Vector;
use 0x0::Transaction;
use 0x0::NodeWeight;

fun main() {
    let vec = Vector::empty();

    Vector::push_back<address>(&mut vec, {{alice}});
    Vector::push_back<address>(&mut vec, {{bob}});
    Vector::push_back<address>(&mut vec, {{carol}});
    Vector::push_back<address>(&mut vec, {{sha}});
    Vector::push_back<address>(&mut vec, {{hola}});

    let equals_test = NodeWeight::top_n_accounts(vec,5);
    Transaction::assert(Vector::length<address>(&equals_test) == 5, 1);
}
}
// check: EXECUTED

// Base Case: If n is greater than or equal to vector length, return vector itself    
// N greater than the vector length
//! new-transaction
script {
use 0x0::Vector;
use 0x0::Transaction;
use 0x0::NodeWeight;

fun main() {
    let vec = Vector::empty();

    Vector::push_back<address>(&mut vec, {{alice}});
    Vector::push_back<address>(&mut vec, {{bob}});
    Vector::push_back<address>(&mut vec, {{carol}});
    Vector::push_back<address>(&mut vec, {{sha}});
    Vector::push_back<address>(&mut vec, {{hola}});

    let greater_than_test = NodeWeight::top_n_accounts(vec,5);
    Transaction::assert(Vector::length<address>(&greater_than_test) == 5, 1);
}
}
// check: EXECUTED
