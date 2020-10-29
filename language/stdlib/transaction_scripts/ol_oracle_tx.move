

script {
    use 0x0::Oracle;
    use 0x0::Debug::print;
    fun main (sender: &signer, id: u64, data: vector<u8>) {
        print(&0x0000000000000000000000000011e110); // Hello!
        Oracle::handler(sender, id, data);
    }
}

