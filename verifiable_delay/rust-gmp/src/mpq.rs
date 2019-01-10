use super::mpz::{mpz_struct, Mpz, mpz_ptr, mpz_srcptr};
use super::mpf::{Mpf, mpf_srcptr};
use super::sign::Sign;
use ffi::*;
use libc::{c_char, c_double, c_int, c_ulong};
use std::ffi::CString;
use std::str::FromStr;
use std::error::Error;
use std::convert::From;
use std::mem::uninitialized;
use std::fmt;
use std::cmp::Ordering::{self, Greater, Less, Equal};
use std::ops::{Div, DivAssign, Mul, MulAssign, Add, AddAssign, Sub, SubAssign, Neg};
use num_traits::{Zero, One};

#[repr(C)]
pub struct mpq_struct {
    _mp_num: mpz_struct,
    _mp_den: mpz_struct
}

pub type mpq_srcptr = *const mpq_struct;
pub type mpq_ptr = *mut mpq_struct;

#[link(name = "gmp")]
extern "C" {
    fn __gmpq_init(x: mpq_ptr);
    fn __gmpq_clear(x: mpq_ptr);
    fn __gmpq_set(rop: mpq_ptr, op: mpq_srcptr);
    fn __gmpq_set_z(rop: mpq_ptr, op: mpz_srcptr);
    fn __gmpq_set_ui(rop: mpq_ptr, op1: c_ulong, op2: c_ulong);
    fn __gmpq_set_d(rop: mpq_ptr, op: c_double);
    fn __gmpq_set_f(rop: mpq_ptr, op: mpf_srcptr);
    fn __gmpq_cmp(op1: mpq_srcptr, op2: mpq_srcptr) -> c_int;
    fn __gmpq_cmp_ui(op1: mpq_srcptr, num2: c_ulong, den2: c_ulong) -> c_int;
    fn __gmpq_equal(op1: mpq_srcptr, op2: mpq_srcptr) -> c_int;
    fn __gmpq_add(sum: mpq_ptr, addend1: mpq_srcptr, addend2: mpq_srcptr);
    fn __gmpq_sub(difference: mpq_ptr, minuend: mpq_srcptr, subtrahend: mpq_srcptr);
    fn __gmpq_mul(product: mpq_ptr, multiplier: mpq_srcptr, multiplicand: mpq_srcptr);
    fn __gmpq_div(product: mpq_ptr, multiplier: mpq_srcptr, multiplicand: mpq_srcptr);
    fn __gmpq_neg(negated_operand: mpq_ptr, operand: mpq_srcptr);
    fn __gmpq_abs(rop: mpq_ptr, op: mpq_srcptr);
    fn __gmpq_inv(inverted_number: mpq_ptr, number: mpq_srcptr);
    fn __gmpq_get_num(numerator: mpz_ptr, rational: mpq_srcptr);
    fn __gmpq_get_den(denominator: mpz_ptr, rational: mpq_srcptr);
    fn __gmpq_set_num(rational: mpq_ptr, numerator: mpz_srcptr);
    fn __gmpq_set_den(rational: mpq_ptr, denominator: mpz_srcptr);
    fn __gmpq_canonicalize(rational: mpq_ptr);
    fn __gmpq_get_d(rational: mpq_srcptr) -> c_double;
    fn __gmpq_set_str(rop: mpq_ptr, str: *const c_char, base: c_int) -> c_int;
}

pub struct Mpq {
    mpq: mpq_struct,
}

unsafe impl Send for Mpq { }
unsafe impl Sync for Mpq { }

impl Drop for Mpq {
    fn drop(&mut self) { unsafe { __gmpq_clear(&mut self.mpq) } }
}

impl Mpq {
    pub unsafe fn inner(&self) -> mpq_srcptr {
        &self.mpq
    }

    pub unsafe fn inner_mut(&mut self) -> mpq_ptr {
        &mut self.mpq
    }

    pub fn new() -> Mpq {
        unsafe {
            let mut mpq = uninitialized();
            __gmpq_init(&mut mpq);
            Mpq { mpq: mpq }
        }
    }

    pub fn ratio(num: &Mpz, den: &Mpz) -> Mpq {
        unsafe {
            let mut res = Mpq::new();
            __gmpq_set_num(&mut res.mpq, num.inner());
            __gmpq_set_den(&mut res.mpq, den.inner());
            // Not canonicalizing is unsafe
            __gmpq_canonicalize(&mut res.mpq);
            res
        }
    }

