//! account: alice, 100000,0, validator

//! new-transaction
//! sender: alice
script {
use 0x1::LibraSystem;
use 0x1::MinerState;
use 0x1::Signer;
use 0x1::Debug::print;


    fun main(sender: &signer) {
        print(&Signer::address_of(sender));
        print(&{{alice}});
        assert(LibraSystem::is_validator({{alice}}) == true, 98);
        print(&MinerState::test_helper_get_height({{alice}}));

        //alice should send a proof transaction here before MinerState is invoked
        assert(MinerState::test_helper_get_height({{alice}}) == 0u64, 73570002);
    }
}
// check: EXECUTED
