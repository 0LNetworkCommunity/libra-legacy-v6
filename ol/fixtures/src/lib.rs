use std::{fs, path::{Path, PathBuf}};

pub fn get_persona_mnem(persona: &str) -> String {
  let path= env!("CARGO_MANIFEST_DIR");
  let buf = Path::new(path).join("mnemonic").join(format!("{}.mnem", persona));
  fs::read_to_string(&buf).expect("could not file mnemonic file")
}

pub fn get_persona_account_json(persona: &str) -> (String, PathBuf) {
  let path= env!("CARGO_MANIFEST_DIR");
  let buf = Path::new(path).join("account").join(format!("{}.account.json", persona));
  (
    fs::read_to_string(&buf).expect("could not file mnemonic file"),
    buf
  )
}

pub fn get_persona_autopay_json(persona: &str) -> (String, PathBuf) {
  let path= env!("CARGO_MANIFEST_DIR");
  let buf = Path::new(path).join("autopay").join(format!("{}.autopay_batch.json", persona));
  (
    fs::read_to_string(&buf).expect("could not file mnemonic file"),
    buf
  )
}