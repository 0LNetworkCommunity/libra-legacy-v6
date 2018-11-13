#![deny(unsafe_code)]
use classgroup::ClassGroupPartial;
use num_traits::{One, Zero};
use std::cell::RefCell;
use std::fmt;
use std::ops::{Mul, MulAssign};

mod congruence;
mod ffi;

pub use self::ffi::{export_obj, import_obj, Mpz};

#[derive(PartialEq, PartialOrd, Eq, Ord, Hash, Debug, Clone)]
pub struct GmpClassGroup {
    a: Mpz,
    b: Mpz,
    c: Mpz,
    discriminant: Mpz,
}

#[derive(PartialEq, PartialOrd, Eq, Ord, Clone, Hash, Debug)]
pub struct Ctx {
    negative_a: Mpz,
    r: Mpz,
    denom: Mpz,
    old_a: Mpz,
    old_b: Mpz,
    ra: Mpz,
    s: Mpz,
    x: Mpz,
    congruence_context: congruence::CongruenceContext,
    h: Mpz,
    w: Mpz,
    m: Mpz,
    u: Mpz,
    a: Mpz,
    l: Mpz,
    j: Mpz,
    b: Mpz,
    k: Mpz,
    t: Mpz,
    mu: Mpz,
    v: Mpz,
    sigma: Mpz,
    lambda: Mpz,
}

thread_local! {
    static CTX: RefCell<Ctx> = Default::default();
}

impl fmt::Display for GmpClassGroup {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{:?}\n{:?}", self.a, self.b)
    }
}

impl GmpClassGroup {
    fn new(a: Mpz, b: Mpz, c: Mpz, discriminant: Mpz) -> Self {
        GmpClassGroup {
            a,
            b,
            c,
            discriminant,
        }
    }

    fn inner_normalize(&mut self, ctx: &mut Ctx) {
        //eprintln!("{:?}", self);
        ctx.negative_a = -&self.a;
        //dbg!(&self);
        if self.b > ctx.negative_a && self.b <= self.a {
            //eprintln!("{:?}", self);

            return;
        }
        ffi::mpz_sub(&mut ctx.r, &self.a, &self.b);
        ffi::mpz_mul_ui(&mut ctx.denom, &self.a, 2);
        //dbg!(&ctx.r);
        ffi::mpz_fdiv_q_self(&mut ctx.r, &ctx.denom);
        ctx.old_b.set(&self.b);
        ffi::mpz_mul(&mut ctx.ra, &ctx.r, &self.a);
        self.b += &ctx.ra;
        self.b += &ctx.ra;
        //assert!(!self.b.is_zero());

        ctx.ra *= &ctx.r;
        self.c += &ctx.ra;

        ffi::mpz_mul(&mut ctx.ra, &ctx.r, &ctx.old_b);
        self.c += &ctx.ra;
        //eprintln!("{:?}", self);
    }

    fn inner_reduce(&mut self, ctx: &mut Ctx) {
        self.inner_normalize(ctx);

        while self.a > self.c || (self.a == self.c && self.b < Zero::zero()) {
            ffi::mpz_add(&mut ctx.s, &self.c, &self.b);
            ffi::mpz_mul_ui(&mut ctx.x, &self.c, 2);
            ffi::mpz_fdiv_q_self(&mut ctx.s, &ctx.x);
            ctx.old_a.set(&self.a);
            ctx.old_b.set(&self.b);

            self.a.set(&self.c);
            ffi::mpz_neg(&mut self.b, &ctx.old_b);

            // x = 2sc
            ffi::mpz_mul(&mut ctx.x, &ctx.s, &self.c);
            ffi::mpz_double(&mut ctx.x);

            // b += x
            self.b += &ctx.x;

            // c = cs^2
            self.c *= &ctx.s;
            self.c *= &ctx.s;

            // x = bs
            ffi::mpz_mul(&mut ctx.x, &ctx.old_b, &ctx.s);

            // c -= x
            self.c -= &ctx.x;

            // c += a
            self.c += &ctx.old_a;
        }
        self.inner_normalize(ctx);
        //eprintln!();
    }

