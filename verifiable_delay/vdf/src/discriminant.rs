/// Copyright 2018 Chia Network Inc and Block Notary Inc
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
///   http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// and limitations under the License.

use openssl::bn::BigNum;
use std::i32;
/// Generate a discriminant (a prime equal to 7 mod 8)
pub fn create_discriminant(len: u32) -> BigNum {
    assert!(len <= i32::MAX as _);
    let eight = BigNum::from_u32(8).unwrap();
    let seven = BigNum::from_u32(7).unwrap();
    let mut bn = BigNum::new().unwrap();
    bn.generate_prime(len as _, true, Some(&eight), Some(&seven)).unwrap();
    bn
}