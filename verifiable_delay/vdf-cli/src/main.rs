// Copyright 2018 Chia Network Inc and POA Networks, Ltd.
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
// and limitations under the License.
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
                DISCRIMINANT.with(|x| assert!(x.replace(Some(m)).is_none()));
                Ok(())
            }
        }
        Err(e) => Err(format!("{}: {:?}", e, obj)),
    };
    drop(obj);
    s
}

fn is_value_ok(obj: String) -> Result<(), String> {
    let s = Mpz::from_str_radix(&obj, 0)
        .map(drop)
        .map_err(|e| format!("{}: {:?}", e, obj));
    drop(obj);
    s
}

fn is_u64_ok(obj: String) -> Result<(), String> {
    match u64::from_str_radix(&obj, 10) {
        Ok(n) if n < 66 => Err(format!(
            "Number of iterations must be at least 66, not {}",
            n
        )),
        Ok(n) if n & 1 == 0 => {
            NUM_ITERATIONS.with(|x| assert!(x.replace(Some(n)).is_none()));
            drop(obj);
            Ok(())
        }
        Ok(n) => Err(format!("Number of iterations must be even, not {}", n)),
        Err(s) => Err(format!("{}: {:?}", s, obj)),
    }
}

fn parse_already_checked_args() -> (Mpz, u64) {
    (
        DISCRIMINANT.with(|x| x.borrow_mut().take().unwrap()),
        NUM_ITERATIONS.with(|x| x.borrow_mut().take().unwrap()),
    )
}

fn is_hex_ok(obj: String) -> Result<(), String> {
    if obj.len() & 1 != 0 {
        return Err(format!("{}", hex::FromHexError::OddLength));
    }
    for i in obj.chars() {
        match i {
            '0'...'9' | 'a'...'f' | 'A'...'F' => (),
            _ => drop(hex::decode(&obj).map_err(|x| format!("{}", x))),
        }
    }
    drop(obj);
    Ok(())
}

fn is_u16_ok(obj: String) -> Result<(), String> {
    u16::from_str_radix(&obj, 10)
        .map(drop)
        .map_err(|x| format!("{}", x))
}

fn main() -> Result<(), std::io::Error> {
    let matches = clap_app!(myapp =>
        (version: crate_version!())
        (author: "POA Networks, Ltd. <poa.networks>")
        (about: "CLI to Verifiable Delay Functions")
        (@subcommand compute =>
            (@arg DISCRIMINANT: +required {is_bigint_ok} "The discriminant" )
            (@arg NUM_ITERATIONS: +required  {is_u64_ok} "The number of iterations")
        )
        (@subcommand prove =>
            (@arg DISCRIMINANT_CHALLENGE: +required {is_hex_ok} "Hex-encoded challenge to derive the discriminant from" )
            (@arg NUM_ITERATIONS: +required  {is_u64_ok} "The number of iterations")
            (@arg LENGTH: {is_u16_ok} "Length in bits of the discriminant (default: 2048)")
        )
        (@subcommand verify =>
            (@arg DISCRIMINANT_CHALLENGE: +required {is_hex_ok} "Hex-encoded challenge to derive the discriminant from" )
            (@arg NUM_ITERATIONS: +required  {is_u64_ok} "The number of iterations")
            (@arg PROOF: +required {is_hex_ok} "The proof")
            (@arg LENGTH: {is_u16_ok} "Length in bits of the discriminant (default: 2048)")
        )
        (@subcommand dump =>
        (@arg NUM: +required {is_value_ok} "The bignum to dump")
        )
    )
    .get_matches();
    if let Some(_matches) = matches.subcommand_matches("compute") {
        let (discriminant, iterations) = parse_already_checked_args();
        println!("{}", vdf::do_compute(discriminant, iterations));
        Ok(())
    } else if let Some(matches) = matches.subcommand_matches("dump") {
        let mut v_input = matches.value_of("NUM").unwrap();
        let v = Mpz::from_str_radix(v_input, 0).unwrap();
        let mut buf = v_input.to_owned().into_bytes();
        vdf::export_obj(&v, &mut buf).unwrap();
        assert_eq!(&vdf::import_obj(&buf), &v);
        println!("Dumped output: {:x?}", buf);
        Ok(())
    } else if let Some(matches) = matches.subcommand_matches("verify") {
        let iterations = value_t!(matches, "NUM_ITERATIONS", u64).unwrap();
        let challenge = matches.value_of("DISCRIMINANT_CHALLENGE").unwrap();
        let length = matches.value_of("LENGTH").or(Some("2048")).unwrap();
        let length = u16::from_str_radix(length, 10).unwrap();
        let discriminant = vdf::create_discriminant(&hex::decode(&challenge).unwrap(), length);
        let proof = hex::decode(matches.value_of("PROOF").unwrap()).unwrap();
        let x: vdf::GmpClassGroup =
            vdf::ClassGroup::from_ab_discriminant(2.into(), 1.into(), discriminant.clone());
        match vdf::check_proof_of_time_pietrzak(
            discriminant,
            &x,
            &proof,
            iterations,
            usize::from(length),
        ) {
            Ok(()) => {
                println!("Proof is valid");
                Ok(())
            }
            Err(()) => {
                println!("Bad proof!");
                Err(std::io::Error::new(
                    std::io::ErrorKind::InvalidData,
                    "Bad proof!",
                ))
            }
        }
    } else if let Some(matches) = matches.subcommand_matches("prove") {
        let iterations = value_t!(matches, "NUM_ITERATIONS", u64).unwrap();
        let challenge = matches.value_of("DISCRIMINANT_CHALLENGE").unwrap();
        let length = matches.value_of("LENGTH").or(Some("2048")).unwrap();
        let length = u16::from_str_radix(length, 10).unwrap();
        let discriminant = vdf::create_discriminant(&hex::decode(&challenge).unwrap(), length);
        let x: vdf::GmpClassGroup =
            vdf::ClassGroup::from_ab_discriminant(2.into(), 1.into(), discriminant);
        println!(
            "{}",
            hex::encode(
                &vdf::create_proof_of_time_pietrzak(x, iterations, usize::from(length)).unwrap()
            )
        );
        Ok(())
    } else {
        unimplemented!()
    }
}
