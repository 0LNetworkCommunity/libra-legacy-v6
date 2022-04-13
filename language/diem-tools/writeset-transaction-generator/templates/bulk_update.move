script {
    use 0x1::DiemSystem;
    fun main(diem_root: signer, vals: vector<address>) {
        DiemSystem::bulk_update_validators(&diem_root, vals);
    }
}
