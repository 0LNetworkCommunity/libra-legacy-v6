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
use super::proof_of_time::{deserialize_proof, iterate_squarings, serialize};
use classgroup::{gmp_classgroup::GmpClassGroup, BigNumExt, ClassGroup};
use num_traits::{One, Zero};
use std::{fmt, num::ParseIntError, ops::Index, str::FromStr, u64, usize};

#[derive(PartialEq, Eq, Hash, PartialOrd, Ord, Copy, Clone, Debug)]
pub struct Iterations(u64);

#[derive(PartialEq, Eq, Hash, Ord, PartialOrd, Copy, Clone, Debug)]
pub enum InvalidIterations {
    OddNumber(u64),
    LessThan66(u64),
}

#[derive(PartialEq, Eq, Clone, Debug)]
pub struct ParseIterationsError {
    kind: Result<InvalidIterations, ParseIntError>,
}

impl From<InvalidIterations> for ParseIterationsError {
    fn from(t: InvalidIterations) -> Self {
        Self { kind: Ok(t) }
    }
}

impl From<ParseIntError> for ParseIterationsError {
    fn from(t: ParseIntError) -> Self {
        Self { kind: Err(t) }
    }
}

impl fmt::Display for InvalidIterations {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match *self {
            InvalidIterations::OddNumber(s) => {
                write!(f, "Pietrzak iterations must be an even number, not {}", s)
            }
            InvalidIterations::LessThan66(s) => write!(
                f,
                "Pietrzak proof-of-time must run for at least 66 iterations, not {}",
                s
            ),
        }
    }
}

impl From<Iterations> for u64 {
    fn from(t: Iterations) -> u64 {
        t.0
    }
}

impl fmt::Display for ParseIterationsError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self.kind {
            Ok(ref q) => <InvalidIterations as fmt::Display>::fmt(q, f),
            Err(ref q) => <ParseIntError as fmt::Display>::fmt(q, f),
        }
    }
}

impl FromStr for Iterations {
    type Err = ParseIterationsError;
    fn from_str(s: &str) -> Result<Self, Self::Err> {
        Self::new(s.parse::<u64>().map_err(ParseIterationsError::from)?)
            .map_err(ParseIterationsError::from)
    }
}

impl Iterations {
    pub fn new<T: Into<u64>>(iterations: T) -> Result<Iterations, InvalidIterations> {
        let iterations = iterations.into();
        if iterations & 1 != 0 {
            Err(InvalidIterations::OddNumber(iterations))
        } else if iterations < 66 {
            Err(InvalidIterations::LessThan66(iterations))
        } else {
            Ok(Iterations(iterations))
        }
    }
}

/// Selects a reasonable choice of cache size.
fn approximate_i(t: Iterations) -> u64 {
    let x: f64 = (((t.0 >> 1) as f64) / 8.) * 2.0f64.ln();
    let w = x.ln() - x.ln().ln() + 0.25;
    (w / (2. * 2.0f64.ln())).round() as _
}

fn sum_combinations<'a, T: IntoIterator<Item = &'a u64>>(numbers: T) -> Vec<u64> {
    let mut combinations = vec![0];
    for i in numbers {
        let mut new_combinations = combinations.clone();
        for j in combinations {
            new_combinations.push(i + j)
        }
        combinations = new_combinations
    }
    combinations.remove(0);
    combinations
}

fn cache_indices_for_count(t: Iterations) -> Vec<u64> {
    let i: u64 = approximate_i(t);
    let mut curr_t = t.0;
    let mut intermediate_ts = vec![];
    for _ in 0..i {
        curr_t >>= 1;
        intermediate_ts.push(curr_t);
        if curr_t & 1 != 0 {
            curr_t += 1
        }
    }
    let mut cache_indices = sum_combinations(&intermediate_ts);
    cache_indices.sort();
    cache_indices.push(t.0);
    cache_indices
}

fn generate_r_value<T>(x: &T, y: &T, sqrt_mu: &T, int_size_bits: usize) -> T::BigNum
where
    T: ClassGroup,
    for<'a, 'b> &'a T: std::ops::Mul<&'b T, Output = T>,
    for<'a, 'b> &'a T::BigNum: std::ops::Mul<&'b T::BigNum, Output = T::BigNum>,
{
    use sha3::{
        digest::{ExtendableOutput, Input, XofReader},
        Shake128,
    };

    let size = (int_size_bits + 16) >> 4;
    let mut v = vec![0; size * 2];
    let mut h = Shake128::default();
    for i in &[&x, &y, &sqrt_mu] {
        i.serialize(&mut v).expect(super::INCORRECT_BUFFER_SIZE);
        h.input(&v);
    }
    let mut res = [0u8; 16];
    h.xof_result().read(&mut res);
    T::unsigned_deserialize_bignum(&res[..])
}

