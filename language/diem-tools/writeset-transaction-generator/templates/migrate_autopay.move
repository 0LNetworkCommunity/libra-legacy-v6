script {
    use 0x1::MigrateAutoPayBal;
    // use 0x1::DiemConfig;
    fun main(diem_root: signer) {
        MigrateAutoPayBal::do_it(&diem_root);
        // DiemConfig::upgrade_reconfig(&diem_root);
    }
}


