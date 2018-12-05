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

//! FFI bindings to GMP.  This module exists because the `rust-gmp` crate
//! is too high-level.  High-performance bignum computation requires that
//! bignums be modified in-place, so that their storage can be reused.
//! Furthermore, the `rust-gmp` crate doesn’t support many operations that
//! this library requires.
#![allow(unsafe_code)]
pub use gmp::mpz::Mpz;
use gmp::mpz::{mpz_ptr, mpz_srcptr};
use libc;
pub use libc::c_ulong;
use std::{mem, usize};
// We use the unsafe versions to avoid unecessary allocations.
#[link(name = "gmp")]
extern "C" {
    fn __gmpz_gcdext(gcd: mpz_ptr, s: mpz_ptr, t: mpz_ptr, a: mpz_srcptr, b: mpz_srcptr);
    fn __gmpz_gcd(rop: mpz_ptr, op1: mpz_srcptr, op2: mpz_srcptr);
    fn __gmpz_fdiv_qr(q: mpz_ptr, r: mpz_ptr, b: mpz_srcptr, g: mpz_srcptr);
    fn __gmpz_fdiv_q(q: mpz_ptr, a: mpz_srcptr, b: mpz_srcptr);
    fn __gmpz_tdiv_q(q: mpz_ptr, a: mpz_srcptr, b: mpz_srcptr);
    fn __gmpz_mul(p: mpz_ptr, a: mpz_srcptr, b: mpz_srcptr);
    fn __gmpz_mul_ui(rop: mpz_ptr, op1: mpz_srcptr, op2: libc::c_ulong);
    fn __gmpz_sub(rop: mpz_ptr, op1: mpz_srcptr, op2: mpz_srcptr);
    fn __gmpz_import(
        rop: mpz_ptr,
        count: libc::size_t,
        order: libc::c_int,
        size: libc::size_t,
        endian: libc::c_int,
        nails: libc::size_t,
        op: *const libc::c_void,
    );
    fn __gmpz_sizeinbase(op: mpz_srcptr, base: libc::c_int) -> libc::size_t;
    fn __gmpz_fdiv_q_ui(rop: mpz_ptr, op1: mpz_srcptr, op2: libc::c_ulong) -> libc::c_ulong;
    fn __gmpz_add(rop: mpz_ptr, op1: mpz_srcptr, op2: mpz_srcptr);
    fn __gmpz_add_ui(rop: mpz_ptr, op1: mpz_srcptr, op2: libc::c_ulong);
    fn __gmpz_set_ui(rop: mpz_ptr, op: libc::c_ulong);
    fn __gmpz_set_si(rop: mpz_ptr, op: libc::c_long);
    fn __gmpz_neg(rop: mpz_ptr, op: mpz_srcptr);
    fn __gmpz_cdiv_ui(n: mpz_srcptr, d: libc::c_ulong) -> libc::c_ulong;
    fn __gmpz_fdiv_ui(n: mpz_srcptr, d: libc::c_ulong) -> libc::c_ulong;
    fn __gmpz_tdiv_ui(n: mpz_srcptr, d: libc::c_ulong) -> libc::c_ulong;
    fn __gmpz_export(
        rop: *mut libc::c_void,
        countp: *mut libc::size_t,
        order: libc::c_int,
        size: libc::size_t,
        endian: libc::c_int,
        nails: libc::size_t,
        op: mpz_srcptr,
    ) -> *mut libc::c_void;
    fn __gmpz_powm(rop: mpz_ptr, base: mpz_srcptr, exp: mpz_srcptr, modulus: mpz_srcptr);
}

// MEGA HACK: rust-gmp doesn’t expose the fields of this struct, so we must define
// it ourselves and cast.
//
// Should be stable though, as only GMP can change it, and doing would break binary compatibility.
#[repr(C)]
struct MpzStruct {
    mp_alloc: libc::c_int,
    mp_size: libc::c_int,
    mp_d: *mut gmp::mpz::mp_limb_t,
}

macro_rules! impl_div_ui {
    ($t:ident, $i:ident, $f:expr) => {
        pub fn $i(n: &Mpz, d: $t) -> $t {
            use std::$t;
            let res = unsafe { $f(n.inner(), libc::c_ulong::from(d)) };
            assert!(res <= $t::MAX.into());
            res as $t
        }
    };
}

impl_div_ui!(u16, mpz_crem_u16, __gmpz_cdiv_ui);
impl_div_ui!(u32, mpz_frem_u32, __gmpz_fdiv_ui);

