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
//use std::num::ParseIntError;
extern crate gmp;
use gmp::mpz::Mpz;
use std::cell::RefCell;
extern crate hex;
extern crate vdf;
#[macro_use]
extern crate clap;

thread_local! {
    static DISCRIMINANT: RefCell<Option<Mpz>> = RefCell::new(None);
    static NUM_ITERATIONS: RefCell<Option<u64>> = RefCell::new(None);
}

fn is_bigint_ok(obj: String) -> Result<(), String> {
    let s = match Mpz::from_str_radix(&obj, 0) {
        Ok(m) => {
            if m >= (-6i64).into() {
                Err("m must be negative and ≤ -7".to_owned())
            } else if (m).probab_prime(if cfg!(debug_assertions) { 40 } else { 1 })
                == gmp::mpz::ProbabPrimeResult::NotPrime
            {
                Err("m must be prime".to_owned())
            } else {
                Ok(DISCRIMINANT.with(|x| assert!(x.replace(Some(m)).is_none())))
            }
        }
        Err(e) => Err(format!("{}: {:?}", e, obj)),
    };
    drop(obj);
    s
}

fn is_u64_ok(obj: String) -> Result<(), String> {
    let s = u64::from_str_radix(&obj, 10)
        .map(|q| NUM_ITERATIONS.with(|x| assert!(x.replace(Some(q)).is_none())))
        .map_err(|x| format!("{}: {:?}", x, obj));
    drop(obj);
    s
}

fn parse_already_checked_args() -> (Mpz, u64) {
    (
        DISCRIMINANT.with(|x| x.borrow_mut().take().unwrap()),
        NUM_ITERATIONS.with(|x| x.borrow_mut().take().unwrap()),
    )
}

fn main() {
    let matches = clap_app!(myapp =>
        (version: crate_version!())
        (author: "Block Notary <poa.networks>")
        (about: "CLI to Verifiable Delay Functions")
        (@subcommand compute =>
            (@arg DISCRIMINANT: +required {is_bigint_ok} "The discriminant" )
            (@arg NUM_ITERATIONS: +required  {is_u64_ok} "The number of iterations")
        )
        (@subcommand prove =>
            (@arg DISCRIMINANT: +required {is_bigint_ok} "The discriminant" )
            (@arg NUM_ITERATIONS: +required  {is_u64_ok} "The number of iterations")
        )
        (@subcommand verify =>
            (@arg DISCRIMINANT: +required {is_bigint_ok} "The discriminant" )
            (@arg NUM_ITERATIONS: +required  {is_u64_ok} "The number of iterations")
            (@arg PROOF: +required "The proof")
        )
        (@subcommand dump =>
        (@arg NUM: +required "The bignum to dump")
        )
    )
    .get_matches();
    if let Some(_matches) = matches.subcommand_matches("compute") {
        let (discriminant, iterations) = parse_already_checked_args();
        println!("{}", vdf::do_compute(discriminant, iterations));
    } else if let Some(matches) = matches.subcommand_matches("dump") {
        let mut v_input = matches.value_of("NUM").unwrap();
        let v = Mpz::from_str_radix(v_input, 0).unwrap();
        let mut buf = v_input.to_owned().into_bytes();
        vdf::export_obj(&v, &mut buf).unwrap();
        println!("Dumped output: {:x?}", buf);
    } else {
        unimplemented!();
        /*
        if  let Some(matches) = matches.subcommand_matches("verify") {
        let (discriminant, iterations) = parse_already_checked_args();
        let v = matches.value_of("PROOF").unwrap(); */
    }
}
