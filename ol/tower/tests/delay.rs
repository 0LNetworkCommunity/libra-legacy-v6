//! Functional test for delay module

#![forbid(unsafe_code)]
use tower::delay;

#[test]
fn test_do_delay() {
    // use a test pre image and a 100 difficulty
    let proof = delay::do_delay(b"test preimage");

    // print to copy/paste the correct_proof string below.
    println!("proof:\n{:?}", hex::encode(&proof));

    let correct_proof = hex::decode("00033705de61e5afdaac23066e66c4844f182a1f50a55e062ab0be9571528caab8a4bfb7bb9ca64817140283d63cedc1145efbcca7b1e263f23ed98100dae329e7b778c64017b251474072dbe0c2603accd45ebbb2625ce04c7857ab7c4cd6bc8d3e0956bffc8e69d825dcd32ae15f0c6ea18a8aff184f7234bf54c6bb7b546259fffef303ffe5ae453accf251a4b580a1cbd0d2fc1b04193c68bf98ad2752242f62aaa76336e392275517f3427ad639876310c1e92d94cae3ffa01fb473cb4cd9f865201c16ad38b6e16646a2501058c009596e9ce52f09ad4f9ab428e28f6e9216ce82563322a2f1eabea36ee6e399a765da557d562158f490303fea002bc0ac49000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001").unwrap();

    //println!("decoded:\n{:?}", correct_proof);

    assert_eq!(proof, correct_proof, "proof is incorrect");
}
