script {
    use 0x1::DiemSystem;
    fun main(diem_root: signer) {
        {{#each addresses}}
        // loop through all addresses in the system
        Ancestry::remove_validator(&diem_root, @0x{{this}});
        {{/each}}
    }
}
