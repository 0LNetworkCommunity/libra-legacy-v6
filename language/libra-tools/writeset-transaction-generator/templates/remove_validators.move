script {
    use 0x1::LibraSystem;
    fun main(diem_root: &signer) {
        {{#each addresses}}
        LibraSystem::remove_validator(diem_root, 0x{{this}});
        {{/each}}
    }
}
