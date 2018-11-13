// Copyright 2018 Chia Network Inc and Block Notary Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// and limitations under the License.#![forbid(unsafe_code)]
#![deny(warnings)]
#![forbid(unsafe_code)]
use std::u64;
extern crate gmp;
use gmp::mpz::Mpz;
extern crate vdf;
#[macro_use]
extern crate clap;

fn is_bigint_ok(obj: String) -> Result<(), String> {
    Mpz::from_str_radix(&obj, 0)
        .map(drop)
        .map_err(|x| format!("{:?}", x))
}
fn is_u64_ok(obj: String) -> Result<(), String> {
    u64::from_str_radix(&obj, 10)
        .map(drop)
        .map_err(|x| format!("{:?}", x))
}
fn main() {
    let _matches = clap_app!(myapp =>
        (version: crate_version!())
        (author: "Block Notary <poa.networks>")
        (about: "CLI to Verifiable Delay Functions")
        (@arg DISCRIMINANT: +required {is_bigint_ok} "The discriminant" )
        (@arg NUM_ITERATIONS: +required  {is_u64_ok} "The number of iterations")
    )
    .get_matches();
    let iterations = value_t!(_matches, "NUM_ITERATIONS", u64).unwrap();
    let discriminant = Mpz::from_str_radix(_matches.value_of("DISCRIMINANT").unwrap(), 0).unwrap();
    println!("{}", vdf::do_compute(&discriminant, iterations))
}
