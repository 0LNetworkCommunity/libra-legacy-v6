// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use vdf::{VDFParams, VDF};

mod identifier_prop_tests;

#[test]
fn testabc(){
    let challenge = vec![1u8, 2u8, 3u8, 4u8];
    let p = vdf::WesolowskiVDFParams(3);
    let v = p.new();
    v.check_difficulty(18);
    let re = v.solve(&challenge, 10);
    //v.verify()

    println!("ch: {:?}", re.unwrap());

}