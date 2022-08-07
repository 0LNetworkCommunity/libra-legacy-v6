script {
    use 0x1::Testnet;
    use 0x1::DiemConfig;
    fun main(diem_root: signer) {
        Testnet::initialize(&diem_root);
        DiemConfig::upgrade_reconfig(&diem_root);
    }
}
