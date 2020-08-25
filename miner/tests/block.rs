//! Functional test for delay module

#![forbid(unsafe_code)]
use libra_types::waypoint::Waypoint;
use miner::block::build_block;
use miner::config::*;
use std::path::PathBuf;

#[test]
#[ignore]

// This test doesn't pass because of the loop. Panics with: 'terminal streams not yet initialized!'
fn test_mine_and_submit() {
    let configs = OlMinerConfig {
        workspace: Workspace {
            home: PathBuf::from("."),
        },
        profile: Profile {
            // public_key: "5ffd9856978b5020be7f72339e41a401".to_owned(),
            // statement: "protests rage across America".to_owned(),
            auth_key: "5ffd9856978b5020be7f72339e41a401".to_owned(),
            account: None,
            operator_private_key: None,
            ip: None,
            statement: "Protests rage across the nation".to_owned(),
        },
        chain_info: ChainInfo {
            chain_id: "0L testnet".to_owned(),
            block_dir: "test_blocks".to_owned(),
            base_waypoint: "0:8859e663dfc13a44d2b67b11bfa4bf7679c61691de5fb0c483c4874b4edae35b"
                .to_owned(),
            node: None,
        },
    };

    let parsed_waypoint: Waypoint = configs.chain_info.base_waypoint.parse().unwrap();

    let _start_app = build_block::mine_and_submit(&configs, "test mnemonic".to_string(), parsed_waypoint);

    // assert_eq!(Ok(()), start_app, "not true");
}
