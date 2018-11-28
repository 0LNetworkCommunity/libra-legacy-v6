// Copyright 2018 Chia Network Inc and POA Networks Ltd.
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
// limitations under the License.
#![deny(warnings)]
#![forbid(unsafe_code)]
use std::u64;
// use std::num::ParseIntError;
extern crate gmp;
use gmp::mpz::Mpz;
use std::cell::RefCell;
extern crate hex;
extern crate vdf;
use vdf::{InvalidProof, PietrzakVDFParams, VDFParams, WesolowskiVDFParams, VDF};
#[macro_use]
extern crate clap;
extern crate classgroup;
thread_local! {
    static DISCRIMINANT: RefCell<Option<Mpz>> = RefCell::new(None);
}

fn is_bigint_ok(obj: String) -> Result<(), String> {
    let s = match Mpz::from_str_radix(&obj, 0) {
        Ok(m) => {
            if m >= (-6i64).into() {
                Err("m must be negative and ≤ -7".to_owned())
            } else if m.probab_prime(if cfg!(debug_assertions) { 40 } else { 1 })
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

fn parse_already_checked_args() -> (Mpz,) {
    (DISCRIMINANT.with(|x| x.borrow_mut().take().unwrap()),)
}

macro_rules! gen_validator {
    ($name:ident : $type:ty) => {
        gen_validator!($name, str::parse::<$type>);
    };
    ($name:ident, $expr:expr) => {
        fn $name(obj: String) -> Result<(), String> {
            $expr(&obj).map(drop).map_err(|x| format!("{}", x))
        }
    };
}

gen_validator!(is_u16_ok: u16);
gen_validator!(is_u64_ok: u64);
gen_validator!(is_hex_ok, hex::decode);
gen_validator!(is_bignum_ok, |x| Mpz::from_str_radix(x, 0));

fn check_iterations(is_pietrzak: bool, matches: &clap::ArgMatches) -> u64 {
    let iterations = value_t!(matches, "NUM_ITERATIONS", u64).unwrap();
    if is_pietrzak && (iterations & 1 != 0 || iterations < 66) {
        clap::Error::with_description(
            "Number of iterations must be even and at least 66",
            clap::ErrorKind::ValueValidation,
        ).exit()
    } else {
        iterations
    }
}

fn main() -> Result<(), std::io::Error> {
    let validate_proof_type = |x| {
        if x == "pietrzak" || x == "wesolowski" {
            Ok(())
        } else {
            Err("Invalid proof type".to_owned())
        }
    };

    let matches = clap_app!(myapp =>
        (version: crate_version!())
        (author: "POA Networks Ltd. <poa.networks>")
        (about: "CLI to Verifiable Delay Functions")
        (@arg TYPE: -t --type +takes_value {validate_proof_type} "The type of proof to generate")
        (@subcommand compute =>
            (@arg DISCRIMINANT: +required {is_bigint_ok} "The discriminant" )
            (@arg NUM_ITERATIONS: +required {is_u64_ok} "The number of iterations")
        )
        (@subcommand prove =>
            (@arg DISCRIMINANT_CHALLENGE: +required {is_hex_ok} "Hex-encoded challenge to derive the discriminant from" )
            (@arg NUM_ITERATIONS: +required {is_u64_ok} "The number of iterations")
            (@arg LENGTH: {is_u16_ok} "Length in bits of the discriminant (default: 2048)")
        )
        (@subcommand verify =>
            (@arg DISCRIMINANT_CHALLENGE: +required {is_hex_ok} "Hex-encoded challenge to derive the discriminant from" )
            (@arg NUM_ITERATIONS: +required {is_u64_ok} "The number of iterations")
            (@arg PROOF: +required {is_hex_ok} "The proof")
            (@arg LENGTH: {is_u16_ok} "Length in bits of the discriminant (default: 2048)")
        )
        (@subcommand dump =>
        (@arg NUM: +required {is_bignum_ok} "The bignum to dump")
        )
    )
    .get_matches();
    let is_pietrzak = matches
        .value_of("TYPE")
        .map(|x| x == "pietrzak")
        .unwrap_or(true);

    match matches.subcommand() {
        ("compute", Some(matches)) => {
            let (discriminant,) = parse_already_checked_args();
            println!(
                "{}",
                classgroup::do_compute(
                    discriminant,
                    matches.value_of("ITERATIONS").unwrap().parse().unwrap()
                )
            );
            Ok(())
        }
        ("verify", Some(matches)) => {
            let iterations = check_iterations(is_pietrzak, &matches);
            let challenge =
                hex::decode(&matches.value_of("DISCRIMINANT_CHALLENGE").unwrap()).unwrap();
            let length = matches.value_of("LENGTH").or(Some("2048")).unwrap();
            let int_size_bits = u16::from_str_radix(length, 10).unwrap();
            let proof = hex::decode(matches.value_of("PROOF").unwrap()).unwrap();

            let vdf: Box<VDF> = if is_pietrzak {
                Box::new(PietrzakVDFParams(int_size_bits).new()) as _
            } else {
                Box::new(WesolowskiVDFParams(int_size_bits).new()) as _
            };

            match vdf.verify(&challenge, iterations, &proof) {
                Ok(()) => {
                    println!("Proof is valid");
                    Ok(())
                }
                Err(InvalidProof) => {
                    println!("Invalid proof");
                    std::process::exit(1);
                }
            }
        }
        ("prove", Some(matches)) => {
            let iterations = check_iterations(is_pietrzak, &matches);
            let challenge =
                hex::decode(&matches.value_of("DISCRIMINANT_CHALLENGE").unwrap()).unwrap();
            let length = matches.value_of("LENGTH").or(Some("2048")).unwrap();
            let int_size_bits = u16::from_str_radix(length, 10).unwrap();

            let vdf: Box<VDF> = if is_pietrzak {
                Box::new(PietrzakVDFParams(int_size_bits).new()) as _
            } else {
                Box::new(WesolowskiVDFParams(int_size_bits).new()) as _
            };

            let proof = vdf.solve(&challenge, iterations).unwrap();
            println!("{}", hex::encode(&proof));
            Ok(())
        }
        ("dump", Some(matches)) => {
            let v = Mpz::from_str_radix(matches.value_of("NUM").unwrap(), 0).unwrap();
            let mut buf = vec![0u8; classgroup::export_obj(&v, &mut []).unwrap_err()];
            classgroup::export_obj(&v, &mut buf).unwrap();
            assert_eq!(&classgroup::import_obj(&buf), &v);
            println!("Dumped output: {:x?}", buf);
            Ok(())
        }
        _ => unreachable!(),
    }
}
