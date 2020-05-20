// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use vdf::{VDFParams, VDF};

mod identifier_prop_tests;


fn main(){
    let challenge = vec![1u8, 2u8, 3u8, 4u8];
    let solution = vec![2u8];
    let p = vdf::WesolowskiVDFParams(1024);
    let v = p.new();
    v.check_difficulty(18);
    let re = v.solve(&challenge, 10);
    match v.verify(&challenge, 1000, &solution) {
        Ok(_) => assert!(true, 1),
        Err(_) => assert!(true, 2),
    }

    println!("ch: {:?}", re.unwrap());

}