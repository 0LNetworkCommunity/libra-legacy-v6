//! Functional test for delay module

#![forbid(unsafe_code)]
use std::{fs, io::Write};

use miner::config;
#[test]
fn test_waypoint() {
    let s = config::OlMinerConfig::default();

    let mut path =  s.workspace.miner_home.clone();
    path.push("key_store.json");
    let mut file = fs::File::create(&path).unwrap();
    let json_data = r#"{
        "1234/waypoint":"hello"
    }"#;

    file.write_all(json_data.as_bytes())
            .expect("Could not write json");
    let data = s.get_waypoint();
    assert_eq!(data, "hello", "json value not equal");
    fs::remove_file(path).unwrap();
}
