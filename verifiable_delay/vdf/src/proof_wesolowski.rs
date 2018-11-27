// Copyright 2018 POA Networks Ltd.
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

use super::gmp_classgroup::ffi::mpz_powm;
use super::ClassGroup;
use gmp::mpz::Mpz;
use sha2::{digest::FixedOutput, Digest, Sha256};
use std::{cmp::Eq, collections::HashMap, hash::Hash, mem, u64, usize};

/// To quote the original Python code:
///
/// > Create `L` and `k` parameters from papers, based on how many iterations
/// > need to be performed, and how much memory should be used.
pub fn approximate_parameters(t: f64) -> (usize, u8, u64) {
    let log_memory = (10_000_000.0f64).log2();
    let log_t = (t as f64).log2();
    let l = if log_t - log_memory > 0. {
        2.0f64.powf(log_memory - 20.).ceil()
    } else {
        1.
    };

    let intermediate = t * (2.0f64).ln() / (2.0 * l);
    let k = (intermediate.ln() - intermediate.ln().ln() + 0.25)
        .round()
        .max(1.);

    let w = (t / (t / k + l * (2.0f64).powf(k + 1.0)) - 2.0).floor();
    (l as _, k as _, w as _)
}

fn u64_to_bytes(q: u64) -> [u8; 8] {
    if false {
        unsafe { std::mem::transmute(q.to_be()) }
    } else {
        [
            (q >> 56) as u8,
            (q >> 48) as u8,
            (q >> 40) as u8,
            (q >> 32) as u8,
            (q >> 24) as u8,
            (q >> 16) as u8,
            (q >> 8) as u8,
            q as u8,
        ]
    }
}

/// Quote:
///
/// > Creates a random prime based on input s.
fn hash_prime(seed: &[&[u8]]) -> Mpz {
    let mut j = 0u64;
    loop {
        let mut hasher = Sha256::new();
        hasher.input(b"prime");
        hasher.input(u64_to_bytes(j));
        for i in seed {
            hasher.input(i);
        }
        let n = Mpz::from(&hasher.fixed_result()[..16]);
        if n.probab_prime(25) != gmp::mpz::ProbabPrimeResult::NotPrime {
            break n;
        }
        j += 1;
    }
}

/// Quote:
///
/// > Get“s the ith block of `2^T // B`, such that `sum(get_block(i) * 2^(k*i))
/// > = t^T // B`
fn get_block(i: u64, k: u8, t: u64, b: &Mpz) -> Mpz {
    let mut res = Mpz::new();
    super::gmp_classgroup::ffi::mpz_powm(
        &mut res,
        &Mpz::from(2),
        &Mpz::from(t - u64::from(k) * (i + 1)),
        b,
    );
    res *= Mpz::one() << k as usize;
    res / b
}

fn eval_optimized<T, L: ClassGroup<BigNum = Mpz> + Eq + Hash>(
    h: &L,
    b: &Mpz,
    t: usize,
    k: u8,
    l: usize,
    powers: &T,
) -> L
where
    T: for<'a> std::ops::Index<&'a u64, Output = L>,
{
    assert!(k > 0, "k cannot be zero");
    assert!(l > 0, "l cannot be zero");
    let kl = (k as usize)
        .checked_mul(l)
        .expect("computing k*l overflowed a u64");
    assert!(kl <= u64::MAX as _);
    assert!((kl as u64) < (1u64 << 53), "k*l overflowed an f64");
    assert!((t as u64) < (1u64 << 53), "t overflows an f64");
    assert!(
        k < (mem::size_of::<usize>() << 3) as u8,
        "k must be less than the number of bits in a usize"
    );
    let k1 = k >> 1;
    let k0 = k - k1;
    let mut x = h.identity();
    let identity = h.identity();
    let k_exp = 1usize << k;
    let k0_exp = 1usize << k0;
    let k1_exp = 1usize << k1;
    for j in (0..l).rev() {
        x.pow(Mpz::from(k_exp as u64));
        let mut ys: HashMap<Mpz, L> = HashMap::new();
        for b in 0..1usize << k {
            ys.entry(Mpz::from(b as u64))
                .or_insert_with(|| identity.clone());
        }
        let end_of_loop = ((t as f64) / kl as f64).ceil() as usize;
        assert!(end_of_loop == 0 || (end_of_loop as u64 - 1).checked_mul(l as u64).is_some());
        for i in 0..end_of_loop {
            if t < k as usize * (i * l + j + 1) {
                continue;
            }
            let b = get_block((i as u64) * (l as u64), k, t as _, b);
            *ys.get_mut(&b).unwrap() *= &powers[&((i * kl) as _)];
        }

        for b1 in 0..k1_exp {
            let mut z = identity.clone();
            for b0 in 0..k0_exp {
                z *= &ys[&Mpz::from((b1 * k0_exp + b0) as u64)]
            }
            z.pow(Mpz::from((b1 as u64) * (k0_exp as u64)));
            x *= &z;
        }

        for b0 in 0..k0_exp {
            let mut z = identity.clone();
            for b1 in 0..k1_exp {
                z *= &ys[&Mpz::from((b1 * k0_exp + b0) as u64)];
            }
            z.pow(Mpz::from(b0 as u64));
            x *= &z;
        }
    }
    x
}

pub fn generate_proof<T, V: ClassGroup<BigNum = Mpz> + Eq + Hash>(
    x: &V,
    iterations: u64,
    k: u8,
    l: usize,
    powers: &T,
    int_size_bits: usize,
) -> V
where
    T: for<'a> std::ops::Index<&'a u64, Output = V>,
{
    let element_len = 2 * ((int_size_bits + 16) >> 4);
    let mut x_buf = vec![0; element_len];
    x.serialize(&mut x_buf[..])
        .expect(super::INCORRECT_BUFFER_SIZE);
    let mut y_buf = vec![0; element_len];
    powers[&iterations]
        .serialize(&mut y_buf[..])
        .expect(super::INCORRECT_BUFFER_SIZE);
    let b = hash_prime(&[&x_buf[..], &y_buf[..]]);
    eval_optimized(&x, &b, iterations as _, k, l, powers)
}

/// Verify a proof, according to the Wesolowski paper.
pub fn verify_proof<V: ClassGroup<BigNum = Mpz>>(
    mut x: V,
    y: &V,
    mut proof: V,
    t: u64,
    int_size_bits: usize,
) -> Result<(), ()> {
    let element_len = 2 * ((int_size_bits + 16) >> 4);
    let mut x_buf = vec![0; element_len];
    x.serialize(&mut x_buf[..])
        .expect(super::INCORRECT_BUFFER_SIZE);
    let mut y_buf = vec![0; element_len];
    y.serialize(&mut y_buf[..])
        .expect(super::INCORRECT_BUFFER_SIZE);
    let b = hash_prime(&[&x_buf[..], &y_buf[..]]);
    let mut r = Mpz::new();
    mpz_powm(&mut r, &Mpz::from(2u64), &Mpz::from(t), &b);
    proof.pow(b);
    x.pow(r);
    proof *= &x;
    if &proof == y {
        Ok(())
    } else {
        Err(())
    }
}
