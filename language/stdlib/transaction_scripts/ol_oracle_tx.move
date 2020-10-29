

script {
    use 0x1::Oracle;
    use 0x1::Debug::print;
    fun ol_oracle_tx (sender: &signer, id: u64, data: vector<u8>) {
        print(&0x0000000000000000000000000011e110); // Hello!
        Oracle::handler(sender, id, data);
    }
}

