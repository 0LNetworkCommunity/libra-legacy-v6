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
#![forbid(unsafe_code)]
use hex;

#[macro_use]
extern crate clap;

use std::{cell::RefCell, fs::File, io::Read, rc::Rc, u64};
use vdf::{InvalidProof, PietrzakVDFParams, VDFParams, WesolowskiVDFParams, VDF};

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

fn check_iterations(is_pietrzak: bool, matches: &clap::ArgMatches<'_>) -> u64 {
    let iterations = value_t!(matches, "NUM_ITERATIONS", u64).unwrap();
    if is_pietrzak && (iterations & 1 != 0 || iterations < 66) {
        clap::Error::with_description(
            "Number of iterations must be even and at least 66",
            clap::ErrorKind::ValueValidation,
        )
        .exit()
    } else {
        iterations
    }
}

fn main() {
    let validate_proof_type = |x| {
        if x == "pietrzak" || x == "wesolowski" {
            Ok(())
        } else {
            Err("Invalid proof type".to_owned())
        }
    };

    let proof_contents = Rc::new(RefCell::new(None));
    let is_proof_ok = {
        let proof_contents = proof_contents.clone();
        move |proof: String| {
            *proof_contents.borrow_mut() = Some(if proof.starts_with("@") {
                let file_name = &proof[1..];
                let mut file = File::open(file_name)
                    .map_err(|err| format!("Cound not open {:?}: {}", file_name, err))?;
                let mut buf = Vec::new();
                file.read_to_end(&mut buf)
                    .map_err(|err| format!("Cound not read {:?}: {}", file_name, err))?;
                buf
            } else {
                hex::decode(&proof).map_err(|err| format!("Invalid hex {:?}: {}", proof, err))?
            });
            Ok(())
        }
    };

    let matches = clap_app!(vdf =>
        (version: crate_version!())
        (author: "POA Networks Ltd. <poa.networks>")
        (about: "CLI to Verifiable Delay Functions")
        (@arg VERBOSE: -v --verbose "Log verbosely to stderr.  This command does not currently log anything, so this option currently has no affect.")
        (@arg TYPE: -t --type +takes_value {validate_proof_type} "The type of proof to generate")
        (@arg LENGTH: -l --length +takes_value {is_u16_ok} "Length in bits of the discriminant (default: 2048)")
        (@arg DISCRIMINANT_CHALLENGE: +required {is_hex_ok} "Hex-encoded challenge to derive the discriminant from" )
        (@arg NUM_ITERATIONS: +required {is_u64_ok} "The number of iterations")
        (@arg PROOF: {is_proof_ok} "The hex-encoded proof, or @ followed by a file containing the proof as raw binary data")
    )
    .get_matches();
    let is_pietrzak = matches
        .value_of("TYPE")
        .map(|x| x == "pietrzak")
        .unwrap_or(false);
    let int_size_bits: u16 = matches
        .value_of("LENGTH")
        .unwrap_or("2048")
        .parse()
        .unwrap();

    let iterations = check_iterations(is_pietrzak, &matches);
    let challenge = hex::decode(&matches.value_of("DISCRIMINANT_CHALLENGE").unwrap()).unwrap();

    let vdf: Box<dyn VDF> = if is_pietrzak {
        Box::new(PietrzakVDFParams(int_size_bits).new()) as _
    } else {
        Box::new(WesolowskiVDFParams(int_size_bits).new()) as _
    };
    if let Some(proof) = matches.value_of_os("PROOF") {
        drop(proof);
        let actual_proof = proof_contents.borrow_mut().take().unwrap();
        match vdf.verify(&challenge, iterations, &actual_proof) {
            Ok(()) => println!("Proof is valid"),
            Err(InvalidProof) => {
                println!("Invalid proof");
                std::process::exit(1)
            }
        }
    } else {
        let proof = vdf
            .solve(&challenge, iterations)
            .expect("iterations should have been valiated earlier");
        println!("{}", hex::encode(proof))
    }
}
