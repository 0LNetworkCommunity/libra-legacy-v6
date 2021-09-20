// Copyright 2018 Chia Network Inc and POA Networks Ltd.
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
#![deny(unsafe_code)]
#![allow(clashing_extern_declarations)] //////// 0L ////////
use num_traits::{One, Zero};
use std::ops::{Mul, MulAssign, Rem, ShlAssign};

pub mod gmp;

pub mod gmp_classgroup;
pub use self::gmp_classgroup::{
    do_compute,
    ffi::{export_obj, import_obj},
};
pub trait BigNum:
    Zero
    + One
    + Clone
    + PartialOrd
    + std::fmt::Debug
    + Rem
    + ShlAssign<usize>
    + for<'a> MulAssign<&'a Self>
    + std::ops::Sub<u64, Output = Self>
    + std::ops::Add<u64, Output = Self>
    + std::convert::From<u64>
    + for<'a> std::convert::From<&'a [u8]>
    + std::ops::Shl<usize, Output = Self>
    + std::ops::Shr<usize, Output = Self>
    + std::ops::Neg<Output = Self>
    + std::str::FromStr
    + for<'a> std::ops::Div<&'a Self, Output = Self>
    + Eq
    + std::hash::Hash
{
    fn probab_prime(&self, iterations: u32) -> bool;
    fn setbit(&mut self, offset: usize);
    fn mod_powm(&mut self, base: &Self, exponent: &Self, modulus: &Self);
}

pub trait BigNumExt: BigNum {
    fn frem_u32(&self, modulus: u32) -> u32;
    fn crem_u16(&mut self, modulus: u16) -> u16;
}

pub trait ClassGroup:
    Sized + Clone + for<'a> MulAssign<&'a Self> + for<'a> Mul<&'a Self> + PartialEq + std::fmt::Debug
{
    type BigNum: BigNum;

    /// Produces a `Self` from `a`, `b`, and a discriminant.
    fn from_ab_discriminant(a: Self::BigNum, b: Self::BigNum, discriminant: Self::BigNum) -> Self;

    /// Unmarshals a `Self` from a byte array and discriminant.
    ///
    /// The byte array will be in the format of two big-endian byte sequences
    /// concatenated together.
    fn from_bytes(bytearray: &[u8], discriminant: Self::BigNum) -> Self;

    /// Computes the identity element of `Self` for a given discriminant.
    ///
    /// If the discriminant is not valid, the result is unspecified.
    ///
    /// # Panics
    ///
    /// This may panic (but is not required to) if the discriminant is not
    /// valid. If this function does not panic, the results of future
    /// operations are unspecified: they will not invoke undefined behavior,
    /// but may panic, loop forever, or just compute garbage.
    ///
    /// In debug builds, this will always panic if the discriminant is invalid.
    fn identity_for_discriminant(discriminant: Self::BigNum) -> Self {
        Self::from_ab_discriminant(Self::BigNum::one(), Self::BigNum::one(), discriminant)
    }

    /// Serializes `self` to a byte array.  Returns `Err(s)` if there
    /// is not enough space in the buffer.
    ///
    /// The data must be serialized in twos-complement, big-endian format.
    fn serialize(&self, buf: &mut [u8]) -> std::result::Result<(), usize>;

    /// Deserializes a bignum from raw bytes.  The bytes **must** be interpreted
    /// as a big-endian unsigned integer.
    fn unsigned_deserialize_bignum(_: &[u8]) -> Self::BigNum;

    /// Reduce `self` in-place.
    fn reduce(&mut self);

    /// Squares `self`, modifying it in-place.
    ///
    /// A default implementation is provided, but implementations are suggested
    /// to override it for performance reasons.
    fn square(&mut self) {
        let s = self.clone();
        self.mul_assign(&s)
    }

    /// Normalize `self`.
    fn normalize(&mut self);

    /// The length of `num` in **bits**
    fn size_in_bits(num: &Self::BigNum) -> usize;

    /// Gets the discriminant of `self`.
    fn discriminant(&self) -> &Self::BigNum;

    /// Computes the identity element of a `ClassGroup`.
    fn identity(&self) -> Self {
        Self::identity_for_discriminant(self.discriminant().clone())
    }

    /// Generates a *generator* for the class group of `Self`, given a
    /// discriminant.
    ///
    /// If the discriminant is not valid, the result is unspecified.
    ///
    /// # Relation to `Self::identity_for_discriminant`
    ///
    /// This is *not* the same as `Self::identity_for_discriminant`: the
    /// identity element is *never* a generator for *any* group.  This follows
    /// from their definitions: the identity element, when multiplied by another
    /// element, always gives that other element, whereas *every* element in the
    /// group is some power of a generator.
    ///
    /// # Panics
    ///
    /// This may panic (but is not required to) if the discriminant is not
    /// valid. If this function does not panic, the results of future
    /// operations are unspecified: they will not invoke undefined behavior,
    /// but may panic, loop forever, or just compute garbage.
    ///
    /// If the global allocator panics on running out of memory, then this
    /// function may panic in the same situation, but it may also just abort the
    /// program instead.
    ///
    /// In debug builds, this will always panic if the discriminant is invalid.
    fn generator_for_discriminant(discriminant: Self::BigNum) -> Self {
        Self::from_ab_discriminant(2.into(), One::one(), discriminant)
    }

    /// Replaces `*self` with its inverse.
    fn inverse(&mut self);

    /// Squares `self` repeatedly in-place.
    ///
    /// Implementors of this trait are encouraged to override this
    /// with a more efficient implementation, if one exists.
    fn repeated_square(&mut self, iterations: u64) {
        for _ in 0..iterations {
            self.square()
        }
    }

    /// Exponentiation
    fn pow(&mut self, exponent: Self::BigNum);

    /// Deserialization
    fn deserialize(buf: &[u8], discriminant: Self::BigNum) -> Self;
}

