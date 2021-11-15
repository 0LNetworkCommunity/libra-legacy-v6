#[allow(non_snake_case)]

use std::path::Path;

fn main() {
  let PROJECT_DIR = std::env::var("CARGO_MANIFEST_DIR").unwrap();
  let GMP_LIB_DIR = Path::new(&PROJECT_DIR).join("gmp");
  println!("cargo:rustc-link-search={}", GMP_LIB_DIR.to_str().unwrap());
}