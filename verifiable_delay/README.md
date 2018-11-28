# Rust implementations of class groups and verifyable delay functions

This repo includes three crates

* `classgroup, which includes a class group implementation, as well as a
  trait for class groups.
* `vdf`, which includes a Verifyable Delay Function (VDF) trait, as well as
  an implementation of that trait.
* `vdf-cli`, which includes a command-line interface to the `vdf` crate.  It
  also includes additional commands, which are deprecated and will later be
  replaced by a CLI to the `classgroup` crate.

## Usage

First, install Rust, Cargo, and the GNU Multiprecision Library (GMP).  Then,
follow one of the below steps.

### To use the command line interface

```sh
$ git clone https://github.com/poanetwork/vdf
$ cd vdf
$ cargo install
$ vdf-cli prove aa 100
005271e8f9ab2eb8a2906e851dfcb5542e4173f016b85e29d481a108dc82ed3b3f97937b7aa824801138d1771dea8dae2f6397e76a80613afda30f2c30a34b040baaafe76d5707d68689193e5d211833b372a6a4591abb88e2e7f2f5a5ec818b5707b86b8b2c495ca1581c179168509e3593f9a16879620a4dc4e907df452e8dd0ffc4f199825f54ec70472cc061f22eb54c48d6aa5af3ea375a392ac77294e2d955dde1d102ae2ace494293492d31cff21944a8bcb4608993065c9a00292e8d3f4604e7465b4eeefb494f5bea102db343bb61c5a15c7bdf288206885c130fa1f2d86bf5e4634fdc4216bc16ef7dac970b0ee46d69416f9a9acee651d158ac64915b
$ vdf-cli verify aa 100 005271e8f9ab2eb8a2906e851dfcb5542e4173f016b85e29d481a108dc82ed3b3f97937b7aa824801138d1771dea8dae2f6397e76a80613afda30f2c30a34b040baaafe76d5707d68689193e5d211833b372a6a4591abb88e2e7f2f5a5ec818b5707b86b8b2c495ca1581c179168509e3593f9a16879620a4dc4e907df452e8dd0ffc4f199825f54ec70472cc061f22eb54c48d6aa5af3ea375a392ac77294e2d955dde1d102ae2ace494293492d31cff21944a8bcb4608993065c9a00292e8d3f4604e7465b4eeefb494f5bea102db343bb61c5a15c7bdf288206885c130fa1f2d86bf5e4634fdc4216bc16ef7dac970b0ee46d69416f9a9acee651d158ac64915b
Proof is valid
```
### To use the VDF library

```rust
extern crate vdf;
use vdf::{InvalidProof, PietrzakVDFParams, VDFParams, WesolowskiVDFParams, VDF};

fn main() {
    const CORRECT_SOLUTION: &[u8] =
        b"\x00\x52\x71\xe8\xf9\xab\x2e\xb8\xa2\x90\x6e\x85\x1d\xfc\xb5\x54\x2e\x41\x73\xf0\x16\
        \xb8\x5e\x29\xd4\x81\xa1\x08\xdc\x82\xed\x3b\x3f\x97\x93\x7b\x7a\xa8\x24\x80\x11\x38\
        \xd1\x77\x1d\xea\x8d\xae\x2f\x63\x97\xe7\x6a\x80\x61\x3a\xfd\xa3\x0f\x2c\x30\xa3\x4b\
        \x04\x0b\xaa\xaf\xe7\x6d\x57\x07\xd6\x86\x89\x19\x3e\x5d\x21\x18\x33\xb3\x72\xa6\xa4\
        \x59\x1a\xbb\x88\xe2\xe7\xf2\xf5\xa5\xec\x81\x8b\x57\x07\xb8\x6b\x8b\x2c\x49\x5c\xa1\
        \x58\x1c\x17\x91\x68\x50\x9e\x35\x93\xf9\xa1\x68\x79\x62\x0a\x4d\xc4\xe9\x07\xdf\x45\
        \x2e\x8d\xd0\xff\xc4\xf1\x99\x82\x5f\x54\xec\x70\x47\x2c\xc0\x61\xf2\x2e\xb5\x4c\x48\
        \xd6\xaa\x5a\xf3\xea\x37\x5a\x39\x2a\xc7\x72\x94\xe2\xd9\x55\xdd\xe1\xd1\x02\xae\x2a\
        \xce\x49\x42\x93\x49\x2d\x31\xcf\xf2\x19\x44\xa8\xbc\xb4\x60\x89\x93\x06\x5c\x9a\x00\
        \x29\x2e\x8d\x3f\x46\x04\xe7\x46\x5b\x4e\xee\xfb\x49\x4f\x5b\xea\x10\x2d\xb3\x43\xbb\
        \x61\xc5\xa1\x5c\x7b\xdf\x28\x82\x06\x88\x5c\x13\x0f\xa1\xf2\xd8\x6b\xf5\xe4\x63\x4f\
        \xdc\x42\x16\xbc\x16\xef\x7d\xac\x97\x0b\x0e\xe4\x6d\x69\x41\x6f\x9a\x9a\xce\xe6\x51\
        \xd1\x58\xac\x64\x91\x5b";
    let pietrzak_vdf = PietrzakVDFParams(2048).new();
    assert_eq!(
        &pietrzak_vdf.solve(b"\xaa", 100).unwrap()[..],
        CORRECT_SOLUTION
    );
    assert!(pietrzak_vdf.verify(b"\xaa", 100, CORRECT_SOLUTION).is_ok());
}
```
