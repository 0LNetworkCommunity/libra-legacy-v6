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
use std::env;
#[cfg(unix)]
#[cfg(not(unix))]
use std::{process, str::FromStr};

#[cfg(unix)]
fn main() {
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
    args.next();
    let discriminant = unsafe {
        let mut q: Mpz = mem::uninitialized();
        assert!(
            0 == __gmpz_init_set_str(
                q.inner_mut(),
                CString::from_vec_unchecked(args.next().unwrap().into_vec()).as_ptr(),
                0
            )
        );
        q
    };
    let mut generator = GmpClassGroup::generator_for_discriminant(discriminant);
    generator.repeated_square(args.next().unwrap().to_str().unwrap().parse().unwrap());
    println!("{}", generator);
}
#[cfg(not(unix))]
fn main() {
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
