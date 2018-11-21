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
use std::env;
use std::fs::File;
use std::io::Write;
use std::path::PathBuf;
use std::u16;

/// The number of odd prime less than 65536.
const PRIMES_LEN: usize = 6541;

/// The number of integers that are:
///
/// * equal to 7 mod 8
/// * not divisible by any prime number less than or equal to 13.
/// * less than 8 * 3 * 5 * 7 * 11 * 13
const RESIDUES_LEN: usize = 5760;

/// The number of odd prime numbers between 13 and 65536 exclusive.
const SIEVE_INFO_LEN: usize = PRIMES_LEN - 5;

fn odd_primes_below_65536() -> Vec<usize> {
    const N: usize = 1 << 16;
    let mut sieve = vec![true; N >> 1];
    let mut q = (N as f64).powf(0.5) as usize;
    assert!(q * q <= N);
    q += 1;
    assert!(q * q > N);
    for i in (3..q).step_by(2) {
        if sieve[i >> 1] {
            for i in ((i * i >> 1)..sieve.len()).step_by(i) {
                sieve[i] = false;
            }
        }
    }
    // mega cheat ― we know the exact size of this vector
    let mut res = Vec::with_capacity(PRIMES_LEN);
    for i in 1..N / 2 {
        if sieve[i] {
            res.push(2 * i + 1);
        }
    }
    assert_eq!(res.len(), PRIMES_LEN);
    res
}

fn mod_exponentiation(base: usize, exponent: usize, modulus: usize) -> usize {
    assert!(base < u16::MAX.into());
    assert!(exponent < u16::MAX.into());
    assert!(modulus < u16::MAX.into());
    let (mut base, mut exponent, modulus) = (base as u32, exponent as u32, modulus as u32);
    let mut state = 1;
    loop {
        if exponent & 1 != 0 {
            state *= base;
            state %= modulus;
        }
        exponent >>= 1;
        if exponent == 0 {
            return state as _;
        }
        base *= base;
        base %= modulus;
    }
}

macro_rules! const_fmt {
    () => {
        "#[allow(clippy::unreadable_literals)]\n\
         const {}: [{}; {}] = {:?};\n\n";
    };
}
const M: usize = 8 * 3 * 5 * 7 * 11 * 13;
fn emit<T: std::fmt::Debug>(f: &mut dyn Write, name: &str, t: &str, obj: &[T]) {
    write!(f, const_fmt!(), name, t, obj.len(), obj).expect("i/o error in build script");
}

/// Write the generated code to `f`.
fn generate(f: &mut dyn Write) {
    let odd_primes_below_65536 = odd_primes_below_65536();
    let odd_primes_above_13 = &odd_primes_below_65536[5..];
    assert_eq!(odd_primes_above_13.len(), SIEVE_INFO_LEN);
    write!(f, "const M: u32 = 8 * 3 * 5 * 7 * 11 * 13;\n\n").expect("i/o error");
    let mut residues = Vec::with_capacity(RESIDUES_LEN);
    'outer: for x in (7..M).step_by(8) {
        for y in &[3, 5, 7, 11, 13] {
            if x % y == 0 {
                continue 'outer;
            }
        }
        residues.push(x);
    }
    assert_eq!(residues.len(), RESIDUES_LEN);
    emit(f, "RESIDUES", "u32", &residues[..]);
    let mut sieve_info = Vec::with_capacity(SIEVE_INFO_LEN);
    for &i in odd_primes_above_13 {
        sieve_info.push((i, mod_exponentiation(M % i, i - 2, i)));
    }
    assert_eq!(sieve_info.len(), SIEVE_INFO_LEN);
    emit(f, "SIEVE_INFO", "(u16, u16)", &sieve_info[..]);
}

fn main() {
    println!("cargo:rerun-if-changed=build.rs");
    let manifest_path = env::var("OUT_DIR").expect("cargo should have set this");
    let mut path = PathBuf::from(&manifest_path);
    path.push("constants.rs");
    let mut f = File::create(path).expect("cannot create constants.rs");
    generate(&mut f);
}