/// Returns `true` if `z` is negative and not zero.  Otherwise,
/// returns `false`.
// #[inline]
pub fn mpz_is_negative(z: &Mpz) -> bool {
    unsafe { (*(z.inner() as *const MpzStruct)).mp_size < 0 }
}

// #[inline]
pub fn mpz_powm(rop: &mut Mpz, base: &Mpz, exponent: &Mpz, modulus: &Mpz) {
    unsafe {
        __gmpz_powm(
            rop.inner_mut(),
            base.inner(),
            exponent.inner(),
            modulus.inner(),
        )
    }
}

/// Sets `g` to the GCD of `a` and `b`.
// #[inline]
pub fn mpz_gcdext(gcd: &mut Mpz, s: &mut Mpz, t: &mut Mpz, a: &Mpz, b: &Mpz) {
    unsafe {
        __gmpz_gcdext(
            gcd.inner_mut(),
            s.inner_mut(),
            t.inner_mut(),
            a.inner(),
            b.inner(),
        )
    }
}

/// Sets `rop` to `(-1) * op`
// #[inline]
#[cfg(none)]
pub fn mpz_neg(rop: &mut Mpz, op: &Mpz) {
    unsafe { __gmpz_neg(rop.inner_mut(), op.inner()) }
}

/// Doubles `rop` in-place
// #[inline]
pub fn mpz_double(rop: &mut Mpz) {
    unsafe { __gmpz_add(rop.inner_mut(), rop.inner(), rop.inner()) }
}

// #[inline]
pub fn mpz_fdiv_qr(q: &mut Mpz, r: &mut Mpz, b: &Mpz, g: &Mpz) {
    unsafe { __gmpz_fdiv_qr(q.inner_mut(), r.inner_mut(), b.inner(), g.inner()) }
}

// #[inline]
pub fn mpz_fdiv_q_ui_self(rop: &mut Mpz, op: c_ulong) -> c_ulong {
    unsafe { __gmpz_fdiv_q_ui(rop.inner_mut(), rop.inner(), op) }
}

/// Unmarshals a buffer to an `Mpz`.  `buf` is interpreted as a 2’s complement,
/// big-endian integer.  If the buffer is empty, zero is returned.
pub fn import_obj(buf: &[u8]) -> Mpz {
    fn raw_import(buf: &[u8]) -> Mpz {
        let mut obj = Mpz::new();

        unsafe {
            __gmpz_import(
                obj.inner_mut(),
                buf.len(),
                1,
                1,
                1,
                0,
                buf.as_ptr() as *const _,
            )
        }
        obj
    }
    let is_negative = match buf.first() {
        None => return Mpz::zero(),
        Some(x) => x & 0x80 != 0,
    };
    if !is_negative {
        raw_import(buf)
    } else {
        let mut new_buf: Vec<_> = buf.iter().cloned().skip_while(|&x| x == 0xFF).collect();
        if new_buf.is_empty() {
            (-1).into()
        } else {
            for i in &mut new_buf {
                *i ^= 0xFF
            }
            !raw_import(&new_buf)
        }
    }
}

pub fn three_gcd(rop: &mut Mpz, a: &Mpz, b: &Mpz, c: &Mpz) {
    unsafe {
        __gmpz_gcd(rop.inner_mut(), a.inner(), b.inner());
        __gmpz_gcd(rop.inner_mut(), rop.inner(), c.inner())
    }
}

// #[inline]
pub fn size_in_bits(obj: &Mpz) -> usize {
    unsafe { __gmpz_sizeinbase(obj.inner(), 2) }
}

// #[inline]
pub fn mpz_add(rop: &mut Mpz, op1: &Mpz, op2: &Mpz) {
    unsafe { __gmpz_add(rop.inner_mut(), op1.inner(), op2.inner()) }
}

// #[inline]
pub fn mpz_mul(rop: &mut Mpz, op1: &Mpz, op2: &Mpz) {
    unsafe { __gmpz_mul(rop.inner_mut(), op1.inner(), op2.inner()) }
}

// #[inline]
pub fn mpz_mul_ui(rop: &mut Mpz, op1: &Mpz, op2: libc::c_ulong) {
    unsafe { __gmpz_mul_ui(rop.inner_mut(), op1.inner(), op2) }
}

/// Divide `n` by `d`.  Round towards -∞ and place the result in `q`.
pub fn mpz_fdiv_q(q: &mut Mpz, n: &Mpz, d: &Mpz) {
    if mpz_is_negative(n) == mpz_is_negative(n) {
        unsafe { __gmpz_tdiv_q(q.inner_mut(), n.inner(), d.inner()) }
    } else {
        unsafe { __gmpz_fdiv_q(q.inner_mut(), n.inner(), d.inner()) }
    }
}

