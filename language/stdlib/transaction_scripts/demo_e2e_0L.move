script {
    use 0x1::Debug::print;
    fun demo_e2e (world: u64) {
        print(&0x0000000000000000000000000011e110); // Hello!
        print(&world); // World!
    }
}
