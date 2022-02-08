#[allow(non_snake_case)]

use std::path::Path;

fn main() {
  let gmp_os_dir: &str = match std::env::consts::OS {
    "linux" => "gmp-ubuntu",
    _ => "gmp"
  };

  let project_dir = std::env::var("CARGO_MANIFEST_DIR").unwrap();
  let gmp_lib_dir = Path::new(&project_dir).join(gmp_os_dir);
  println!("cargo:rustc-link-search={}", gmp_lib_dir.to_str().unwrap());
}