pub fn mpz_fdiv_q_self(rop: &mut Mpz, op: &Mpz) {
    if mpz_is_negative(op) == mpz_is_negative(rop) {
        unsafe { __gmpz_tdiv_q(rop.inner_mut(), rop.inner(), op.inner()) }
    } else {
        unsafe { __gmpz_fdiv_q(rop.inner_mut(), rop.inner(), op.inner()) }
    }
}

// #[inline]
pub fn mpz_sub(rop: &mut Mpz, op1: &Mpz, op2: &Mpz) {
    unsafe { __gmpz_sub(rop.inner_mut(), op1.inner(), op2.inner()) }
}

/// Exports `obj` to `v` as an array of 2’s complement, big-endian
/// bytes.  If `v` is too small to hold the result, returns `Err(s)`,
/// where `s` is the size needed to hold the exported version of `obj`.
pub fn export_obj(obj: &Mpz, v: &mut [u8]) -> Result<(), usize> {
    // Requires: offset < v.len() and v[offset..] be able to hold all of `obj`
    unsafe fn raw_export(v: &mut [u8], offset: usize, obj: &Mpz) -> usize {
        // SAFE as `offset` will always be in-bounds, since byte_len always <=
        // byte_len_needed and we check that v.len() >= byte_len_needed.
        let ptr = v.as_mut_ptr().add(offset) as *mut libc::c_void;

        // Necessary ― this byte may not be fully overwritten
        *(ptr as *mut u8) = 0;

        // SAFE as __gmpz_export will *always* initialize this.
        let mut s: usize = mem::uninitialized();
        let ptr2 = __gmpz_export(ptr, &mut s, 1, 1, 1, 0, obj.inner());
        assert_eq!(ptr, ptr2);
        if 0 == s {
            1
        } else {
            s
        }
    }

    let size = size_in_bits(obj);
    assert!(size > 0);

    // Check to avoid integer overflow in later operations.
    if size > usize::MAX - 8 || v.len() > usize::MAX >> 3 {
        return Err(usize::MAX);
    }

    // One additional bit is needed for the sign bit.
    let byte_len_needed = (size + 8) >> 3;
    if v.len() < byte_len_needed {
        return if v.is_empty() && obj.is_zero() {
            Ok(())
        } else {
            Err(byte_len_needed)
        };
    }
    let is_negative = mpz_is_negative(obj);

    if is_negative {
        // MEGA HACK: GMP does not have a function to perform 2's complement
        let obj = !obj;
        debug_assert!(
            !mpz_is_negative(&obj),
            "bitwise negation of a negative number produced a negative number"
        );
        let new_byte_size = (size_in_bits(&obj) + 7) >> 3;
        let offset = v.len() - new_byte_size;

        for i in &mut v[..offset] {
            *i = 0xFF
        }
        unsafe {
            assert_eq!(raw_export(v, offset, &obj), new_byte_size);
        }

        // We had to do a one’s complement to get the data in a decent format,
        // so now we need to flip all of the bits back.  LLVM should be able to
        // vectorize this loop easily.
        for i in &mut v[offset..] {
            *i ^= 0xFF
        }
    } else {
        // ...but GMP will not include that in the number of bytes it writes
        // (except for negative numbers)
        let byte_len = (size + 7) >> 3;
        assert!(byte_len > 0);

        let offset = v.len() - byte_len;

        // Zero out any leading bytes
        for i in &mut v[..offset] {
            *i = 0
        }
        unsafe {
            assert_eq!(raw_export(v, offset, &obj), byte_len);
        }
    }

    Ok(())
}

#[cfg(test)]
mod test {
    use super::*;
    #[test]
    fn check_expected_bit_width() {
        let mut s: Mpz = (-2).into();
        assert_eq!(size_in_bits(&s), 2);
        s = !s;
        assert_eq!(s, 1.into());
        s.setbit(2);
        assert_eq!(s, 5.into());
    }

    #[test]
    fn check_export() {
        let mut s: Mpz = 0x100.into();
        s = !s;
        let mut buf = [0, 0, 0];
        export_obj(&s, &mut buf).expect("buffer should be large enough");
        assert_eq!(buf, [0xFF, 0xFE, 0xFF]);
        export_obj(&Mpz::zero(), &mut []).unwrap();
    }

    #[test]
    fn check_rem() {
        assert_eq!(mpz_crem_u16(&(-100i64).into(), 3), 1);
        assert_eq!(mpz_crem_u16(&(100i64).into(), 3), 2);
    }
}
