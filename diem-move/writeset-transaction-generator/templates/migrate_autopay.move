script {
    use DiemFramework::MigrateAutoPayBal;
    // use DiemFramework::DiemConfig;
    fun main(diem_root: signer) {
        MigrateAutoPayBal::do_it(&diem_root);
        // DiemConfig::upgrade_reconfig(&diem_root);
    }
}