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

use classgroup::{
    gmp::mpz::{mpz_ptr, Mpz, mpz_srcptr},
    gmp_classgroup::GmpClassGroup,
    ClassGroup,
};
use libc;
use std::{env, process};

fn main() {
    let fail = |q| {
        eprintln!("{}", q);
        process::exit(1)
    };
    use libc;
    use std::{ffi::CString, mem, os::unix::ffi::OsStringExt};

    #[link = "gmp"]
    extern "C" {
        fn __gmpz_init_set_str(
            rop: mpz_ptr,
            ptr: *const libc::c_char,
            base: libc::c_int,
        ) -> libc::c_int;
        fn __gmpz_out_str(stream: *mut libc::FILE, base: libc::c_int, op: mpz_srcptr) -> libc::size_t;
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
        let (a, b) = generator.into_raw();
        unsafe {
            __gmpz_out_str(std::ptr::null_mut(), 10, a.inner());
            libc::putchar(b'\n'.into());
            __gmpz_out_str(std::ptr::null_mut(), 10, b.inner());
        }
    } else {
        fail("Invalid number of iterations");
    }
}
