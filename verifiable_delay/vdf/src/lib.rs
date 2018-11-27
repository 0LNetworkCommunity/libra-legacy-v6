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
extern crate gmp;
extern crate libc;
extern crate num_traits;
extern crate sha2;
mod create_discriminant;
mod gmp_classgroup;

pub use self::gmp_classgroup::{
    do_compute,
    ffi::{export_obj, import_obj},
    GmpClassGroup,
};

const INCORRECT_BUFFER_SIZE: &str = "incorrect buffer size calculation (this is a bug)";

pub mod classgroup;
mod proof_of_time;
mod proof_wesolowski;
pub use self::create_discriminant::create_discriminant;
pub use self::proof_of_time::{
    check_proof_of_time_pietrzak, check_proof_of_time_wesolowski, create_proof_of_time_pietrzak,
    create_proof_of_time_wesolowski,
};
mod proof_pietrzak;
pub use self::classgroup::ClassGroup;
pub use proof_pietrzak::{InvalidIterations, Iterations, ParseIterationsError};
pub trait VDF {
    type PublicParameters;
    type SecurityParameter;
    type TimeBound;
    type Input;
    type Output;
    type Proof;
    fn generate(
        security_parameter: Self::SecurityParameter,
        time_bound: Self::TimeBound,
    ) -> Self::PublicParameters;
    fn solve(parameters: Self::PublicParameters, input: Self::Input)
        -> (Self::Output, Self::Proof);
    fn verify(
        parameters: Self::PublicParameters,
        input: Self::Input,
        output: Self::Output,
        proof: Self::Proof,
    ) -> Result<(), ()>;
}
