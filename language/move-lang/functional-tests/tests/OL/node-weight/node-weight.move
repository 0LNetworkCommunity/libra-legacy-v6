//! account: alice, 8
//! account: bob, 7
//! account: carol, 6
//! account: sha, 9
//! account: hola, 10


//! new-transaction
script {
    use 0x0::Vector;
    use 0x0::Transaction;
    use 0x0::NodeWeight;
    // Base Case: If n is greater than or equal to vector length, return vector itself    
    // Test that length is the same. 
    // N equal to vector length       
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

//! new-transaction
script {
    use 0x0::Vector;
    use 0x0::Transaction;
    use 0x0::NodeWeight;
    // Base Case: If n is greater than or equal to vector length, return vector itself    
    // N greater than the vector length
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

//! new-transaction
script {
    use 0x0::Vector;
    use 0x0::Transaction;
    use 0x0::NodeWeight;

    // n is less than vector length. We need top N.   
    // Top 1 account test. N=1 vector has 5 addresses
    fun main() {
        let vec = Vector::empty();

        Vector::push_back<address>(&mut vec, {{alice}});
        Vector::push_back<address>(&mut vec, {{bob}});
        Vector::push_back<address>(&mut vec, {{carol}});
        Vector::push_back<address>(&mut vec, {{sha}});
        Vector::push_back<address>(&mut vec, {{hola}});

        let result = NodeWeight::top_n_accounts(vec,1);
        Transaction::assert(Vector::length<address>(&result) == 1, 1);
        Transaction::assert(Vector::contains<address>(&result, &{{hola}}) == true, 1);
            
    }
}
// check: EXECUTED

//! new-transaction
script {
    use 0x0::Vector;
    use 0x0::Transaction;
    use 0x0::NodeWeight;

    // n is less than vector length. We need top N.   
    // Top 3 account test. N=3 vector has 5 addresses
    fun main() {
        let vec = Vector::empty();

        Vector::push_back<address>(&mut vec, {{alice}});
        Vector::push_back<address>(&mut vec, {{bob}});
        Vector::push_back<address>(&mut vec, {{carol}});
        Vector::push_back<address>(&mut vec, {{sha}});
        Vector::push_back<address>(&mut vec, {{hola}});

        let result = NodeWeight::top_n_accounts(vec,3);
        Transaction::assert(Vector::length<address>(&result) == 3, 1);
        Transaction::assert(Vector::contains<address>(&result, &{{hola}}) == true, 1);
        Transaction::assert(Vector::contains<address>(&result, &{{alice}}) == true, 1);
        Transaction::assert(Vector::contains<address>(&result, &{{sha}}) == true, 1);
            
    }
}
// check: EXECUTED