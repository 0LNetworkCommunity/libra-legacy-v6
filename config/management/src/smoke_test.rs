// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use crate::{
    layout::Layout, storage_helper::StorageHelper
};
use config_builder::{BuildSwarm, SwarmConfig};
use libra_config::{
    config::{
        DiscoveryMethod, Identity, NetworkConfig, NodeConfig, OnDiskStorageConfig, RoleType,
        SecureBackend, WaypointConfig,
    },
    network_id::NetworkId,
};

use libra_secure_storage::Value;
use libra_swarm::swarm::{LibraNode, LibraSwarm, LibraSwarmDir};
use libra_temppath::TempPath;
use libra_types::account_address;
use std::fs;
use std::path::{Path, PathBuf};

struct ManagementBuilder {
    configs: Vec<NodeConfig>,
}

impl BuildSwarm for ManagementBuilder {
    fn build_swarm(&self) -> anyhow::Result<Vec<NodeConfig>> {
        Ok(self.configs.clone())
    }
}

#[test]
// NOTE: Run this with: cargo xtest -p libra-management smoke_test
fn smoke_test() {
    LibraNode::prepare();
    let helper = StorageHelper::new();
    let num_validators = 5;
    let shared = "_shared";
    let association = "vm";
    // let association_shared = association.to_string() + shared;

    // Step 1) Prepare the layout
    let mut layout = Layout::default();
    // layout.association = vec![association_shared.to_string()];
    layout.operators = (0..num_validators)
        .map(|v| (v.to_string() + shared))
        .collect();

    let mut common_storage = helper.storage(crate::constants::COMMON_NS.into());
    let layout_value = Value::String(layout.to_toml().unwrap());
    common_storage
        .set(crate::constants::LAYOUT, layout_value)
        .unwrap();

    // Step 2) Set association key
    helper.initialize(association.into());
    // helper
    //     .association_key(&association, &association_shared)
    //     .unwrap();

    // Step 3) Prepare validators
    let temppath = TempPath::new();
    temppath.create_as_dir().unwrap();
    let swarm_path = temppath.path().to_path_buf();

    let mut configs = Vec::new();
    for i in 0..num_validators {
        let ns = i.to_string();
        let ns_shared = ns.clone() + shared;

        // Using fixtures to skip the offline steps a person would take to set up their miner.
        // 1. Generate a keypair, and save a mnemonic.
        // 2. Run the miner app for creating a genesis proof. block_0.json

        //NOTE: Files generated with miner/block.rs create_fixtures() which is a test-only function.
        // NOTE there are only fixtures for 5 validators in the /test_fixtures/ directory.
        let mnemonic =
            fs::read_to_string(format!("./test_fixtures/miner_{}/miner_{}.mnem", &ns, &ns))
                .unwrap();
        helper.initialize_with_menmonic(ns.clone(), mnemonic.to_string());
        // helper.initialize_with_menmonic(ns.clone(),"version expect kiwi trade flock barely version kangaroo believe estate two wash kingdom fringe evoke unfold grass time lyrics blade robot door tomorrow rail".to_string());

        // Mine a block in the 0L miner folder
        helper
            .mining(
                &format!("./test_fixtures/miner_{}/block_0.json", &ns),
                &ns_shared,
            )
            .unwrap();

        let operator_key = helper.operator_key(&ns, &ns_shared).unwrap();

        let validator_account = account_address::from_public_key(&operator_key);
        let mut config = NodeConfig::default();

        let mut network = NetworkConfig::network_with_id(NetworkId::Validator);
        network.discovery_method = DiscoveryMethod::None;
        config.validator_network = Some(network);

        let mut network = NetworkConfig::network_with_id(NetworkId::vfn_network());
        network.discovery_method = DiscoveryMethod::None;
        config.full_node_networks = vec![network];
        config.randomize_ports();

        let validator_network = config.validator_network.as_mut().unwrap();
        let validator_network_address = validator_network.listen_address.clone();
        validator_network.identity = Identity::from_storage(
            libra_global_constants::VALIDATOR_NETWORK_KEY.into(),
            libra_global_constants::OPERATOR_ACCOUNT.into(),
            secure_backend(helper.path(), &swarm_path, &ns, "validator"),
        );

        let fullnode_network = &mut config.full_node_networks[0];
        let fullnode_network_address = fullnode_network.listen_address.clone();
        fullnode_network.identity = Identity::from_storage(
            libra_global_constants::FULLNODE_NETWORK_KEY.into(),
            libra_global_constants::OPERATOR_ACCOUNT.into(),
            secure_backend(helper.path(), &swarm_path, &ns, "full_node"),
        );

        configs.push(config);

        //TODO: Duplicated here.
        helper.operator_key(&ns, &ns_shared).unwrap();
        helper
            .validator_config(
                validator_account,
                validator_network_address,
                fullnode_network_address,
                &ns,
                &ns_shared,
            )
            .unwrap();
    }

    // Step 4) Produce genesis and introduce into node configs
    let genesis_path = TempPath::new();
    genesis_path.create_as_file().unwrap();
    let genesis = helper.genesis(genesis_path.path()).unwrap();

    // Step 5) Introduce waypoint and genesis into the configs and verify along the way
    for (i, mut config) in configs.iter_mut().enumerate() {
        let ns = i.to_string();
        let waypoint = helper.create_waypoint(&ns).unwrap();
        let output = helper.verify_genesis(&ns, genesis_path.path()).unwrap();
        // 4 matches = 5 splits
        assert_eq!(output.split("match").count(), 5);

        config.consensus.safety_rules.backend =
            secure_backend(helper.path(), &swarm_path, &ns, "safety-rules");

        if i == 0 {
            // This is unfortunate due to the way SwarmConfig works
            config.base.waypoint = WaypointConfig::FromConfig { waypoint };
        } else {
            let backend = secure_backend(helper.path(), &swarm_path, &ns, "waypoint");
            config.base.waypoint = WaypointConfig::FromStorage { backend };
        }
        config.execution.genesis = Some(genesis.clone());
    }

    // Step 6) Build configuration for Swarm
    let management_builder = ManagementBuilder { configs };

    let mut swarm = LibraSwarm {
        dir: LibraSwarmDir::Temporary(temppath),
        nodes: std::collections::HashMap::new(),
        config: SwarmConfig::build(&management_builder, &swarm_path).unwrap(),
    };

    // Step 7) Launch and exit!
    swarm.launch_attempt(RoleType::Validator, false).unwrap();
}

