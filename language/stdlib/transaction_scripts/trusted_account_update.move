script {
    use 0x1::Debug::print;
    fun trusted_account_update_tx(world: u64) {
        print(&0x0000000000000000000000000011e110); // Hello!
        print(&world); // World!
    }
}
