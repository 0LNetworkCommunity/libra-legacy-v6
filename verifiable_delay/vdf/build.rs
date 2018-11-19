use std::env;
use std::fs::File;
use std::io::Write;
use std::path::PathBuf;
use std::u16;
const PRIMES_LEN: usize = 6541;
const RESIDUES_LEN: usize = 5760;
const SIEVE_INFO_LEN: usize = PRIMES_LEN - 5;
fn odd_primes_below_n(n: usize) -> Vec<usize> {
    let mut sieve = Vec::with_capacity(n >> 1);
    sieve.resize(n >> 1, true);
    let mut q = (n as f64).powf(0.5) as usize;
    assert!(q * q <= n);
    q += 1;
    assert!(q * q > n);
    for i in (3..q).step_by(2) {
        if sieve[i >> 1] {
            for i in ((i * i >> 1)..sieve.len()).step_by(i) {
                sieve[i] = false;
            }
        }
    }
    // mega cheat ― we know the exact size of this vector
    let mut res = Vec::with_capacity(PRIMES_LEN);
    for i in 1..n / 2 {
        if sieve[i] {
            res.push(2 * i + 1);
        }
    }
    assert_eq!(res.len(), PRIMES_LEN);
    res
}

// Probably horribly slow.  I don’t care.
fn mod_exponentiation(q: usize, r: usize, s: usize) -> usize {
    assert!(q < u16::MAX.into());
    assert!(r < u16::MAX.into());
    assert!(s < u16::MAX.into());
    let (mut a, mut exponent, modulus) = (q as u32, r as u32, s as u32);
    let mut state = 1;
    loop {
        if exponent & 1 != 0 {
            state *= a;
            state %= modulus;
        }
        exponent >>= 1;
        if exponent == 0 {
            return state as _;
        }
        a *= a;
        a %= modulus;
    }
}

const M: usize = 8 * 3 * 5 * 7 * 11 * 13;
fn generate(f: &mut dyn Write) {
    let odd_primes_below_65535 = odd_primes_below_n(1 << 16);
    let odd_primes_above_13 = &odd_primes_below_65535[5..];
    assert_eq!(odd_primes_above_13.len(), SIEVE_INFO_LEN);
    write!(f, "const M: u32 = 8 * 3 * 5 * 7 * 11 * 13;\n\n").expect("i/o error");
    let mut residues = Vec::with_capacity(RESIDUES_LEN);
    'outer: for x in (7..M).step_by(8) {
        for y in &[3, 5, 7, 11, 13] {
            if x % y == 0 {
                continue 'outer;
            }
        }
        residues.push(x);
    }
    assert_eq!(residues.len(), RESIDUES_LEN);
    write!(
        f,
        "#[cfg_attr(feature = \"cargo-clippy\", allow(clippy::unreadable_literals))]\n\
         const RESIDUES: [u32; {}] = {:?};\n\n",
        RESIDUES_LEN,
        &residues[..]
    )
    .expect("i/o error");
    let mut sieve_info = Vec::with_capacity(SIEVE_INFO_LEN);
    for &i in odd_primes_above_13 {
        sieve_info.push((i, mod_exponentiation(M % i, i - 2, i)));
    }
    assert_eq!(sieve_info.len(), SIEVE_INFO_LEN);
    write!(
        f,
        "#[cfg_attr(feature = \"cargo-clippy\", allow(clippy::unreadable_literals))]\n\
         const SIEVE_INFO: [(u16, u16); {}] = {:?};\n\n",
        SIEVE_INFO_LEN,
        &sieve_info[..]
    )
    .expect("i/o error");
}

fn main() {
    println!("cargo:rerun-if-changed=build.rs");
    let manifest_path = env::var("OUT_DIR").expect("cargo should have set this");
    let mut path = PathBuf::from(&manifest_path);
    path.push("constants.rs");
    let mut f = File::create(path).expect("cannot create constants.rs");
    generate(&mut f);
}
