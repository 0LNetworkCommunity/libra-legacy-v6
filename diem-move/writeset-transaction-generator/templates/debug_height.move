script {
    use DiemFramework::Testnet;
    use DiemFramework::DiemConfig;

    fun main(diem_root: signer) {
        Testnet::initialize(&diem_root);
        DiemConfig::upgrade_reconfig(&diem_root);
    }
}