    pub fn from_str_radix(s: &str, base: u8) -> Result<Mpq, ParseMpqError> {
        let s = CString::new(s).map_err(|_| ParseMpqError { _priv: () })?;
        let mut res = Mpq::new();
        unsafe {
            assert!(base == 0 || (base >= 2 && base <= 62));
            let r = __gmpq_set_str(&mut res.mpq, s.as_ptr(), base as c_int);

            if r == 0 {
                // Not canonicalizing is unsafe
                __gmpq_canonicalize(&mut res.mpq);
                Ok(res)
            } else {
                Err(ParseMpqError { _priv: () })
            }
        }
    }

    pub fn set(&mut self, other: &Mpq) {
        unsafe { __gmpq_set(&mut self.mpq, &other.mpq) }
    }

    pub fn set_z(&mut self, other: &Mpz) {
        unsafe { __gmpq_set_z(&mut self.mpq, other.inner()) }
    }

    pub fn set_d(&mut self, other: f64) {
        unsafe { __gmpq_set_d(&mut self.mpq, other) }
    }

    pub fn set_f(&mut self, other: &Mpf) {
        unsafe { __gmpq_set_f(&mut self.mpq, other.inner()) }
    }

    pub fn get_num(&self) -> Mpz {
        unsafe {
            let mut res = Mpz::new();
            __gmpq_get_num(res.inner_mut(), &self.mpq);
            res
        }
    }

    pub fn get_den(&self) -> Mpz {
        unsafe {
            let mut res = Mpz::new();
            __gmpq_get_den(res.inner_mut(), &self.mpq);
            res
        }
    }

    pub fn abs(&self) -> Mpq {
        unsafe {
            let mut res = Mpq::new();
            __gmpq_abs(&mut res.mpq, &self.mpq);
            res
        }
    }

    pub fn invert(&self) -> Mpq {
        unsafe {
            if self.is_zero() {
                panic!("divide by zero")
            }

            let mut res = Mpq::new();
            __gmpq_inv(&mut res.mpq, &self.mpq);
            res
        }
    }

    pub fn floor(&self) -> Mpz {
        let mut res = Mpz::new();
        unsafe {
            __gmpz_fdiv_q(res.inner_mut(), &self.mpq._mp_num, &self.mpq._mp_den);
        }
        res
    }

    pub fn ceil(&self) -> Mpz {
        let mut res = Mpz::new();
        unsafe {
            __gmpz_cdiv_q(res.inner_mut(), &self.mpq._mp_num, &self.mpq._mp_den);
        }
        res
    }

    pub fn sign(&self) -> Sign {
        self.get_num().sign()
    }

    pub fn one() -> Mpq {
        let mut res = Mpq::new();
        unsafe { __gmpq_set_ui(&mut res.mpq, 1, 1) }
        res
    }

    pub fn zero() -> Mpq { Mpq::new() }
    pub fn is_zero(&self) -> bool {
        unsafe { __gmpq_cmp_ui(&self.mpq, 0, 1) == 0 }
    }
}

#[derive(Debug)]
pub struct ParseMpqError {
    _priv: ()
}

impl fmt::Display for ParseMpqError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        self.description().fmt(f)
    }
}

impl Error for ParseMpqError {
    fn description(&self) -> &'static str {
        "invalid rational number"
    }

    fn cause(&self) -> Option<&'static Error> {
        None
    }
}

impl Clone for Mpq {
    fn clone(&self) -> Mpq {
        let mut res = Mpq::new();
        res.set(self);
        res
    }
}

impl Eq for Mpq { }
impl PartialEq for Mpq {
    fn eq(&self, other: &Mpq) -> bool {
        unsafe { __gmpq_equal(&self.mpq, &other.mpq) != 0 }
    }
}

