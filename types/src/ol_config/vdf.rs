use std::env;

pub fn get_difficulty() -> u64 {
    let node_env = env::var("NODE_ENV").unwrap();

    if(node_env == "test") {
        100
    } else {
        1000000 
    }
}

pub const DIFFICULTY: u64 = 1000000;
pub const DIFFICULTY_TEST: u64 = 100;

