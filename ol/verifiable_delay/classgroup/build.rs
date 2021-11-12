#[allow(non_snake_case)]

fn main() {
  let PROJECT_DIR = std::env::var("CARGO_MANIFEST_DIR").unwrap();
  let GMP_LIB_DIR = PROJECT_DIR + "\\gmp\\";
  println!("cargo:rustc-link-search={}", GMP_LIB_DIR);
}