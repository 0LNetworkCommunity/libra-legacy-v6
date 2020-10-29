// TODO: Maybe move this somewhere else
// Note: this script is used for testing upgrade oracle, it is not included in the staged scripts on purpose
// the compiled .mv file can be found in staged/upgrade_payload/
// IMPORTANT: Must update the compiled staged/upgrade_payload/stdlib.mv file everytime after an actual upgrade to include this script, or the e2e test will fail
script {
    use 0x0::Upgrade;
    use 0x0::Debug::print;
    fun main () {
        print(&0x000000000000000000000000000be110); // Bello!
        Upgrade::foo();
    }
}