    fn inner_square(&mut self, ctx: &mut Ctx) {
        assert!(ctx.congruence_context.solve_linear_congruence(
            &mut ctx.mu,
            None,
            &self.b,
            &self.c,
            &self.a,
        ));
        ffi::mpz_mul(&mut ctx.m, &self.b, &ctx.mu);
        ctx.m -= &self.c;
        ctx.m = ctx.m.div_floor(&self.a);

        // New a
        ctx.old_a.set(&self.a);
        ffi::mpz_mul(&mut self.a, &ctx.old_a, &ctx.old_a);

        // New b
        ffi::mpz_mul(&mut ctx.a, &ctx.mu, &ctx.old_a);
        ffi::mpz_double(&mut ctx.a);
        self.b -= &ctx.a;

        // New c
        ffi::mpz_mul(&mut self.c, &ctx.mu, &ctx.mu);
        self.c -= &ctx.m;
        self.inner_reduce(ctx);
        //assert!(!self.b.is_zero())
    }

    /// Call `cb` with a mutable reference to the context of type `Ctx`.
    ///
    /// The reference cannot escape the closure and cannot be sent across threads.
    ///
    /// # Panics
    ///
    /// Panics if called recursively.  This library guarantees that it will never
    /// call this function from any function that takes a parameter of type `&mut Ctx`.
    pub fn with_context<T, U>(cb: T) -> U
    where
        T: FnOnce(&mut Ctx) -> U,
    {
        let mut opt = None;
        CTX.with(|x| opt.replace(cb(&mut x.borrow_mut())));
        opt.unwrap()
    }

    pub fn generate_for_discriminant(discriminant: &Mpz) -> Self {
        let one: Mpz = One::one();
        let x: Mpz = one - discriminant;
        let mut form = Self::new(
            2.into(),
            One::one(),
            x.div_floor(&8.into()),
            discriminant.clone(),
        );
        form.reduce();
        form
    }
}

impl Default for GmpClassGroup {
    fn default() -> Self {
        GmpClassGroup {
            a: Mpz::new(),
            b: Mpz::new(),
            c: Mpz::new(),
            discriminant: Mpz::new(),
        }
    }
}

impl MulAssign<Self> for GmpClassGroup {
    fn mul_assign(&mut self, rhs: Self) {
        *self *= &rhs
    }
}

impl<'a, 'b> Mul<&'b GmpClassGroup> for &'a GmpClassGroup {
    type Output = GmpClassGroup;
    fn mul(self, rhs: &'b Self::Output) -> Self::Output {
        let mut s = self.clone();
        s *= rhs;
        s
    }
}

impl<'a> Mul<GmpClassGroup> for &'a GmpClassGroup {
    type Output = GmpClassGroup;
    fn mul(self, rhs: Self::Output) -> Self::Output {
        let mut s = self.clone();
        s *= &rhs;
        s
    }
}

impl Mul<&Self> for GmpClassGroup {
    type Output = Self;
    fn mul(mut self, rhs: &Self) -> Self {
        self *= rhs;
        self
    }
}

impl Mul<Self> for GmpClassGroup {
    type Output = Self;
    fn mul(mut self, rhs: Self) -> Self {
        self *= rhs;
        self
    }
}