impl Ord for Mpq {
    fn cmp(&self, other: &Mpq) -> Ordering {
        let cmp = unsafe { __gmpq_cmp(&self.mpq, &other.mpq) };
        if cmp == 0 {
            Equal
        } else if cmp < 0 {
            Less
        } else {
            Greater
        }
    }
}
impl PartialOrd for Mpq {
    fn partial_cmp(&self, other: &Mpq) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

macro_rules! div_guard {
    (Div, $what: expr) => {
        if $what.is_zero() {
            panic!("divide by zero")
        }
    };
    ($tr: ident, $what: expr) => {}
}

macro_rules! impl_oper {
    ($tr: ident, $meth: ident, $tr_assign: ident, $meth_assign: ident, $fun: ident) => {
        impl $tr<Mpq> for Mpq {
            type Output = Mpq;
            #[inline]
            fn $meth(self, other: Mpq) -> Mpq {
                self.$meth(&other)
            }
        }

        impl<'a> $tr<&'a Mpq> for Mpq {
            type Output = Mpq;
            #[inline]
            fn $meth(mut self, other: &Mpq) -> Mpq {
                self.$meth_assign(other);
                self
            }
        }

        impl<'a> $tr<Mpq> for &'a Mpq {
            type Output = Mpq;
            #[inline]
            fn $meth(self, mut other: Mpq) -> Mpq {
                unsafe {
                    div_guard!($tr, other);
                    $fun(&mut other.mpq, &self.mpq, &other.mpq);
                    other
                }
            }
        }

        impl<'a, 'b> $tr<&'a Mpq> for &'b Mpq {
            type Output = Mpq;
            fn $meth(self, other: &Mpq) -> Mpq {
                unsafe {
                    div_guard!($tr, *other);
                    let mut res = Mpq::new();
                    $fun(&mut res.mpq, &self.mpq, &other.mpq);
                    res
                }
            }
        }

        impl<'a> $tr_assign<Mpq> for Mpq {
            #[inline]
            fn $meth_assign(&mut self, other: Mpq) {
                self.$meth_assign(&other)
            }
        }

        impl<'a> $tr_assign<&'a Mpq> for Mpq {
            #[inline]
            fn $meth_assign(&mut self, other: &Mpq) {
                unsafe {
                    div_guard!($tr, *other);
                    $fun(&mut self.mpq, &self.mpq, &other.mpq)
                }
            }
        }
    }
}

impl_oper!(Add, add, AddAssign, add_assign, __gmpq_add);
impl_oper!(Sub, sub, SubAssign, sub_assign, __gmpq_sub);
impl_oper!(Mul, mul, MulAssign, mul_assign, __gmpq_mul);
impl_oper!(Div, div, DivAssign, div_assign, __gmpq_div);

impl<'b> Neg for &'b Mpq {
    type Output = Mpq;
    fn neg(self) -> Mpq {
        unsafe {
            let mut res = Mpq::new();
            __gmpq_neg(&mut res.mpq, &self.mpq);
            res
        }
    }
}

impl Neg for Mpq {
    type Output = Mpq;
    #[inline]
    fn neg(mut self) -> Mpq {
        unsafe {
            __gmpq_neg(&mut self.mpq, &self.mpq);
            self
        }
    }
}

impl From<Mpq> for f64 {
    fn from(other: Mpq) -> f64 {
        f64::from(&other)
    }
}

impl<'a> From<&'a Mpq> for f64 {
    fn from(other: &Mpq) -> f64 {
        unsafe {
            __gmpq_get_d(&other.mpq) as f64
        }
    }
}

impl From<Mpz> for Mpq {
    fn from(other: Mpz) -> Mpq {
        Mpq::from(&other)
    }
}

impl<'a> From<&'a Mpz> for Mpq {
    fn from(other: &Mpz) -> Mpq {
        let mut res = Mpq::new();
        res.set_z(&other);
        res
    }
}

impl From<i64> for Mpq {
    fn from(other: i64) -> Mpq {
        From::<Mpz>::from(From::<i64>::from(other))
    }
}

impl From<i32> for Mpq {
    fn from(other: i32) -> Mpq {
        From::<Mpz>::from(From::<i32>::from(other))
    }
}

impl From<u64> for Mpq {
    fn from(other: u64) -> Mpq {
        From::<Mpz>::from(From::<u64>::from(other))
    }
}

impl From<u32> for Mpq {
    fn from(other: u32) -> Mpq {
        From::<Mpz>::from(From::<u32>::from(other))
    }
}

impl FromStr for Mpq {
    type Err = ParseMpqError;
    fn from_str(s: &str) -> Result<Mpq, ParseMpqError> {
        Mpq::from_str_radix(s, 10)
    }
}


impl fmt::Debug for Mpq {
    /// Renders as `numer/denom`. If denom=1, renders as numer.
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        fmt::Display::fmt(&self, f)
    }
}

impl fmt::Display for Mpq {
    /// Renders as `numer/denom`. If denom=1, renders as numer.
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        let numer = self.get_num();
        let denom = self.get_den();

        if denom == From::<i64>::from(1) {
            write!(f, "{}", numer)
        } else {
            write!(f, "{}/{}", numer, denom)
        }
    }
}

impl Zero for Mpq {
    #[inline]
    fn zero() -> Mpq {
        Mpq::zero()
    }

    #[inline]
    fn is_zero(&self) -> bool {
        self.is_zero()
    }
}

impl One for Mpq {
    #[inline]
    fn one() -> Mpq {
        Mpq::one()
    }
}
