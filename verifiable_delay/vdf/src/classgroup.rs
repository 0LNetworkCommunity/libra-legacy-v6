use num_traits::{One, Pow, Zero};
use std::ops::{Mul, MulAssign};
pub trait ClassGroupPartial:
    Sized + Clone + for<'a> Mul<&'a Self> + for<'a> MulAssign<&'a Self> + PartialEq
{
    type BigNum: num_traits::NumOps + num_traits::NumAssignOps + Zero + One;
    fn from_ab_discriminant(a: Self::BigNum, b: Self::BigNum, discriminant: Self::BigNum) -> Self;
    fn from_bytes(bytearray: &[u8], discriminant: Self::BigNum) -> Self;
    fn identity_for_discriminant(discriminant: Self::BigNum) -> Self {
        Self::from_ab_discriminant(Self::BigNum::one(), Self::BigNum::one(), discriminant)
    }
    fn reduce(&mut self);
    fn square(&mut self) {
        let s = self.clone();
        self.mul_assign(&s)
    }
    fn normalize(&mut self);
    fn discriminant(&self) -> Self::BigNum;
    fn identity(&self) -> Self {
        Self::identity_for_discriminant(self.discriminant())
    }
    fn inverse(&mut self);
    fn repeated_square(&mut self, iterations: u64) {
        for _ in 0..iterations {
            self.square()
        }
    }
}

pub trait ClassGroup: ClassGroupPartial + Pow<<Self as ClassGroupPartial>::BigNum> {}
