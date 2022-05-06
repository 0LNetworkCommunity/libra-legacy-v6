script {
    use 0x1::DiemSystem;
    use 0x1::Epoch;
    use 0x1::DiemBlock;
    fun main(diem_root: signer, vals: vector<address>) {
        let height = DiemBlock::get_current_block_height();
        Epoch::reset_timer(&diem_root, height);
        DiemSystem::bulk_update_validators(&diem_root, vals);
        
    }
}
