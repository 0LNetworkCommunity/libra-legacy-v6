address 0x1 {
module OracleScripts {
    use 0x1::Oracle;
    public(script) fun ol_oracle_tx(sender: signer, id: u64, data: vector<u8>) {
        Oracle::handler(&sender, id, data);
    }
}
}