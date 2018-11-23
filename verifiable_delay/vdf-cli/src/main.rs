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
#[macro_use]
extern crate clap;

thread_local! {
    static DISCRIMINANT: RefCell<Option<Mpz>> = RefCell::new(None);
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
gen_validator!(is_iterations_ok: vdf::Iterations);
gen_validator!(is_hex_ok, hex::decode);
gen_validator!(is_bignum_ok, |x| Mpz::from_str_radix(x, 0));

fn main() -> Result<(), std::io::Error> {
    let matches = clap_app!(myapp =>
        (version: crate_version!())
        (author: "POA Networks, Ltd. <poa.networks>")
        (about: "CLI to Verifiable Delay Functions")
        (@subcommand compute =>
            (@arg DISCRIMINANT: +required {is_bigint_ok} "The discriminant" )
            (@arg NUM_ITERATIONS: +required {is_u64_ok} "The number of iterations")
        )
        (@subcommand prove =>
            (@arg DISCRIMINANT_CHALLENGE: +required {is_hex_ok} "Hex-encoded challenge to derive the discriminant from" )
            (@arg NUM_ITERATIONS: +required {is_iterations_ok} "The number of iterations")
            (@arg LENGTH: {is_u16_ok} "Length in bits of the discriminant (default: 2048)")
        )
        (@subcommand verify =>
            (@arg DISCRIMINANT_CHALLENGE: +required {is_hex_ok} "Hex-encoded challenge to derive the discriminant from" )
            (@arg NUM_ITERATIONS: +required {is_iterations_ok} "The number of iterations")
            (@arg PROOF: +required {is_hex_ok} "The proof")
            (@arg LENGTH: {is_u16_ok} "Length in bits of the discriminant (default: 2048)")
        )
        (@subcommand dump =>
        (@arg NUM: +required {is_bignum_ok} "The bignum to dump")
        )
    )
    .get_matches();
    if let Some(_matches) = matches.subcommand_matches("compute") {
        let (discriminant,) = parse_already_checked_args();
        let iterations = value_t_or_exit!(_matches, "NUM_ITERATIONS", u64);
        println!("{}", vdf::do_compute(discriminant, iterations));
        Ok(())
    } else if let Some(matches) = matches.subcommand_matches("dump") {
        let mut v = Mpz::from_str_radix(matches.value_of("NUM").unwrap(), 0).unwrap();
        let mut buf = vec![0u8; vdf::export_obj(&v, &mut []).unwrap_err()];
        vdf::export_obj(&v, &mut buf).unwrap();
        assert_eq!(&vdf::import_obj(&buf), &v);
        println!("Dumped output: {:x?}", buf);
        Ok(())
    } else if let Some(m) = matches.subcommand_matches("verify") {
        let iterations = value_t_or_exit!(m, "NUM_ITERATIONS", vdf::Iterations).into();
        let challenge = m.value_of("DISCRIMINANT_CHALLENGE").unwrap();
        let length = m.value_of("LENGTH").or(Some("2048")).unwrap();
        let length = u16::from_str_radix(length, 10).unwrap();
        let discriminant = vdf::create_discriminant(&hex::decode(&challenge).unwrap(), length);
        let proof = hex::decode(m.value_of("PROOF").unwrap()).unwrap();
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
                println!("Invalid proof");
                std::process::exit(1);
            }
        }
    } else if let Some(matches) = matches.subcommand_matches("prove") {
        let iterations = value_t_or_exit!(matches, "NUM_ITERATIONS", vdf::Iterations);
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
