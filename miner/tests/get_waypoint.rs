//! Functional test for delay module

#![forbid(unsafe_code)]
use std::{fs, io::Write};

use miner::config;
#[test]
fn test_waypoint() {
    let config = config::MinerConfig::default();

    let mut path =  config.workspace.miner_home.clone();
    fs::create_dir_all(path.to_str().unwrap()).unwrap();
    path.push("key_store.json");
    let mut file = fs::File::create(&path).unwrap();
    let json_data = r#"{
        "alice-oper/genesis-waypoint": {
            "data": "GetResponse",
            "last_update": 1604878411,
            "value": "0:08148a7b1ac857caee13337c77e691734899b7cc82f4968b35455fb91c060df5"
        }
    }"#;

    file.write_all(json_data.as_bytes())
            .expect("Could not write json");
    
    let data = config.get_waypoint();
    assert_eq!(data, "0:08148a7b1ac857caee13337c77e691734899b7cc82f4968b35455fb91c060df5", "json value not equal");
    fs::remove_file(path).unwrap();
}
