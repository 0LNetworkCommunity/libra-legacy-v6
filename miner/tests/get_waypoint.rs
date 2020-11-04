//! Functional test for delay module

#![forbid(unsafe_code)]
use std::{fs, io::Write};

use miner::config;
#[test]
fn test_waypoint() {
    let s = config::MinerConfig::default();

    let mut path =  s.workspace.miner_home.clone();
    path.push("key_store.json");
    let mut file = fs::File::create(&path).unwrap();
    let json_data = r#"{
            "alice/waypoint": {
            "data": "GetResponse",
            "last_update": 1602189250,
            "value": {
                "type": "string",
                "value": "353000:7ea06291b23bda2c80245026fdf403b3118b6af58e3595d6586ec31b9463be9b"
            }
        }
    }"#;

    file.write_all(json_data.as_bytes())
            .expect("Could not write json");
    
    let data = s.get_waypoint();
    assert_eq!(data, "353000:7ea06291b23bda2c80245026fdf403b3118b6af58e3595d6586ec31b9463be9b", "json value not equal");
    fs::remove_file(path).unwrap();
}
