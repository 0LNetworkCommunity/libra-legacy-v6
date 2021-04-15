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

#[macro_use]
extern crate criterion;

use hex;

use classgroup::{gmp_classgroup::GmpClassGroup, ClassGroup};
use criterion::Criterion;
use std::{cell::RefCell, env, rc::Rc};
use vdf::create_discriminant;
fn bench_square(c: &mut Criterion) {
    let bench_params = |c: &mut Criterion, len: u16, seed: &[u8]| {
        let i = Rc::new(RefCell::new(GmpClassGroup::generator_for_discriminant(
            create_discriminant(seed, len),
        )));
        {
            let i = i.clone();
            c.bench_function(
                &format!("square with seed {}: {}", hex::encode(seed), len),
                move |b| b.iter(|| i.borrow_mut().square()),
            );
        }
        {
            let multiplier = i.borrow().clone();
            c.bench_function(
                &format!("multiply with seed {}: {}", hex::encode(seed), len),
                move |b| b.iter(|| *i.borrow_mut() *= &multiplier),
            );
        }
    };
    let seed = env::var("VDF_BENCHMARK_SEED")
        .ok()
        .and_then(|x| hex::decode(x).ok())
        .expect("bug in calling script");
    for &i in &[512, 1024, 2048] {
        bench_params(c, i, &seed)
    }
}

criterion_group!(benches, bench_square);
criterion_main!(benches);
