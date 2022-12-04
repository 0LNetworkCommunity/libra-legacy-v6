# Verifiable Delay Function (VDF) Implementation in Rust

## What is a VDF?

A Verifiable Delay Function (VDF) is a function that requires substantial time
to evaluate (even with a polynomial number of parallel processors) but can be
very quickly verified as correct. VDFs can be used to construct randomness
beacons with multiple applications in a distributed network environment. By
introducing a time delay during evaluation, VDFs prevent malicious actors from
influencing output. The output cannot be differentiated from a random number
until the final result is computed.  See <https://eprint.iacr.org/2018/712.pdf>
for more details.

## Description

This VDF implementation is written in Rust.  The GMP library is used for
arithmetic and greatest common divisor (GCD) calculations.  We use class groups
to implement the approaches described in the following papers:

1. [Simple Verifiable Delay Functions](https://eprint.iacr.org/2018/627.pdf). Pietrzak, 2018
2. [Efficient Verifiable Delay Functions](https://eprint.iacr.org/2018/623.pdf). Wesolowski, 2018

The chosen generator is (2, 1, c), where c is calculated from the provided
discriminant.  A form is represented internally (a, b, c), with the
discriminant not being used in most omputations.  This implementation performs
reduction is performed after every multiplication and squaring, as not doing so
did not give any gains in our benchmarks.


This repo includes three crates:

* `classgroup`: a class group implementation, as well as a trait for class
    groups.
* `vdf`: a Verifyable Delay Function (VDF) trait, as well as an
    implementation of that trait.
* `vdf-cli`: a command-line interface to the vdf crate. It also includes
    additional commands, which are deprecated and will be replaced by a CLI to
    the classgroup crate.

## Usage

- Install [Rust].  We (POA Networks) have tested the code with the latest
    stable, beta, and nightly versions of Rust.  It may work with older
    versions, but this is not guaranteed.
- Install the [GNU Multiple Precision Library](https://gmplib.org/)
    * On Debian and derivatives (including Ubuntu):
        ```sh
        $ sudo apt-get install -y libgmp-dev
        ```
    * On Red Hat and derivatives (Fedora, CentOS)
        ```sh
        $ sudo dnf -y install gmp-devel
        ```
- Download and prepare the repository

    ```sh
    $ git clone https://github.com/poanetwork/vdf.git
    $ cargo install --path=vdf-cli
    $ # or for the competition binary
    $ cargo install --path=vdf-competition
    ```

### Command Line Interface

To initiate, use the `vdf-cli` command followed by 2 arguments:

- _challenge_: byte string of arbitrary length
- _difficulty_: number of iterations, each iteration requires more time to evaluate

This generates the Weslowski proof of time.  To generate the Pietrzak proof of
time, pass `-tpietrzak`.  For detailed usage information, run `vdf-cli --help`.

Once complete you will see the output, returned as a `Vec<u8>`.  The CLI tool
hex-encodes its output.

**Example**

```sh
$ vdf-cli aa 100
005271e8f9ab2eb8a2906e851dfcb5542e4173f016b85e29d481a108dc82ed3b3f97937b7aa824801138d1771dea8dae2f6397e76a80613afda30f2c30a34b040baaafe76d5707d68689193e5d211833b372a6a4591abb88e2e7f2f5a5ec818b5707b86b8b2c495ca1581c179168509e3593f9a16879620a4dc4e907df452e8dd0ffc4f199825f54ec70472cc061f22eb54c48d6aa5af3ea375a392ac77294e2d955dde1d102ae2ace494293492d31cff21944a8bcb4608993065c9a00292e8d3f4604e7465b4eeefb494f5bea102db343bb61c5a15c7bdf288206885c130fa1f2d86bf5e4634fdc4216bc16ef7dac970b0ee46d69416f9a9acee651d158ac64915b
```

To verify, use the `vdi-cli` command with the same arguments and include the
output.

**Example**

```sh
$ vdf-cli aa 100 005271e8f9ab2eb8a2906e851dfcb5542e4173f016b85e29d481a108dc82ed3b3f97937b7aa824801138d1771dea8dae2f6397e76a80613afda30f2c30a34b040baaafe76d5707d68689193e5d211833b372a6a4591abb88e2e7f2f5a5ec818b5707b86b8b2c495ca1581c179168509e3593f9a16879620a4dc4e907df452e8dd0ffc4f199825f54ec70472cc061f22eb54c48d6aa5af3ea375a392ac77294e2d955dde1d102ae2ace494293492d31cff21944a8bcb4608993065c9a00292e8d3f4604e7465b4eeefb494f5bea102db343bb61c5a15c7bdf288206885c130fa1f2d86bf5e4634fdc4216bc16ef7dac970b0ee46d69416f9a9acee651d158ac64915b
Proof is valid
```
### VDF Library

<!--
Keep as is, and possibly include argument explanations as well (for byte_length for example). May not be needed though is CLI is main user interaction tool.
-->

```rust
extern crate vdf;
use vdf::{InvalidProof, PietrzakVDFParams, VDFParams, WesolowskiVDFParams, VDF};

/// The correct solution.
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
fn main() {
    // The length of the prime numbers generated, in bits.
    let num_bits: u16 = 2048;

    // An instance of the VDF.  Instances can be used arbitrarily many times.
    let pietrzak_vdf = PietrzakVDFParams(num_bits).new();

    // Solve for the correct answer.  This will take a minute or two.
    assert_eq!(
        &pietrzak_vdf.solve(b"\xaa", 10000).unwrap()[..],
        CORRECT_SOLUTION
    );

    // Verify the answer.  This should be far faster (less than a second).
    assert!(pietrzak_vdf.verify(b"\xaa", 10000, CORRECT_SOLUTION).is_ok());
}
```

## Benchmarks

Benchmarks are provided for the classgroup operations. To run benchmarks:

```sh
$ ./bench.sh <your challenge here>
```

Additional benchmarks are under development.

### Current Benchmarks

These were generated by `./bench.sh aadf`.  Outliers could be due to preemption
by the OS and/or hypervisor.  Changes are relative to the previous test run
done on the same machine.  Since the previous run was done with different
settings and/or code than reported here, these changes are not meaningful.

```text
Benchmarking square with seed aadf: 512: Collecting 100 samples in estimated 5.0439 s (374k iteratio                                                                                                    square with seed aadf: 512
                        time:   [13.301 us 13.333 us 13.372 us]
                        change: [-22.286% -21.745% -21.225%] (p = 0.00 < 0.05)
                        Performance has improved.
Found 22 outliers among 100 measurements (22.00%)
  5 (5.00%) high mild
  17 (17.00%) high severe

Benchmarking multiply with seed aadf: 512: Collecting 100 samples in estimated 5.0452 s (293k iterat                                                                                                    multiply with seed aadf: 512
                        time:   [17.219 us 17.251 us 17.287 us]
                        change: [-24.323% -23.739% -23.149%] (p = 0.00 < 0.05)
                        Performance has improved.
Found 10 outliers among 100 measurements (10.00%)
  4 (4.00%) high mild
  6 (6.00%) high severe

Benchmarking square with seed aadf: 1024: Collecting 100 samples in estimated 5.0822 s (177k iterati                                                                                                    square with seed aadf: 1024
                        time:   [28.672 us 28.716 us 28.767 us]
                        change: [-29.947% -29.339% -28.708%] (p = 0.00 < 0.05)
                        Performance has improved.
Found 8 outliers among 100 measurements (8.00%)
  1 (1.00%) low mild
  1 (1.00%) high mild
  6 (6.00%) high severe

Benchmarking multiply with seed aadf: 1024: Collecting 100 samples in estimated 5.0886 s (136k itera                                                                                                    multiply with seed aadf: 1024
                        time:   [37.163 us 37.207 us 37.254 us]
                        change: [-21.403% -20.750% -20.170%] (p = 0.00 < 0.05)
                        Performance has improved.
Found 8 outliers among 100 measurements (8.00%)
  1 (1.00%) low mild
  1 (1.00%) high mild
  6 (6.00%) high severe

Benchmarking square with seed aadf: 2048: Collecting 100 samples in estimated 5.2519 s (76k iteratio                                                                                                    square with seed aadf: 2048
                        time:   [69.115 us 69.254 us 69.430 us]
                        change: [-28.091% -27.738% -27.341%] (p = 0.00 < 0.05)
                        Performance has improved.
Found 8 outliers among 100 measurements (8.00%)
  1 (1.00%) low mild
  1 (1.00%) high mild
  6 (6.00%) high severe

Benchmarking multiply with seed aadf: 2048: Collecting 100 samples in estimated 5.0554 s (56k iterat                                                                                                    multiply with seed aadf: 2048
                        time:   [90.922 us 91.057 us 91.201 us]
                        change: [-25.236% -24.794% -24.336%] (p = 0.00 < 0.05)
                        Performance has improved.
Found 13 outliers among 100 measurements (13.00%)
  2 (2.00%) low mild
  5 (5.00%) high mild
  6 (6.00%) high severe
```

[Rust]: <https://doc.rust-lang.org/cargo/getting-started/installation.html>


## License

Copyright 2018 Chia Network Inc and POA Networks Ltd.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
