

script {
    use 0x1::Oracle;
    fun ol_oracle_tx(sender: &signer, id: u64, data: vector<u8>) {
        Oracle::handler(sender, id, data);
    }
}

