use gmp::mpz::{mpz_ptr, mpz_srcptr, Mpz};
use num_traits::{One, Zero};
use std::fmt;
use libc;
// We use the unsafe versions to avoid unecessary allocations.
#[link(name = "gmp")]
extern "C" {
    fn __gmpz_gcdext(g: mpz_ptr, s: mpz_ptr, t: mpz_ptr, a: mpz_srcptr, b: mpz_srcptr);
    fn __gmpz_fdiv_qr(q: mpz_ptr, r: mpz_ptr, b: mpz_srcptr, g: mpz_srcptr);
    fn __gmpz_fdiv_q(q: mpz_ptr, a: mpz_srcptr, b: mpz_srcptr);
    fn __gmpz_mul(p: mpz_ptr, a: mpz_srcptr, b: mpz_srcptr);
    fn __gmpz_mul_ui(rop: mpz_ptr, op1: mpz_srcptr, op2: libc::c_ulong);
}

fn mpz_mul(rop: &mut Mpz, op1: &Mpz, op2: &Mpz) {
    unsafe {
        __gmpz_mul(rop.inner_mut(), op1.inner(), op2.inner())
    }
}

fn mpz_mul_ui(rop: &mut Mpz, op1: &Mpz, op2: libc::c_ulong) {
    unsafe {
        __gmpz_mul_ui(rop.inner_mut(), op1.inner(), op2)
    }
}

#[derive(PartialEq, PartialOrd, Eq, Ord, Hash, Debug, Clone)]
pub struct Form {
    a: Mpz,
    b: Mpz,
    c: Mpz,
    discriminant: Mpz,
}

#[derive(PartialEq, PartialOrd, Eq, Ord, Hash, Debug)]
pub struct Ctx {
    negative_a: Mpz,
    r: Mpz,
    denom: Mpz,
    old_a: Mpz,
    old_b: Mpz,
    ra: Mpz,
    s: Mpz,
    x: Mpz,
    g: Mpz,
    d: Mpz,
    e: Mpz,
    q: Mpz,
    w: Mpz,
    m: Mpz,
    u: Mpz,
    a: Mpz,
    b: Mpz,
    k: Mpz,
    mu: Mpz,
    v: Mpz,
    sigma: Mpz,
    lambda: Mpz,
}

impl fmt::Display for Form {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{:?}\n{:?}", self.a, self.b)
    }
}

impl Form {
    fn new(a: Mpz, b: Mpz, c: Mpz, discriminant: Mpz) -> Self {
        Form {
            a,
            b,
            c,
            discriminant,
        }
    }
    fn normalize(&mut self, ctx: &mut Ctx) {
        assert!(!self.a.is_zero());
        ctx.negative_a = -&self.a;
        if self.b > ctx.negative_a && self.b <= self.a {
            return;
        }
        mpz_mul_ui(&mut ctx.denom, &self.a, 2);
        ctx.r = (&self.a - &self.b).div_floor(&ctx.denom);
        ctx.old_b = self.b.clone();
        ctx.ra = &ctx.r * &self.a;
        self.b += &ctx.ra;
        self.b += &ctx.ra;
        ctx.ra *= &ctx.r;
        self.c += &ctx.ra;
        self.c += &ctx.r * &ctx.old_b;
    }
    fn reduce(&mut self, ctx: &mut Ctx) {
        self.normalize(ctx);
        while self.a > self.c || (self.a == self.c && self.b < Zero::zero()) {
            ctx.s = &self.c + &self.b;
            mpz_mul_ui(&mut ctx.x, &self.c, 2);
            unsafe {
                __gmpz_fdiv_q(ctx.s.inner_mut(), ctx.s.inner_mut(), ctx.x.inner())
            };
            ctx.old_a.set(&self.a);
            ctx.old_b.set(&self.b);
            self.a.set(&self.c);
            mpz_mul_ui(&mut self.b, &self.c, 2);
            self.b *= &ctx.s;
            self.b -= &ctx.old_b;
            self.c *= &ctx.s * &ctx.s;
            self.c -= &ctx.old_b * &ctx.s;
            self.c += &ctx.old_a;
        }
        self.normalize(ctx)
    }
    fn solve_linear_congruence(
        v: Option<&mut Mpz>,
        a: &Mpz,
        b: &Mpz,
        m: &Mpz,
        ctx: &mut Ctx,
    ) -> bool {
        unsafe {
            __gmpz_gcdext(
                ctx.g.inner_mut(),
                ctx.d.inner_mut(),
                ctx.e.inner_mut(),
                a.inner(),
                m.inner(),
            );
            __gmpz_fdiv_qr(
                ctx.q.inner_mut(),
                ctx.r.inner_mut(),
                b.inner(),
                ctx.g.inner_mut(),
            );
        }
        if !ctx.r.is_zero() {
            return false;
        }
        mpz_mul(&mut ctx.mu, &ctx.q, &ctx.d);
        ctx.mu = ctx.mu.modulus(m);
        v.map(|v| unsafe {
            __gmpz_fdiv_q(v.inner_mut(), m.inner(), ctx.g.inner());
        });
        true
    }
    fn square(&mut self, ctx: &mut Ctx) -> Result<(), ()> {
        if !Self::solve_linear_congruence(None, &self.b, &self.c, &self.a, ctx) {
            return Err(());
        }
        let two: Mpz = 2.into();
        ctx.m = &self.b * &ctx.mu;
        ctx.m -= &self.c;
        ctx.m = ctx.m.div_floor(&self.a);
        let f3_a = &self.a * &self.a;
        ctx.a = &ctx.mu * &self.a;
        ctx.a *= two;
        let f3_b = &self.b - &ctx.a;
        let mut f3_c = &ctx.mu * &ctx.mu;
        f3_c -= &ctx.m;
        *self = Self {
            a: f3_a,
            b: f3_b,
            c: f3_c,
            discriminant: self.discriminant.clone(),
        };
        Ok(self.reduce(ctx))
    }
    fn repeated_square(&self, iterations: u64, ctx: &mut Ctx) -> Result<Self, ()> {
        let mut f: Self = (*self).clone();
        for _ in 0..iterations {
            f.square(ctx)?
        }
        Ok(f)
    }
    pub fn generate_for_discriminant(discriminant: &Mpz, context: &mut Ctx) -> Self {
        let one: Mpz = One::one();
        let x: Mpz = one - discriminant;
        let mut form = Self::new(2.into(), One::one(), x.div_floor(&8.into()), Zero::zero());
        form.reduce(context);
        form
    }
}

impl Default for Form {
    fn default() -> Self {
        Form {
            a: Mpz::new(),
            b: Mpz::new(),
            c: Mpz::new(),
            discriminant: Mpz::new(),
        }
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
            g: Mpz::new(),
            d: Mpz::new(),
            e: Mpz::new(),
            q: Mpz::new(),
            w: Mpz::new(),
            m: Mpz::new(),
            u: Mpz::new(),
            a: Mpz::new(),
            b: Mpz::new(),
            k: Mpz::new(),
            mu: Mpz::new(),
            v: Mpz::new(),
            sigma: Mpz::new(),
            lambda: Mpz::new(),
        }
    }
}
pub fn do_compute(discriminant: &Mpz, iterations: u64) -> Form {
    let mut ctx = Default::default();
    Form::generate_for_discriminant(discriminant, &mut ctx).repeated_square(iterations, &mut ctx).unwrap()
}