#[cfg(test)]
mod test {

    use std::{
        fs::File,
        io::{BufRead, BufReader},
        path::PathBuf,
    };

    use super::gmp::mpz::Mpz;
    use super::{gmp_classgroup::GmpClassGroup, ClassGroup};

    fn split_into_three_pieces(line: &str, c: char) -> [&str; 3] {
        let mut iter = line.split(c);
        let fst = iter.next().expect("bad test file");
        let snd = iter.next().expect("bad test file");
        let thd = iter.next().expect("bad test file");
        assert!(iter.next().is_none(), "bad test file");
        [fst, snd, thd]
    }

    #[test]
    fn multiplication_is_correct() {
        let manifest_path =
            std::env::var("CARGO_MANIFEST_DIR").expect("cargo should have set this");
        let mut path = PathBuf::from(&manifest_path);
        path.push("tests/multiply.txt");
        let mut f = BufReader::new(File::open(path).expect("test file missing or unreadable"));
        let mut buffer = String::new();
        loop {
            let bytes_read = f
                .read_line(&mut buffer)
                .expect("could not read from test file");
            assert!(bytes_read == buffer.len());
            if bytes_read == 0 {
                break;
            }
            if buffer.ends_with('\n') {
                buffer.pop();
            }
            if buffer.ends_with('\r') {
                buffer.pop();
            }
            let mut current_discriminant: Option<Mpz> = None;
            let q: Vec<_> = split_into_three_pieces(&buffer, '|')
                .iter()
                .map(|i| {
                    let k = split_into_three_pieces(i, ',');

                    let a = Mpz::from_str_radix(k[0], 10).expect("bad test file");
                    let b = Mpz::from_str_radix(k[1], 10).expect("bad test file");
                    let c = Mpz::from_str_radix(k[2], 10).expect("bad test file");
                    let mut discriminant: Mpz = &b * &b;
                    let mut minuand: Mpz = (4u64).into();
                    minuand *= &a * &c;
                    discriminant -= &minuand;
                    assert!(discriminant < Mpz::zero());
                    // takes waaaay too long
                    // assert!(discriminant.probab_prime(20) !=
                    // gmp::mpz::ProbabPrimeResult::NotPrime);
                    if let Some(ref q) = current_discriminant {
                        assert_eq!(q, &discriminant, "mismatching discriminant in test files");
                    } else {
                        current_discriminant = Some(discriminant.clone());
                    }
                    GmpClassGroup::from_ab_discriminant(a, b, discriminant)
                })
                .collect();
            assert_eq!(q.len(), 3);
            if q[0] == q[1] {
                let mut i = q[0].clone();
                i.square();
                assert_eq!(i, q[2]);
            }
            assert_eq!(&q[1] * &q[0], q[2], "multiplication not valid");
            assert_eq!(&q[0] * &q[1], q[2], "multiplication not valid");
            buffer.clear();
        }
    }
}
