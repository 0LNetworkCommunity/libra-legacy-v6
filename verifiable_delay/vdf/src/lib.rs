// Copyright 2018 Chia Network Inc and Block Notary Inc
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
// and limitations under the License.
extern crate num_traits;
extern crate gmp;
mod compute;
pub use compute::*;
pub trait VDF {
    type PublicParameters;
    type SecurityParameter;
    type TimeBound;
    type Input;
    type Output;
    type Proof;
    fn generate(security_parameter: Self::SecurityParameter, time_bound: Self::TimeBound) -> Self::PublicParameters;
    fn solve(parameters: Self::PublicParameters, input: Self::Input) -> (Self::Output, Self::Proof);
    fn verify(parameters: Self::PublicParameters, input: Self::Input, output: Self::Output, proof: Self::Proof) -> Result<(), ()>;
}
#[cfg(test)]
mod tests {
}
