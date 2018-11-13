#![allow(dead_code)]
use gmp::mpz::Mpz;
use std::ops::Index;

fn approximate_i(t: usize) -> usize {
    let x: f64 = (t as f64) / 16.;
    let w = x.log2() - x.log2().log2() + 0.25;
    (w / 2.).round() as _
}

fn sum_combinations<'a, T: IntoIterator<Item = &'a usize>>(numbers: T) -> Vec<usize> {
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

pub fn cache_indeces_for_count(t: usize) -> Vec<usize> {
    let i: usize = approximate_i(t);
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

fn calculate_final_t(t: usize, delta: usize) -> usize {
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
    ts[ts.len() - delta]
}

#[allow(clippy::too_many_arguments)]
pub fn generate_proof<T, U>(
    x: &Mpz,
    t: usize,
    delta: usize,
    y: &Mpz,
    powers: &T,
    identity: &Mpz,
    generate_r_value: &U,
    int_size_bits: usize,
) -> Result<Vec<Mpz>, ()>
where
    T: Index<usize, Output = Mpz>,
    U: Fn(&Mpz, &Mpz, &Mpz, usize) -> Result<Mpz, ()>,
{
    if t & 1 == 1 {
        panic!("T must be even")
    }
    let i = approximate_i(t);
    let mut mus = vec![];
    let mut rs = vec![];
    let mut x_p = vec![x.clone()];
    let mut y_p = vec![y.clone()];

    let mut curr_t = t;
    let mut ts = vec![];

    let final_t = calculate_final_t(t, delta);

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
                let mut r_prod: Mpz = 1.into();
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
                mu *= &powers[t_sum] * &r_prod
            }
            mu
        } else {
            let mut mu = x_p.last().unwrap().clone();
            for _ in 0..half_t {
                mu = &mu * &mu
            }
            mu
        });
        let mu = mus.last().unwrap();
        rs.push(generate_r_value(&x, &y, mu, int_size_bits)?);
        let mut last_r = rs.last().unwrap().clone();
        last_r *= mu;
        {
            let a = x_p.last().unwrap() * &last_r;
            x_p.push(a)
        }
        y_p.push(last_r);
        curr_t >>= 1;
        if curr_t & 1 != 0 {
            curr_t += 1;
            let q = {
                let s = y_p.last_mut().unwrap();

                let s_nonmut: &_ = &*s;
                s_nonmut * s_nonmut
            };
            *(y_p.last_mut().unwrap()) = q
        }
        round_index += 1
    }
    let one: Mpz = 1u64.into();
    assert_eq!(
        y_p.last().unwrap().clone(),
        x_p.last().unwrap() * (&one << final_t)
    );
    Ok(mus)
}