fn create_proof_of_time_pietrzak<T>(
    challenge: &[u8],
    iterations: Iterations,
    int_size_bits: u16,
) -> Vec<u8>
where
    T: ClassGroup,
    <T as ClassGroup>::BigNum: BigNumExt,
    for<'a, 'b> &'a T: std::ops::Mul<&'b T, Output = T>,
    for<'a, 'b> &'a T::BigNum: std::ops::Mul<&'b T::BigNum, Output = T::BigNum>,
{
    let discriminant = super::create_discriminant::create_discriminant(&challenge, int_size_bits);
    let x = T::from_ab_discriminant(2.into(), 1.into(), discriminant);

    let delta = 8;
    let powers_to_calculate = cache_indices_for_count(iterations);
    let powers = iterate_squarings(x.clone(), powers_to_calculate.iter().cloned());
    let proof: Vec<T> = generate_proof(
        x,
        iterations,
        delta,
        &powers,
        &generate_r_value,
        usize::from(int_size_bits),
    );
    serialize(
        &proof,
        &powers[&iterations.into()],
        usize::from(int_size_bits),
    )
}

pub fn check_proof_of_time_pietrzak<T>(
    challenge: &[u8],
    proof_blob: &[u8],
    iterations: u64,
    length_in_bits: u16,
) -> Result<(), super::InvalidProof>
where
    T: ClassGroup,
    T::BigNum: BigNumExt,
    for<'a, 'b> &'a T: std::ops::Mul<&'b T, Output = T>,
    for<'a, 'b> &'a T::BigNum: std::ops::Mul<&'b T::BigNum, Output = T::BigNum>,
{
    let discriminant = super::create_discriminant::create_discriminant(&challenge, length_in_bits);
    let x = T::from_ab_discriminant(2.into(), 1.into(), discriminant);
    let iterations = Iterations::new(iterations).map_err(|_| super::InvalidProof)?;
    if usize::MAX - 16 < length_in_bits.into() {
        // Proof way too long.
        return Err(super::InvalidProof);
    }
    let length: usize = (usize::from(length_in_bits) + 16usize) >> 4;
    if proof_blob.len() < 2 * length {
        // Invalid length of proof
        return Err(super::InvalidProof);
    }
    let result_bytes = &proof_blob[..length * 2];
    let proof_bytes = &proof_blob[length * 2..];
    let discriminant = x.discriminant().clone();
    let proof =
        deserialize_proof(proof_bytes, &discriminant, length).map_err(|()| super::InvalidProof)?;
    let y = T::from_bytes(result_bytes, discriminant);
    verify_proof(
        &x,
        &y,
        proof,
        iterations,
        8,
        &generate_r_value,
        length_in_bits.into(),
    )
    .map_err(|()| super::InvalidProof)
}

fn calculate_final_t(t: Iterations, delta: usize) -> u64 {
    let mut curr_t = t.0;
    let mut ts = vec![];
    while curr_t != 2 {
        ts.push(curr_t);
        curr_t >>= 1;
        if curr_t & 1 == 1 {
            curr_t += 1
        }
    }
    ts.push(2);
    ts.push(1);
    assert!(ts.len() >= delta);
    ts[ts.len() - delta]
}

pub fn generate_proof<T, U, V>(
    x: V,
    iterations: Iterations,
    delta: usize,
    powers: &T,
    generate_r_value: &U,
    int_size_bits: usize,
) -> Vec<V>
where
    T: for<'a> Index<&'a u64, Output = V>,
    U: Fn(&V, &V, &V, usize) -> V::BigNum,
    V: ClassGroup,
    for<'a, 'b> &'a V: std::ops::Mul<&'b V, Output = V>,
    for<'a, 'b> &'a V::BigNum: std::ops::Mul<&'b V::BigNum, Output = V::BigNum>,
{
    let identity = x.identity();
    let i = approximate_i(iterations);
    let mut mus = vec![];
    let mut rs: Vec<V::BigNum> = vec![];
    let mut x_p = vec![x];
    let mut curr_t = iterations.0;

    let mut y_p = vec![powers[&curr_t].clone()];

    let mut ts = vec![];

    let final_t = calculate_final_t(iterations, delta);

    let mut round_index = 0;
    while curr_t != final_t {
        assert_eq!(curr_t & 1, 0);
        let half_t = curr_t >> 1;
        ts.push(half_t);
        assert!(round_index < 63);
        let denominator: u64 = 1 << (round_index + 1);

        mus.push(if round_index < i {
            let mut mu = identity.clone();
            for numerator in (1..denominator).step_by(2) {
                let num_bits = 62 - denominator.leading_zeros() as usize;
                let mut r_prod: V::BigNum = One::one();
                for b in (0..num_bits).rev() {
                    if 0 == (numerator & (1 << (b + 1))) {
                        r_prod *= &rs[num_bits - b - 1]
                    }
                }
                let mut t_sum = half_t;
                for b in 0..num_bits {
                    if 0 != (numerator & (1 << (b + 1))) {
                        t_sum += ts[num_bits - b - 1]
                    }
                }
                let mut power = powers[&t_sum].clone();
                power.pow(r_prod);
                mu *= &power;
            }
            mu
        } else {
            let mut mu = x_p.last().unwrap().clone();
            for _ in 0..half_t {
                mu *= &mu.clone()
            }
            mu
        });
        let mut mu: V = mus.last().unwrap().clone();
        let last_r: V::BigNum = generate_r_value(&x_p[0], &y_p[0], &mu, int_size_bits);
        assert!(last_r >= Zero::zero());
        rs.push(last_r.clone());
        {
            let mut last_x: V = x_p.last().unwrap().clone();
            last_x.pow(last_r.clone());
            last_x *= &mu;
            x_p.push(last_x);
        }
        mu.pow(last_r);
        mu *= y_p.last().unwrap();
        y_p.push(mu);
        curr_t >>= 1;
        if curr_t & 1 != 0 {
            curr_t += 1;
            y_p.last_mut().unwrap().square();
        }
        round_index += 1
    }
    if cfg!(debug_assertions) {
        let mut last_y = y_p.last().unwrap().clone();
        let mut last_x = x_p.last().unwrap().clone();
        let one: V::BigNum = 1u64.into();
        last_y.pow(one.clone());
        assert_eq!(last_y, y_p.last().unwrap().clone());
        last_x.pow(one << final_t as usize);
    }
    mus
}

