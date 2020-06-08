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
#![deny(warnings)]
//! # Rust implementations of class groups and verifyable delay functions
//!
//! This repo includes three crates
//!
//! * `classgroup`, which includes a class group implementation, as well as a
//!   trait for class groups.
//! * `vdf`, which includes a Verifyable Delay Function (VDF) trait, as well as
//!   an implementation of that trait.
//! * `vdf-cli`, which includes a command-line interface to the `vdf` crate.  It
//!   also includes additional commands, which are deprecated and will later be
//!   replaced by a CLI to the `classgroup` crate.
//!
//! ## Usage
//!
//! First, install Rust, Cargo, and the GNU Multiprecision Library (GMP).  Then,
//! follow one of the below steps.
//!
//! ### To use the command line interface
//!
//! ```sh
//! $ git clone https://github.com/poanetwork/vdf
//! $ cd vdf
//! $ cargo install
//! $ vdf-cli aa 100
//! 005271e8f9ab2eb8a2906e851dfcb5542e4173f016b85e29d481a108dc82ed3b3f97937b7aa824801138d1771dea8dae2f6397e76a80613afda30f2c30a34b040baaafe76d5707d68689193e5d211833b372a6a4591abb88e2e7f2f5a5ec818b5707b86b8b2c495ca1581c179168509e3593f9a16879620a4dc4e907df452e8dd0ffc4f199825f54ec70472cc061f22eb54c48d6aa5af3ea375a392ac77294e2d955dde1d102ae2ace494293492d31cff21944a8bcb4608993065c9a00292e8d3f4604e7465b4eeefb494f5bea102db343bb61c5a15c7bdf288206885c130fa1f2d86bf5e4634fdc4216bc16ef7dac970b0ee46d69416f9a9acee651d158ac64915b
//! $ vdf-cli aa 100 005271e8f9ab2eb8a2906e851dfcb5542e4173f016b85e29d481a108dc82ed3b3f97937b7aa824801138d1771dea8dae2f6397e76a80613afda30f2c30a34b040baaafe76d5707d68689193e5d211833b372a6a4591abb88e2e7f2f5a5ec818b5707b86b8b2c495ca1581c179168509e3593f9a16879620a4dc4e907df452e8dd0ffc4f199825f54ec70472cc061f22eb54c48d6aa5af3ea375a392ac77294e2d955dde1d102ae2ace494293492d31cff21944a8bcb4608993065c9a00292e8d3f4604e7465b4eeefb494f5bea102db343bb61c5a15c7bdf288206885c130fa1f2d86bf5e4634fdc4216bc16ef7dac970b0ee46d69416f9a9acee651d158ac64915b
//! Proof is valid
//! ```
//!
//! ### To use the VDF library
//!
//! ```rust
//! extern crate vdf;
//! use vdf::{InvalidProof, PietrzakVDFParams, VDFParams, WesolowskiVDFParams, VDF};
//!
//! # fn main() {
//!     let pietrzak_vdf = PietrzakVDFParams(2048).new();
//!     let solution = pietrzak_vdf.solve(b"\xaa", 100).unwrap();
//!     assert!(pietrzak_vdf.verify(b"\xaa", 100, &solution[..]).is_ok());
//! # }
//! ```
//!
//! ### To run the benchmarks
//!
//! Benchmarks are provided for the classgroup operations.  Run `cargo bench`
//! to run them.  Additional benchmarks are under development.
use classgroup;

mod create_discriminant;
use std::fmt::Debug;

pub use self::{
    create_discriminant::create_discriminant,
    proof_pietrzak::{PietrzakVDF, PietrzakVDFParams},
    proof_wesolowski::{WesolowskiVDF, WesolowskiVDFParams},
};

/// Message used to report an internal miscalculation of serialization buffer
/// sizes.
const INCORRECT_BUFFER_SIZE: &str =
    "internal error: incorrect buffer size calculation (this is a bug)";

mod proof_of_time;
mod proof_pietrzak;
mod proof_wesolowski;

/// An empty struct indicating verification failure.
///
/// For security reasons, the functions that perform verification *do not*
/// return any information on failure.  Use `VDF::validate_params` to check if
/// the parameters are correct.
#[derive(Clone, Copy, Eq, PartialEq, PartialOrd, Ord, Hash, Debug)]
pub struct InvalidProof;

/// An error return indicating an invalid number of iterations.  The string is a
/// human-readable message describing the valid iterations.  It should not be
/// interpreted by programs.
#[derive(Clone, Eq, PartialEq, PartialOrd, Ord, Hash, Debug)]
pub struct InvalidIterations(String);

/// The type of VDF parameters.
///
/// Parameters represent public information that can be shared by all users
/// of the protocol.  As such, they must implement `Clone`, so that they can
/// be duplicated.  They also must implement `Send`, so that a parallel
/// application can send them safely across threads.
///
/// The parameters *do not* include the difficulty level (usually an
/// iteration count), since that can be separate for each invocation.
///
/// This must implement `Clone` and `Eq`.
pub trait VDFParams: Clone + Eq {
    type VDF: VDF + Sized;

