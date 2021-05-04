[![Build Status](https://travis-ci.org/fizyk20/rust-gmp.svg?branch=master)](https://travis-ci.org/fizyk20/rust-gmp)

[Documentation](https://docs.rs/rust-gmp)

The following functions are intentionally left out of the bindings:

* `gmp_randinit` (not thread-safe, obsolete)
* `mpz_random` (not thread-safe, obsolete)
* `mpz_random2` (not thread-safe, obsolete)
* `mpf_set_default_prec` (not thread-safe)
* `mpf_get_default_prec` (not thread-safe)
* `mpf_init` (not thread-safe)
* `mpf_inits` (not thread-safe, va_list wrapper)
* `mpf_clears` (va_list wrapper)
* `mpf_swap` (no better than rust's swap)
* `mpf_set_prec_raw` (could be exposed with an `unsafe` function if needed)
* `mpz_inits` (va_list wrapper)
* `mpz_clears` (va_list wrapper)
* `mpz_swap` (no better than rust's swap)
* `mpq_inits` (va_list wrapper)
* `mpq_clears` (va_list wrapper)
* `mpq_swap` (no better than rust's swap)
