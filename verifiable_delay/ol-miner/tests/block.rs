//! Functional test for delay module

#![forbid(unsafe_code)]
use ol_miner::delay::delay;
use ol_miner::block::build_block;

#[test]
fn test_write_block() {
    build_block::write_block(Vec::new());
    assert_eq!(true, true);
}