impl MulAssign<&Self> for GmpClassGroup {
    fn mul_assign(&mut self, rhs: &Self) {
        assert!(self.discriminant == rhs.discriminant);
        GmpClassGroup::with_context(|ctx| {
            ffi::mpz_add(&mut ctx.a, &self.b, &rhs.b);
            ffi::mpz_fdiv_q_ui_self(&mut ctx.a, 2);
            ffi::mpz_sub(&mut ctx.h, &rhs.b, &self.b);
            ffi::mpz_fdiv_q_ui_self(&mut ctx.h, 2);
            ffi::three_gcd(&mut ctx.w, &self.a, &rhs.a, &ctx.a);
            ctx.j.set(&ctx.w);
            ffi::mpz_set_ui(&mut ctx.r, 0);
            ffi::mpz_fdiv_q(&mut ctx.s, &self.a, &ctx.w);
            ffi::mpz_fdiv_q(&mut ctx.t, &rhs.a, &ctx.w);
            ffi::mpz_fdiv_q(&mut ctx.u, &ctx.a, &ctx.w);
            ffi::mpz_mul(&mut ctx.a, &ctx.t, &ctx.u);
            ffi::mpz_mul(&mut ctx.b, &ctx.h, &ctx.u);
            ffi::mpz_mul(&mut ctx.m, &ctx.s, &self.c);
            ctx.b += &ctx.m;
            ffi::mpz_mul(&mut ctx.m, &ctx.s, &ctx.t);
            assert!(ctx.congruence_context.solve_linear_congruence(
                &mut ctx.mu,
                Some(&mut ctx.v),
                &ctx.a,
                &ctx.b,
                &ctx.m,
            ));
            ffi::mpz_mul(&mut ctx.a, &ctx.t, &ctx.v);
            ffi::mpz_mul(&mut ctx.m, &ctx.t, &ctx.mu);
            ffi::mpz_sub(&mut ctx.b, &ctx.h, &ctx.m);
            ctx.m.set(&ctx.s);
            assert!(ctx.congruence_context.solve_linear_congruence(
                &mut ctx.lambda,
                Some(&mut ctx.sigma),
                &ctx.a,
                &ctx.b,
                &ctx.m,
            ));
            ffi::mpz_mul(&mut ctx.a, &ctx.v, &ctx.lambda);
            ffi::mpz_add(&mut ctx.k, &ctx.mu, &ctx.a);
            ffi::mpz_mul(&mut ctx.l, &ctx.k, &ctx.t);
            ctx.l -= &ctx.h;
            ffi::mpz_fdiv_q_self(&mut ctx.l, &ctx.s);

            ffi::mpz_mul(&mut ctx.m, &ctx.t, &ctx.u);
            ctx.m *= &ctx.k;
            ffi::mpz_mul(&mut ctx.a, &ctx.h, &ctx.u);
            ctx.m *= &ctx.a;
            ffi::mpz_mul(&mut ctx.a, &self.c, &ctx.s);
            ctx.m -= &ctx.a;
            ffi::mpz_mul(&mut ctx.a, &ctx.s, &ctx.t);
            ffi::mpz_fdiv_q_self(&mut ctx.m, &ctx.a);
            ffi::mpz_mul(&mut self.a, &ctx.s, &ctx.t);
            ffi::mpz_mul(&mut ctx.a, &ctx.r, &ctx.u);
            self.a -= &ctx.a;

            // B = ju + mr - (kt + ls)
            ffi::mpz_mul(&mut self.b, &ctx.j, &ctx.u);
            ffi::mpz_mul(&mut ctx.a, &ctx.m, &ctx.r);
            ffi::mpz_mul(&mut ctx.a, &ctx.k, &ctx.t);
            self.b += &ctx.a;
            ffi::mpz_mul(&mut ctx.a, &ctx.l, &ctx.s);
            self.b -= &ctx.a;

            // C = kl - jm
            ffi::mpz_mul(&mut self.c, &ctx.k, &ctx.l);
            ffi::mpz_mul(&mut ctx.a, &ctx.j, &ctx.m);
            self.c -= &ctx.a;

            self.reduce();
        })
    }
}

impl ClassGroupPartial for GmpClassGroup {
    type BigNum = Mpz;

    /// Normalize `self`.
    ///
    /// # Panics
    ///
    /// Panics if called within a call to `Self::with_context`.
    fn normalize(&mut self) {
        Self::with_context(|x| self.inner_normalize(x))
    }

    fn inverse(&mut self) {
        self.b = -self.b.clone();
    }

