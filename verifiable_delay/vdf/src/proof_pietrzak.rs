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
use super::classgroup::ClassGroup;
use num_traits::One;
use std::ops::Index;

fn approximate_i(t: u64) -> u64 {
    let x: f64 = (t as f64) / 16.;
    let w = x.log2() - x.log2().log2() + 0.25;
    (w / 2.).round() as _
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

pub fn cache_indeces_for_count(t: u64) -> Vec<u64> {
    let i: u64 = approximate_i(t);
    let mut curr_t = t;
    let mut intermediate_ts = vec![];
    for _ in 0..i {
        curr_t >>= 1;
        intermediate_ts.push(curr_t);
        if curr_t & 1 != 0 {
            curr_t += 1
        }
    }
    let mut cache_indeces = sum_combinations(&intermediate_ts);
    cache_indeces.sort();
    cache_indeces.push(t);
    cache_indeces
}

fn calculate_final_t(t: u64, delta: usize) -> u64 {
    let mut curr_t = t;
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

#[cfg_attr(feature = "cargo-clippy", allow(clippy::too_many_arguments))]
pub fn generate_proof<T, U, V>(
    x: V,
    t: u64,
    delta: usize,
    y: V,
    powers: &T,
    identity: &V,
    generate_r_value: &U,
    int_size_bits: usize,
) -> Result<Vec<V>, ()>
where
    T: for<'a> Index<&'a u64, Output = V>,
    U: Fn(&V, &V, &V, usize) -> Result<V::BigNum, ()>,
    V: ClassGroup<BigNum = gmp::mpz::Mpz>,
    for<'a, 'b> &'a V: std::ops::Mul<&'b V, Output = V>,
    for<'a, 'b> &'a V::BigNum: std::ops::Mul<&'b V::BigNum, Output = V::BigNum>,
{
    if t & 1 == 1 {
        panic!("T must be even")
    }
    let i = approximate_i(t);
    let mut mus = vec![];
    let mut rs: Vec<V::BigNum> = vec![];
    let mut x_p = vec![x];
    let mut y_p = vec![y];

    let mut curr_t = t;
    let mut ts = vec![];

    let final_t = calculate_final_t(t as _, delta);

    let mut round_index = 0;
    while curr_t as u64 != final_t {
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
                    if 0 == numerator & 1 << (b + 1) {
                        r_prod *= &rs[num_bits - b - 1]
                    }
                }
                let mut t_sum = half_t;
                for b in 0..num_bits {
                    if 0 == numerator & 1 << (b + 1) {
                        t_sum += ts[num_bits - b - 1]
                    }
                }
                let mut s = powers[&t_sum].clone();
                s.pow(r_prod);
                mu *= &s
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
        rs.push(generate_r_value(&x_p[0], &y_p[0], &mu, int_size_bits)?);
        let last_r: V::BigNum = rs.last().unwrap().clone();
        {
            let mut a: V = x_p.last().unwrap().clone();
            a.pow(last_r.clone());
            a *= &mu;
            x_p.push(a)
        }
        mu.pow(last_r);
        mu *= y_p.last().unwrap();
        y_p.push(mu);
        curr_t >>= 1;
        if curr_t & 1 != 0 {
            curr_t += 1;
            let q: V = {
                let s = y_p.last_mut().unwrap();
                let mut t = s.clone();
                t.square();
                t
            };
            *(y_p.last_mut().unwrap()) = q
        }
        round_index += 1
    }
    Ok(mus)
}

pub fn verify_proof<T, U, V>(
    x_initial: &V,
    y_initial: &V,
    proof: T,
    t: u64,
    delta: usize,
    generate_r_value: &U,
    int_size_bits: usize,
) -> Result<(), ()>
where
    T: IntoIterator<Item = V>,
    U: Fn(&V, &V, &V, usize) -> Result<V::BigNum, ()>,
    V: ClassGroup,
    for<'a, 'b> &'a V: std::ops::Mul<&'b V, Output = V>,
    for<'a, 'b> &'a V::BigNum: std::ops::Mul<&'b V::BigNum, Output = V::BigNum>,
{
    let mut one: V::BigNum = One::one();
    if t & 1 != 0 {
        return Err(());
    }
    let (mut x, mut y): (V, V) = (x_initial.clone(), y_initial.clone());
    let final_t = calculate_final_t(t, delta);
    let mut curr_t = t;
    for mut mu in proof {
        if curr_t & 1 != 0 {
            return Err(());
        }
        let r = generate_r_value(x_initial, y_initial, &mu, int_size_bits)?;
        x.pow(r.clone());
        x *= &mu;
        mu.pow(r);
        y *= &mu;

        curr_t >>= 1;
        if curr_t & 1 == 1 {
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
