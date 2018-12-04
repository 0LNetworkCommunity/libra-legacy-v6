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

extern crate classgroup;
extern crate gmp;
use classgroup::{gmp_classgroup::GmpClassGroup, ClassGroup};
use gmp::mpz::{mpz_ptr, Mpz};
use std::{env, process};

#[cfg(unix)]
fn main() {
    let fail = |q| {
        eprintln!("{}", q);
        process::exit(1)
    };
    use std::{ffi::CString, mem, os::unix::ffi::OsStringExt};
    extern crate libc;

    #[link = "gmp"]
    extern "C" {
        fn __gmpz_init_set_str(
            rop: mpz_ptr,
            ptr: *const libc::c_char,
            base: libc::c_int,
        ) -> libc::c_int;
    }

    let mut args = env::args_os();

    if args.len() != 3 {
        fail("Must have exactly two arguments");
    }

    args.next();
    let discriminant = unsafe {
        let cstr = CString::from_vec_unchecked(args.next().unwrap().into_vec());
        let mut q: Mpz = mem::zeroed();
        if 0 == __gmpz_init_set_str(q.inner_mut(), cstr.as_ptr(), 0) {
            q
        } else {
            fail("Invalid discriminant")
        }
    };

    if let Some(iterations) = args.next().unwrap().to_str().and_then(|x| x.parse().ok()) {
        let mut generator = GmpClassGroup::generator_for_discriminant(discriminant);
        generator.repeated_square(iterations);
        println!("{}", generator);
    } else {
        fail("Invalid number of iterations");
    }
}
#[cfg(not(unix))]
fn main() {
    use std::str::FromStr;
    let fail = |q| {
        eprintln!("{}", q);
        process::exit(1)
    };
    let check_arg = |q: &mut env::ArgsOs| {
        if let Some(q) = q.next().and_then(|x| x.to_str().map(|x| x.to_owned())) {
            q
        } else {
            fail("Arguments must be valid UTF-8!".to_owned())
        }
    };
    let mut args = env::args_os();
    if args.len() != 3 {
        fail("Must have exactly two arguments".to_owned());
    }
    drop(args.next());
    let discriminant = Mpz::from_str_radix(&check_arg(&mut args), 0)
        .map_err(|x| fail(format!("{}", x)))
        .unwrap();
    let iterations: u64 = check_arg(&mut args)
        .parse()
        .map_err(|x| fail(format!("{}", x)))
        .unwrap();
    let mut generator = GmpClassGroup::generator_for_discriminant(discriminant);
    generator.repeated_square(iterations);
    println!("{}", generator);
}
