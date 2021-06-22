address 0x1 {
module DemoScripts {

    use 0x1::Debug::print;
    public(script) fun demo_e2e (world: u64) {
        print(&0x0000000000000000000000000011e110); // Hello!
        print(&world); // World!
    }

}
}