    /// Creates an instance of this VDF from the given parameters.
    ///
    /// # Performance
    ///
    /// This method is expected to be fairly cheap.  For example, it is okay if
    /// it allocates memory, but it should not perform expensive computations or
    /// I/O.
    ///
    /// # Panics
    ///
    /// This method **MUST NOT** fail due to invalid values for `params`.  Such
    /// errors should be checked by the factory functions for `Self::Params`.
    ///
    /// This function **MAY** panic for other reasons.  For example, it is
    /// allowed to panic if an allocation fails, or if a needed external library
    /// could not be dynamically loaded.
    fn new(self) -> Self::VDF;
}

/// A Verifiable Delay Function (VDF).
///
/// VDFs are problems that require a certain amount of time to solve, even on a
/// parallel machine, but can be validated much more easily.
///
/// While VDFs are considered to be cryptographic primitives, they generally do
/// *not* operate on highly sensitive data.  As such, implementers of this trait
/// **do not** guarantee that they will be immune to side-channel attacks, and
/// consumers of this trait **MUST NOT** expect this.
///
/// Instances of this trait are *not* expected to be `Sync`.  This allows them
/// to reuse allocations (such as scratch memory) accross invocations without
/// the need for locking.  However, they **MUST** be `Send` and `Clone`, so that
/// consumers can duplicate them and send them across threads.
pub trait VDF: Send + Debug {
    /// Solve an instance of this VDF, with challenge `challenge` and difficulty
    /// `difficulty`.
    ///
    /// The output is to be returned in a `Vec<u8>`, so it can be stored to disk
    /// or sent over the network.
    ///
    /// # Challenge format
    ///
    /// The challenge is an opaque byte string of arbitrary length.
    /// Implementors **MUST NOT** make any assumptions about its contents,
    /// and **MUST** produce distinct outputs for distinct challenges
    /// (except with negiligible probability).
    ///
    /// This can be most easily implemented by using the challenge as part of
    /// the input of a cryptographic hash function.  The VDFs provided in this
    /// crate use this strategy.
    ///
    /// The difficulty must be checked before performing any expensive
    /// computations.
    ///
    /// Most applications will generate the challenge using a
    /// cryptographically-secure pseudorandom number generator, but implementors
    /// **MUST NOT** rely on this.  In particular, this function must be secure
    /// even if `challenge` is chosen by an adversary.  Excessive values for
    /// `difficulty` may cause excessive resource consumption, but must not
    /// create any other vulnerabilities.
    ///
    /// # Complexity
    ///
    /// The VDFs in this crate consume memory that does not depend on
    /// `difficulty`, and time linearly proportional to `difficulty`.
    /// Implementors of this trait should document the resource use.
    ///
    /// # Purity
    ///
    /// This method must have no side effects.  In particular, it must be
    /// **deterministic**: it must always return the same output for the same
    /// inputs, except with negligible probability.  Furthermore, while it may
    /// change `self` via interior mutability, such changes must not affect
    /// future calls to this method, `Self::check_difficulty`, or
    /// `Self::verify`.  They *may* affect the `Debug` output.
    fn solve(&self, challenge: &[u8], difficulty: u64) -> Result<Vec<u8>, InvalidIterations>;

    /// Check that the difficulty is valid.
    ///
    /// This must return `Ok` if and only if `difficulty` is valid.  Otherwise,
    /// it must return `Err`.
    ///
    /// # Rationale
    ///
    /// It would be more ideomatic Rust to use the type system to enforce that a
    /// difficulty has been validated before use.  However, I (Demi) have not
    /// yet figured out an object-safe way to do so.
    fn check_difficulty(&self, difficulty: u64) -> Result<(), InvalidIterations>;

    /// Verifies an alleged solution of this VDF, with challenge `challenge` and
    /// difficulty `difficulty`.  Return `Ok(())` on success, or
    /// `Err(InvalidProof)` on failure.
    ///
    /// This function *does not* return any extended error information for
    /// security reasons.  To check that the difficulty is correct, call
    /// `Self::check_difficulty`.
    ///
    /// # Uniqueness of valid solutions
    ///
    /// For any `(challenge, difficulty)` tuple, there must be at most one
    /// `alleged_solution` (as measured by `Eq`) that causes this function to
    /// return `Ok(())`.  If the difficulty is valid (as determined by
    /// `check_difficulty`), there must be exactly one such solution; otherwise,
    /// there must be none.
    ///
    /// # Purity
    ///
    /// This method must have no side effects.  In particular, it must be
    /// **deterministic**: it must always return the same output for the same
    /// inputs.  Furthermore, while it may change `self` via interior
    /// mutability, such changes must not affect future calls to this method,
    /// `Self::prove`, or `Self::check_difficulty`.  Such changes **MAY** affect
    /// debugging output.
    fn verify(
        &self,
        challenge: &[u8],
        difficulty: u64,
        alleged_solution: &[u8],
    ) -> Result<(), InvalidProof>;
}
