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
use super::classgroup::ClassGroup;
use std::{collections::HashMap, usize};

pub fn serialize<V: ClassGroup>(proof: &[V], y: &V, int_size_bits: usize) -> Vec<u8> {
    let proof_len = proof.len();
    let element_length = 2 * ((int_size_bits + 16) >> 4);
    let proof_len_in_bytes = (proof_len + 1) * element_length;
    let mut v = vec![0; proof_len_in_bytes];
    y.serialize(&mut v[0..element_length])
        .expect(super::INCORRECT_BUFFER_SIZE);
    for (index, group) in proof.iter().enumerate() {
        let offset = (index + 1) * element_length;
        group
            .serialize(&mut v[offset..offset + element_length])
            .expect(super::INCORRECT_BUFFER_SIZE)
    }
    v
}
pub fn deserialize_proof<T>(
    proof_blob: &[u8],
    discriminant: &T::BigNum,
    orig_length: usize,
) -> Result<Vec<T>, ()>
where
    T: ClassGroup,
    for<'a, 'b> &'a T: std::ops::Mul<&'b T, Output = T>,
    for<'a, 'b> &'a T::BigNum: std::ops::Mul<&'b T::BigNum, Output = T::BigNum>,
{
    let length = T::size_in_bits(discriminant);
    if length > usize::MAX - 16 {
        return Err(());
    }
    let length = (length + 16) >> 4;
    if length == 0 {
        return Err(());
    }
    if orig_length != length {
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

pub fn iterate_squarings<V, U>(mut x: V, powers_to_calculate: U) -> HashMap<u64, V>
where
    V: ClassGroup,
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
