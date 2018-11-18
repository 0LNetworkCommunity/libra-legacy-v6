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
// and limitations under the License.
use super::{classgroup::ClassGroup, proof_pietrzak::verify_proof};
use sha2::{digest::FixedOutput, Digest, Sha256};
use std::collections::HashMap;
use std::usize;

fn generate_r_value<T>(x: &T, y: &T, sqrt_mu: &T, int_size_bits: usize) -> Result<T::BigNum, ()>
where
    T: ClassGroup<BigNum = super::gmp_classgroup::ffi::Mpz>,
    for<'a, 'b> &'a T: std::ops::Mul<&'b T, Output = T>,
    for<'a, 'b> &'a T::BigNum: std::ops::Mul<&'b T::BigNum, Output = T::BigNum>,
{
    let size = (int_size_bits + 16) >> 4;
    let mut v = Vec::with_capacity(size * 2);
    for _ in 0..size * 2 {
        v.push(0)
    }
    let mut hasher = Sha256::new();
    for i in &[&x, &y, &sqrt_mu] {
        i.serialize(&mut v).map_err(drop)?;
        hasher.input(&v);
    }
    let res = hasher.fixed_result();
    Ok(T::BigNum::from(&res[..16]))
}

pub fn deserialize_proof<T>(
    proof_blob: &[u8],
    discriminant: &T::BigNum,
    length: usize,
) -> Result<Vec<T>, ()>
where
    T: ClassGroup,
    for<'a, 'b> &'a T: std::ops::Mul<&'b T, Output = T>,
    for<'a, 'b> &'a T::BigNum: std::ops::Mul<&'b T::BigNum, Output = T::BigNum>,
{
    if length == 0 || length > (usize::MAX / 2) {
        return Err(());
    }
    let length = length * 2;
    let proof_blob_length = proof_blob.len();
    let rem = proof_blob_length % length;
    if rem != 0 {
        return Err(());
    }
    let proof_len = proof_blob_length / length;
    let mut v = Vec::with_capacity(proof_len);
    for i in 0..proof_len {
        let offset = i * length;
        v.push(T::from_bytes(
            &proof_blob[offset..offset + length],
            discriminant.clone(),
        ))
    }
    Ok(v)
}

fn iterate_squarings<V, U>(mut x: V, powers_to_calculate: U) -> HashMap<u64, V>
where
    V: ClassGroup<BigNum = gmp::mpz::Mpz>,
    for<'a, 'b> &'a V: std::ops::Mul<&'b V, Output = V>,
    for<'a, 'b> &'a V::BigNum: std::ops::Mul<&'b V::BigNum, Output = V::BigNum>,
    U: Iterator<Item = u64>,
{
    let mut powers_calculated = HashMap::new();
    let mut powers_to_calculate: Vec<u64> = powers_to_calculate.collect();
    powers_to_calculate.sort_unstable();
    let mut previous_power: u64 = 0;
    for &current_power in &powers_to_calculate {
        x.repeated_square(current_power - previous_power);
        powers_calculated.insert(current_power, x.clone());
        previous_power = current_power
    }
    powers_calculated
}

pub fn create_proof_of_time_pietrzak<T>(
    x: T,
    iterations: u64,
    int_size_bits: usize,
) -> Result<Vec<u8>, ()>
where
    T: ClassGroup<BigNum = gmp::mpz::Mpz>,
    for<'a, 'b> &'a T: std::ops::Mul<&'b T, Output = T>,
    for<'a, 'b> &'a T::BigNum: std::ops::Mul<&'b T::BigNum, Output = T::BigNum>,
{
    let delta = 8;
    let powers_to_calculate = super::proof_pietrzak::cache_indeces_for_count(iterations);
    let powers = iterate_squarings(x.clone(), powers_to_calculate.iter().cloned());
    let y = &powers[&iterations];
    let identity = &x.identity();
    let proof = super::proof_pietrzak::generate_proof(
        x,
        iterations,
        delta,
        y.clone(),
        &powers,
        identity,
        &generate_r_value,
        int_size_bits,
    )?;
    let proof_len = proof.len();
    let element_length = 2 * ((int_size_bits + 16) >> 4);
    let proof_len_in_bytes = (proof_len + 1) * element_length;
    let mut v = Vec::with_capacity(proof_len_in_bytes);
    v.resize(proof_len_in_bytes, 0);
    y.serialize(&mut v[0..element_length]).map_err(drop)?;
    for i in 0..proof_len {
        let offset = (i + 1) * element_length;
        proof[i]
            .serialize(&mut v[offset..offset + element_length])
            .map_err(drop)?
    }
    Ok(v)
}

pub fn check_proof_of_time_pietrzak<T>(
    discriminant: T::BigNum,
    x: &T,
    proof_blob: &[u8],
    iterations: u64,
    length_in_bits: usize,
) -> Result<(), ()>
where
    T: ClassGroup<BigNum = gmp::mpz::Mpz>,
    for<'a, 'b> &'a T: std::ops::Mul<&'b T, Output = T>,
    for<'a, 'b> &'a T::BigNum: std::ops::Mul<&'b T::BigNum, Output = T::BigNum>,
{
    if usize::MAX - 16 < length_in_bits {
        // Proof way too long.
        return Err(());
    }
    let length = (length_in_bits + 16) >> 4;
    if proof_blob.len() < 2 * length {
        // Invalid length of proof
        return Err(());
    }
    let result_bytes = &proof_blob[..length * 2];
    let proof_bytes = &proof_blob[length * 2..];
    let proof = deserialize_proof(proof_bytes, &discriminant, length * 2)?;
    let y = T::from_bytes(result_bytes, discriminant);
    verify_proof(
        x,
        &y,
        proof,
        iterations,
        8,
        &generate_r_value,
        length_in_bits,
    )
}
