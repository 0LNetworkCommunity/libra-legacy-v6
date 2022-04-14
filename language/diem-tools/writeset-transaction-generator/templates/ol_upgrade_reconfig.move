script {
    use 0x1::DiemSystem;
    fun main(diem_root: signer) {
        Upgrade::upgrade_reconfig(&diem_root);
    }
}
