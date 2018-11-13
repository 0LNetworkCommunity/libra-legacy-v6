use gmp::mpz::{mpz_ptr, mpz_srcptr, Mpz};

// We use the unsafe versions to avoid unecessary allocations.
#[link(name = "gmp")]
extern "C" {
    pub(super) fn __gmpz_gcdext(g: mpz_ptr, s: mpz_ptr, t: mpz_ptr, a: mpz_srcptr, b: mpz_srcptr);
    pub(super) fn __gmpz_fdiv_qr(q: mpz_ptr, r: mpz_ptr, b: mpz_srcptr, g: mpz_srcptr);
    pub(super) fn __gmpz_fdiv_q(q: mpz_ptr, a: mpz_srcptr, b: mpz_srcptr);
    pub(super) fn __gmpz_mul(p: mpz_ptr, a: mpz_srcptr, b: mpz_srcptr);
    pub(super) fn __gmpz_mul_ui(rop: mpz_ptr, op1: mpz_srcptr, op2: libc::c_ulong);
    pub(super) fn __gmpz_sub(rop: mpz_ptr, op1: mpz_srcptr, op2: mpz_srcptr);
    pub(super) fn __gmpz_import(rop: mpz_ptr, count: libc::size_t, order: libc::c_int, size: libc::size_t,
                     endian: libc::c_int, nails: libc::size_t, op: *const libc::c_void);
    pub(super) fn __gmpz_sizeinbase(op: mpz_srcptr, base: libc::c_int) -> libc::size_t;
    pub(super) fn __gmpz_fdiv_q_ui(rop: mpz_ptr, op1: mpz_srcptr, op2: libc::c_ulong) -> libc::c_ulong;
    pub(super) fn __gmpz_add(rop: mpz_ptr, op1: mpz_srcptr, op2: mpz_srcptr);
}


pub(super) fn size_in_bits(obj: &Mpz) -> usize {
    __gmpz_sizeinbase(obj.inner(), 2)
}

fn mpz_add(rop: &mut Mpz, op1: &Mpz, op2: &Mpz) {
    unsafe { __gmpz_add(rop.inner_mut(), op1.inner(), op2.inner()) }
}

fn mpz_mul(rop: &mut Mpz, op1: &Mpz, op2: &Mpz) {
    unsafe { __gmpz_mul(rop.inner_mut(), op1.inner(), op2.inner()) }
}

fn mpz_mul_ui(rop: &mut Mpz, op1: &Mpz, op2: libc::c_ulong) {
    unsafe { __gmpz_mul_ui(rop.inner_mut(), op1.inner(), op2) }
}

fn mpz_fdiv_q(rop: &mut Mpz, op1: &Mpz, op2: &Mpz) {
    unsafe { __gmpz_fdiv_q(rop.inner_mut(), op1.inner(), op2.inner()) }
}

fn mpz_sub(rop: &mut Mpz, op1: &Mpz, op2: &Mpz) {
    unsafe { __gmpz_sub(rop.inner_mut(), op1.inner(), op2.inner()) }
}


pub(super) fn import_obj(buf: &[u8]) -> Mpz {
    let mut obj = Mpz::new();
    unsafe {
        __gmpz_import(obj.inner_mut(), buf.len(), 1, 1, 1, 0, buf.as_ptr() as *const _)
    }
    obj
}
