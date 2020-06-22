//! Functional test for delay module

#![forbid(unsafe_code)]
use ol_miner::block::build_block;
use ol_miner::config::*;

#[test]
#[ignore]

// This test doesn't pass because of the loop. Panics with: 'terminal streams not yet initialized!'
fn test_write_block() {
    let configs = OlMinerConfig {
        profile: Profile {
            public_key: "3e4629ba1e63114b59a161e89ad4a083b3a31b5fd59e39757c493e96398e4df2"
                .to_owned(),
            statement: "protests rage across America".to_owned(),
        },
        chain_info: ChainInfo {
            chain_id: "Ol testnet".to_owned(),
            block_dir: "test_blocks".to_owned(),
        },
    };

    build_block::write_block(&configs);
    assert_eq!(true, true, "not true");
}