    fn from_bytes(bytearray: &[u8], discriminant: Self::BigNum) -> Self {
        let len = (ffi::size_in_bits(&discriminant) + 16) >> 4;
        let a = ffi::import_obj(&bytearray[..len]);
        let b = ffi::import_obj(&bytearray[len..]);
        Self::from_ab_discriminant(a, b, discriminant)
    }

    fn from_ab_discriminant(a: Self::BigNum, b: Self::BigNum, discriminant: Self::BigNum) -> Self {
        let mut four_a: Self::BigNum = 4u64.into();
        four_a *= &a;
        let c = (&b * &b - &discriminant) / four_a;
        Self {
            a,
            b,
            c,
            discriminant,
        }
    }

    /// Returns the discriminant of `self`.
    fn discriminant(&self) -> Self::BigNum {
        self.discriminant.clone()
    }

    /// Reduce `self`.
    ///
    /// # Panics
    ///
    /// Panics if called within a call to `Self::with_context`.
    fn reduce(&mut self) {
        Self::with_context(|x| self.inner_reduce(x))
    }

    /// Square `self`.ClassGroupPartial
    ///
    /// # Panics
    ///
    /// Panics if called within the scope of a call to `with_context`.
    fn square(&mut self) {
        Self::with_context(|ctx| self.inner_square(ctx))
    }

    /// Square `self` `iterations` times.
    ///
    /// # Panics
    ///
    /// Panics if called within the scope of a call to `with_context`.
    fn repeated_square(&mut self, iterations: u64) {
        Self::with_context(|ctx| {
            for _ in 0..iterations {
                self.inner_square(ctx)
            }
        })
    }
}

impl Default for Ctx {
    fn default() -> Self {
        Self {
            negative_a: Mpz::new(),
            r: Mpz::new(),
            denom: Mpz::new(),
            old_a: Mpz::new(),
            old_b: Mpz::new(),
            ra: Mpz::new(),
            s: Mpz::new(),
            x: Mpz::new(),
            congruence_context: Default::default(),
            w: Mpz::new(),
            m: Mpz::new(),
            u: Mpz::new(),
            l: Mpz::new(),
            j: Mpz::new(),
            t: Mpz::new(),
            a: Mpz::new(),
            b: Mpz::new(),
            k: Mpz::new(),
            h: Mpz::new(),
            mu: Mpz::new(),
            v: Mpz::new(),
            sigma: Mpz::new(),
            lambda: Mpz::new(),
        }
    }
}

pub fn do_compute(discriminant: &Mpz, iterations: u64) -> GmpClassGroup {
    let mut f = GmpClassGroup::generate_for_discriminant(discriminant);
    f.repeated_square(iterations);
    f
}

#[cfg(test)]
mod test {
    #![allow(unused_imports)]
    use super::*;
    #[test]
    fn normalize() {
        let mut s = GmpClassGroup::new(
            16.into(),
            (-23).into(),
            5837_3892.into(),
            (-0xdead_beefi64).into(),
        );
        let mut new = GmpClassGroup {
            b: 9.into(),
            c: 5837_3885.into(),
            ..s.clone()
        };
        s.normalize();
        assert_eq!(s, new);

        s = GmpClassGroup {
            a: (1 << 16).into(),
            b: (-76951).into(),
            c: 36840.into(),
            ..s
        };
        new = GmpClassGroup {
            b: 54121.into(),
            c: 25425.into(),
            ..s.clone()
        };
        s.normalize();
        assert_eq!(s, new);
    }

    #[test]
    fn reduce() {
        let mut s = GmpClassGroup::new(
            125_888_400.into(),
            (-225_748_919).into(),
            101_205_867.into(),
            (-0xdead_beefi64).into(),
        );
        let new = GmpClassGroup {
            a: 7621.into(),
            b: (-2503).into(),
            c: 139_272.into(),
            ..s.clone()
        };
        s.reduce();
        assert_eq!(s, new);
    }
}
