script {
    use DiemFramework::DiemSystem;
    use DiemFramework::Epoch;
    use DiemFramework::DiemBlock;
    fun main(diem_root: signer, vals: vector<address>) {
        let height = DiemBlock::get_current_block_height();
        Epoch::reset_timer(&diem_root, height);
        DiemSystem::bulk_update_validators(&diem_root, vals);
    }
}
