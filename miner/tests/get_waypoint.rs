//! Functional test for delay module

#![forbid(unsafe_code)]
use std::{fs, io::Write};

use libra_types::waypoint::Waypoint;
use miner::config;
#[test]
fn test_waypoint() {
    let s = config::MinerConfig::default();

    let mut path =  s.workspace.node_home.clone();
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
    let correct: Waypoint = "353000:7ea06291b23bda2c80245026fdf403b3118b6af58e3595d6586ec31b9463be9b".parse().unwrap();
    assert_eq!(data.unwrap(), correct, "json value not equal");
    fs::remove_file(path).unwrap();
}