// #[test]
// NOTE: Run this with: cargo xtest -p libra-management smoke_test
// fn smoke_test_github() {
//     // 1. Create Set Layout File (as association) - ok
//     // 2. Creaste a mnemonic - ok
//     // 3. create a proof - ok
//     // 4. (initialize). Initialize local storage with mnemonic. Private keys saved to disk (json). - ok
//     // 5. (mining) Add proof data from mining to key_store.json - ok
//     // 6. (operator-key) Add operator key to remote storage. (and collect account address) - ok
//     // 7. (validator-config) generate validator config transaction for remote NOTE: needs network address. - ok
//     // 8. Build genesis - ok
//     // 9. Create waypoint - ok
//     // 10. Update Node.config.toml file with all data

//     LibraNode::prepare();
//     let helper = StorageHelperGithub::new();
//     let num_validators = 1;
//     let _association = "vm";

//     // Step 1) Prepare the layout

//     // TODO: Remove this step if possible. This is duplicated with set layout below.
//     // TODO: verify_genesis complains if there is no REMOTE information on the SetLayout
//     // TODO: set_layout fails silently if there is no OWNER or ASSOCIATION fields
//     helper.set_layout_remote();

//     // Step 3) Prepare validators.
//     // This simulates EACH validator going through their genesis ceremony steps.
//     for i in 0..num_validators {
//         println!("Validator #{}", i);
//         let ns = i.to_string();

//         // NOTE: Files generated with miner/block.rs create_fixtures() which is a test-only function.
//         // there are only fixtures for 5 validators in the /test_fixtures/ directory.
//         let mnemonic =
//             fs::read_to_string(format!("./test_fixtures/miner_{}/miner_{}.mnem", &ns, &ns))
//                 .unwrap();
//         println!("mnemonic\n");

//         fs::remove_file(format!("./test_fixtures/miner_{}/key_store.json", &ns));

//         helper.initialize_command(
//             mnemonic.to_string(),
//             format!("./test_fixtures/miner_{}", &ns),
//             ns.clone(),
//         );

//         println!("mining\n");

//         helper
//             .mining(&format!("./test_fixtures/miner_{}/block_0.json", &ns), &ns)
//             .unwrap();

//         println!("set layout\n");

//         //TODO: create_waypoint complains if there is no local information on the SetLayout
//         helper.set_layout_local(
//             &ns,
//             &format!("./test_fixtures/miner_{}/miner_{}.mnem", &ns, &ns),
//         );

//         println!("operator key\n");

//         let operator_key = helper.operator_key(&ns).unwrap();

//         let validator_account = account_address::from_public_key(&operator_key);

//         // TODO: Get node.config.toml file with network info.
//         // let mut config = NodeConfig::default();

//         println!("validator config\n");
//         helper
//             .validator_config(
//                 validator_account,
//                 "/ip4/0.0.0.0/tcp/6180",
//                 "/ip4/0.0.0.0/tcp/6180",
//                 &format!("./test_fixtures/miner_{}/key_store.json", &ns),
//                 &ns,
//             )
//             .unwrap();
//     }

//     // Assuming all steps above are OK. The validators can now build the genesis.
//     println!("genesis\n");

//     let genesis = helper.genesis("./test_fixtures/genesis.blob").unwrap();

//     for i in 0..num_validators {
//         // Each validator again can generate a waypoint and save to storage.

//         // Step 5) Introduce waypoint and genesis into the configs and verify along the way

//         println!("\nValidator #{}\n", i);
//         let ns = i.to_string();
//         println!("\nwaypoint\n");

//         // TODO: PLZ HALP.
//         let waypoint = helper.create_waypoint(&ns).unwrap();

//         println!("\nverify\n");
//         //
//         let output = helper
//             .verify_genesis(
//                 &format!("./test_fixtures/miner_{}/key_store.json", &ns),
//                 "./test_fixtures/genesis.blob",
//             )
//             .unwrap();

//         // let output =  helper.verify_genesis_remote().unwrap();
//         println!("{}", output);

//         //TODO: Validators need to create/update a node.config.file.
//     }
// }

fn secure_backend(original: &Path, dst_base: &Path, ns: &str, usage: &str) -> SecureBackend {
    let mut dst = dst_base.to_path_buf();
    dst.push(format!("{}_{}", usage, ns));
    std::fs::copy(original, &dst).unwrap();

    let mut storage_config = OnDiskStorageConfig::default();
    storage_config.path = dst;
    storage_config.set_data_dir(PathBuf::from(""));
    storage_config.namespace = Some(ns.into());
    SecureBackend::OnDiskStorage(storage_config)
}
