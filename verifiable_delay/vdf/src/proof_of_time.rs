#![allow(dead_code)]
use gmp_classgroup::{export_obj, import_obj, Mpz};
use num_traits::Zero;
use sha2::{digest::FixedOutput, Digest, Sha256};

fn generate_r_value(x: &Mpz, y: &Mpz, sqrt_mu: &Mpz, int_size_bits: usize) -> Result<Mpz, ()> {
    let zero = &Zero::zero();
    assert!(x >= zero);
    assert!(y >= zero);
    let mut v = vec![];
    let mut hasher = Sha256::new();
    for i in &[&x, &y, &sqrt_mu] {
        export_obj(i, int_size_bits, &mut v)?;
        hasher.input(&v);
        unsafe { v.set_len(0) }
    }
    let res = hasher.fixed_result();
    Ok(import_obj(&res[..16]))
}