pub fn verify_proof<T, U, V>(
    x_initial: &V,
    y_initial: &V,
    proof: T,
    t: Iterations,
    delta: usize,
    generate_r_value: &U,
    int_size_bits: usize,
) -> Result<(), ()>
where
    T: IntoIterator<Item = V>,
    U: Fn(&V, &V, &V, usize) -> V::BigNum,
    V: ClassGroup,
    for<'a, 'b> &'a V: std::ops::Mul<&'b V, Output = V>,
    for<'a, 'b> &'a V::BigNum: std::ops::Mul<&'b V::BigNum, Output = V::BigNum>,
{
    let mut one: V::BigNum = One::one();
    let (mut x, mut y): (V, V) = (x_initial.clone(), y_initial.clone());
    let final_t = calculate_final_t(t, delta);
    let mut curr_t = t.0;
    for mut mu in proof {
        assert!(
            curr_t & 1 == 0,
            "Cannot have an odd number of iterations remaining"
        );
        let r = generate_r_value(x_initial, y_initial, &mu, int_size_bits);
        x.pow(r.clone());
        x *= &mu;
        mu.pow(r);
        y *= &mu;

        curr_t >>= 1;
        if curr_t & 1 != 0 {
            curr_t += 1;
            y.square();
        }
    }
    one <<= final_t as _;
    x.pow(one);
    if x == y {
        Ok(())
    } else {
        Err(())
    }
}

#[derive(Debug, Clone)]
pub struct PietrzakVDF {
    int_size_bits: u16,
}
use super::InvalidIterations as Bad;

#[derive(Clone, Copy, Eq, PartialEq, PartialOrd, Ord, Hash, Debug)]
pub struct PietrzakVDFParams(pub u16);
impl super::VDFParams for PietrzakVDFParams {
    type VDF = PietrzakVDF;
    fn new(self) -> Self::VDF {
        PietrzakVDF {
            int_size_bits: self.0,
        }
    }
}

impl super::VDF for PietrzakVDF {
    fn check_difficulty(&self, difficulty: u64) -> Result<(), Bad> {
        Iterations::new(difficulty)
            .map_err(|x| Bad(format!("{}", x)))
            .map(drop)
    }
    fn solve(&self, challenge: &[u8], difficulty: u64) -> Result<Vec<u8>, Bad> {
        Ok(create_proof_of_time_pietrzak::<GmpClassGroup>(
            challenge,
            Iterations::new(difficulty).map_err(|x| Bad(format!("{}", x)))?,
            self.int_size_bits,
        ))
    }

    fn verify(
        &self,
        challenge: &[u8],
        difficulty: u64,
        alleged_solution: &[u8],
    ) -> Result<(), super::InvalidProof> {
        check_proof_of_time_pietrzak::<GmpClassGroup>(
            challenge,
            alleged_solution,
            difficulty,
            self.int_size_bits,
        )
    }
}

#[cfg(test)]
mod test {
    use super::*;
    #[test]
    fn check_approximate_i() {
        assert_eq!(approximate_i(Iterations(534)), 2);
        assert_eq!(approximate_i(Iterations(134)), 1);
        assert_eq!(approximate_i(Iterations(1024)), 2);
    }
    #[test]
    fn check_cache_indices() {
        assert_eq!(cache_indices_for_count(Iterations(66))[..], [33, 66]);
        assert_eq!(
            cache_indices_for_count(Iterations(534))[..],
            [134, 267, 401, 534]
        );
    }

    #[test]
    fn check_calculate_final_t() {
        assert_eq!(calculate_final_t(Iterations(1024), 8), 128);
        assert_eq!(calculate_final_t(Iterations(1000), 8), 126);
        assert_eq!(calculate_final_t(Iterations(100), 8), 100);
    }
    #[test]
    fn check_assuptions_about_stdlib() {
        assert_eq!(62 - u64::leading_zeros(1024u64), 9);
        let mut q: Vec<_> = (1..4).step_by(2).collect();
        assert_eq!(q[..], [1, 3]);
        q = (1..3).step_by(2).collect();
        assert_eq!(q[..], [1]);
        q = (1..2).step_by(2).collect();
        assert_eq!(q[..], [1]);
    }
}
