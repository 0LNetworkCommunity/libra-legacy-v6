#![allow(unsafe_code)]
pub use gmp::mpz::Mpz;
use gmp::mpz::{mpz_ptr, mpz_srcptr};
use libc;
pub use libc::c_ulong;
use std::{isize, mem, usize};
// We use the unsafe versions to avoid unecessary allocations.
#[link(name = "gmp")]
extern "C" {
    fn __gmpz_gcdext(g: mpz_ptr, s: mpz_ptr, t: mpz_ptr, a: mpz_srcptr, b: mpz_srcptr);
    fn __gmpz_gcd(rop: mpz_ptr, op1: mpz_srcptr, op2: mpz_srcptr);
    fn __gmpz_fdiv_qr(q: mpz_ptr, r: mpz_ptr, b: mpz_srcptr, g: mpz_srcptr);
    fn __gmpz_fdiv_q(q: mpz_ptr, a: mpz_srcptr, b: mpz_srcptr);
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
    fn __gmpz_set_ui(rop: mpz_ptr, op: libc::c_ulong);
    fn __gmpz_neg(rop: mpz_ptr, op: mpz_srcptr);
    fn __gmpz_export(
        rop: *mut libc::c_void,
        countp: *mut libc::size_t,
        order: libc::c_int,
        size: libc::size_t,
        endian: libc::c_int,
        nails: libc::size_t,
        op: mpz_srcptr,
    ) -> *mut libc::c_void;
}

pub fn mpz_gcdext(g: &mut Mpz, s: &mut Mpz, t: &mut Mpz, a: &Mpz, b: &Mpz) {
    unsafe {
        __gmpz_gcdext(
            g.inner_mut(),
            s.inner_mut(),
            t.inner_mut(),
            a.inner(),
            b.inner(),
        )
    }
}

pub fn mpz_neg(rop: &mut Mpz, op: &Mpz) {
    unsafe {
        __gmpz_neg(rop.inner_mut(), op.inner());
    }
}

pub fn mpz_double(rop: &mut Mpz) {
    unsafe { __gmpz_mul_ui(rop.inner_mut(), rop.inner(), 2) }
}

pub fn mpz_set_ui(rop: &mut Mpz, op: c_ulong) {
    unsafe { __gmpz_set_ui(rop.inner_mut(), op) }
}

pub fn mpz_fdiv_qr(q: &mut Mpz, r: &mut Mpz, b: &Mpz, g: &Mpz) {
    unsafe { __gmpz_fdiv_qr(q.inner_mut(), r.inner_mut(), b.inner(), g.inner()) }
}

pub fn mpz_fdiv_q_ui_self(rop: &mut Mpz, op: c_ulong) -> c_ulong {
    unsafe { __gmpz_fdiv_q_ui(rop.inner_mut(), rop.inner(), op) }
}

pub fn import_obj(buf: &[u8]) -> Mpz {
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

pub fn three_gcd(rop: &mut Mpz, a: &Mpz, b: &Mpz, c: &Mpz) {
    unsafe {
        __gmpz_gcd(rop.inner_mut(), a.inner(), b.inner());
        __gmpz_gcd(rop.inner_mut(), rop.inner(), c.inner())
    }
}

pub fn size_in_bits(obj: &Mpz) -> usize {
    unsafe { __gmpz_sizeinbase(obj.inner(), 2) }
}

pub fn mpz_add(rop: &mut Mpz, op1: &Mpz, op2: &Mpz) {
    unsafe { __gmpz_add(rop.inner_mut(), op1.inner(), op2.inner()) }
}

pub fn mpz_mul(rop: &mut Mpz, op1: &Mpz, op2: &Mpz) {
    unsafe { __gmpz_mul(rop.inner_mut(), op1.inner(), op2.inner()) }
}

pub fn mpz_mul_ui(rop: &mut Mpz, op1: &Mpz, op2: libc::c_ulong) {
    unsafe { __gmpz_mul_ui(rop.inner_mut(), op1.inner(), op2) }
}

pub fn mpz_fdiv_q(rop: &mut Mpz, op1: &Mpz, op2: &Mpz) {
    unsafe { __gmpz_fdiv_q(rop.inner_mut(), op1.inner(), op2.inner()) }
}

pub fn mpz_fdiv_q_self(rop: &mut Mpz, op: &Mpz) {
    unsafe { __gmpz_fdiv_q(rop.inner_mut(), rop.inner(), op.inner()) }
}

pub fn mpz_sub(rop: &mut Mpz, op1: &Mpz, op2: &Mpz) {
    unsafe { __gmpz_sub(rop.inner_mut(), op1.inner(), op2.inner()) }
}

pub fn export_obj(obj: &Mpz, int_size_bits: usize, v: &mut Vec<u8>) -> Result<(), ()> {
    unsafe {
        let size = size_in_bits(obj);
        assert!(size <= usize::MAX - 7);
        if size > int_size_bits {
            Err(())
        } else {
            let l = v.len();
            debug_assert!(l <= isize::MAX as usize);
            v.reserve((size + 7) >> 3);
            let mut s: usize = mem::uninitialized();
            let vec_ptr = v.as_mut_ptr().add(l) as *mut _;
            let ptr = __gmpz_export(vec_ptr, &mut s, 1, 1, 1, 0, obj.inner());
            assert_eq!(ptr, vec_ptr);
            v.set_len(s + l);
            Ok(())
        }
    }
}
