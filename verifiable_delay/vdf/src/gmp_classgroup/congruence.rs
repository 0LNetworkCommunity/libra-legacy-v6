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
#![forbid(unsafe_code)]
use self::ffi::Mpz;
use super::ffi;

#[derive(Clone, Hash, PartialEq, Eq, PartialOrd, Ord, Debug)]
pub struct CongruenceContext {
    g: Mpz,
    d: Mpz,
    e: Mpz,
    q: Mpz,
    r: Mpz,
}

impl Default for CongruenceContext {
    fn default() -> Self {
        Self {
            g: Mpz::new(),
            d: Mpz::new(),
            e: Mpz::new(),
            q: Mpz::new(),
            r: Mpz::new(),
        }
    }
}

impl CongruenceContext {
    pub fn solve_linear_congruence(
        &mut self,
        mu: &mut Mpz,
        v: Option<&mut Mpz>,
        a: &Mpz,
        b: &Mpz,
        m: &Mpz,
    ) {
        ffi::mpz_gcdext(&mut self.g, &mut self.d, &mut self.e, &a, &m);
        if cfg!(test) {
            println!(
                "g = {}, d = {}, e = {}, a = {}, m = {}",
                self.g, self.d, self.e, a, m
            );
        }
        ffi::mpz_fdiv_qr(&mut self.q, &mut self.r, &b, &self.g);
        assert!(self.r.is_zero());
        ffi::mpz_mul(mu, &self.q, &self.d);
        *mu = mu.modulus(m);
        if let Some(v) = v {
            ffi::mpz_fdiv_q(v, &m, &self.g)
        }
    }
}
