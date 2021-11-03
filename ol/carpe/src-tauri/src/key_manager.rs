//! key management tools, leveraging OS keyrings.

extern crate keyring;
use anyhow::bail;
use diem_crypto::{
  ed25519::{Ed25519PrivateKey, Ed25519PublicKey},
  test_utils::KeyPair
};
use keyring::KeyringError;
use std::convert::TryInto;

#[cfg(test)]
use std::error::Error;

const KEYRING_APP_NAME: &str = "carpe";

/// send the encoded private key to OS keyring
pub fn set_private_key(ol_address: &str, key: Ed25519PrivateKey) -> Result<(), KeyringError> {
  let kr = keyring::Keyring::new(KEYRING_APP_NAME, &ol_address);

  let bytes: &[u8] = &(key.to_bytes());
  let encoded = hex::encode(bytes);

  kr.set_password(&encoded)
}

/// retrieve a private key from OS keyring
pub fn get_private_key(ol_address: &str) -> Result<Ed25519PrivateKey, anyhow::Error> {
  let kr = keyring::Keyring::new(KEYRING_APP_NAME, &ol_address);
  match kr.get_password() {
    Ok(s) => {
      let ser = hex::decode(s)?;
      match ser.as_slice().try_into() {
        Ok(k) => Ok(k),
        Err(e) => bail!(e),
      }
    }
    Err(e) => bail!(e),
  }
}

// retrieve a keypair from OS keyring
pub fn get_keypair(
  ol_address: &str,
) -> Result<KeyPair<Ed25519PrivateKey, Ed25519PublicKey>, anyhow::Error> {
  match get_private_key(&ol_address) {
    Ok(k) => {
      let p: KeyPair<Ed25519PrivateKey, Ed25519PublicKey> = match k.try_into(){
          Ok(p) => p,
          Err(e) => bail!(e),
      };
    Ok(p)
    },
    Err(e) => bail!(e),
}
  // let p: KeyPair<Ed25519PrivateKey, Ed25519PublicKey> = k.try_into().unwrap(); // TODO: just return here.
  // Ok(p)
}

#[test]
fn encode_keys() {
  let alice_mnem = "talent sunset lizard pill fame nuclear spy noodle basket okay critic grow sleep legend hurry pitch blanket clerk impose rough degree sock insane purse";
  use ol_keys::scheme::KeyScheme;
  let scheme = KeyScheme::new_from_mnemonic(alice_mnem.to_owned());
  let private = scheme.child_0_owner.get_private_key();
  let bytes: &[u8] = &(private.to_bytes());

  let encoded = hex::encode(bytes);

  let new_bytes = hex::decode(encoded).unwrap();
  let back: Ed25519PrivateKey = new_bytes.as_slice().try_into().unwrap();

  assert_eq!(&back, &private);
}

#[test]
#[ignore] // TODO: this needs to be hand tested since it requires OS password input.
fn test_set() -> Result<(), Box<dyn Error>> {
  use ol_keys::scheme::KeyScheme;
  let ol_address = "0x0";

  let alice_mnem = "talent sunset lizard pill fame nuclear spy noodle basket okay critic grow sleep legend hurry pitch blanket clerk impose rough degree sock insane purse";

  let scheme = KeyScheme::new_from_mnemonic(alice_mnem.to_owned());
  let private = scheme.child_0_owner.get_private_key();

  // let password = "topS3cr3tP4$$w0rd";
  set_private_key(ol_address, private).unwrap();

  Ok(())
}

#[test]
#[ignore] // TODO: this needs to be hand tested since it requires OS password input.

fn test_get() -> Result<(), Box<dyn Error>> {
  use ol_keys::scheme::KeyScheme;
  let ol_address = "0x123";

  let alice_mnem = "talent sunset lizard pill fame nuclear spy noodle basket okay critic grow sleep legend hurry pitch blanket clerk impose rough degree sock insane purse";

  let scheme = KeyScheme::new_from_mnemonic(alice_mnem.to_owned());
  let private = scheme.child_0_owner.get_private_key();

  set_private_key(ol_address, private.clone()).unwrap();

  let read = get_private_key(ol_address).unwrap();
  assert_eq!(&read, &private);

  Ok(())
}
