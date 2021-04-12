use std::{fs, {path::Path}};

pub fn get_persona_mnem(persona: &str) -> String {
  let path= env!("CARGO_MANIFEST_DIR");
  let buf = Path::new(path).join("mnemonic").join(format!("{}.mnem", persona));
  fs::read_to_string(&buf).expect("could not file mnemonic file")
}