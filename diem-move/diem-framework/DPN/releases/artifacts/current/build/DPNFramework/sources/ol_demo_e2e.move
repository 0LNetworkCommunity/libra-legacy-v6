address DiemFramework {
module DemoScripts {
    use DiemFramework::Debug::print;
    public(script) fun demo_e2e (world: u64) {
        print(&@0x0000000000000000000000000011e110); // Hello!
        print(&999999999999999); // Hello!

        print(&world); // World!
    }
}
}