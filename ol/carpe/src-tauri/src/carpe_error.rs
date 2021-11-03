//! Carpe error type for client


#[derive(serde::Deserialize, serde::Serialize, Debug, Clone)]
pub enum ErrorCat {
  Client,
  Tx,
  Configs,
  Misc,
  Tower,
}

#[derive(serde::Deserialize, serde::Serialize, Debug, Clone)]
pub struct CarpeError {
  category: ErrorCat,
  uid: u8,
  msg: String,
}

impl From<anyhow::Error> for CarpeError {
    fn from(e: anyhow::Error) -> Self {
        CarpeError::misc(&format!("misc error, message: {:?}", e.to_string()))
    }
}

const E_MISC: u8 = 100;
const E_TOWER: u8 = 120;


impl CarpeError {
  pub fn new(category: ErrorCat, uid: u8, msg: String ) -> Self {
    CarpeError {
      category,
      uid,
      msg,
    }
  }
  pub fn tower(msg: &str) -> Self {
    CarpeError {
      category: ErrorCat::Tower,
      uid: E_TOWER,
      msg: msg.to_owned(),
    }
  }

  pub fn misc(msg: &str) -> Self {
    CarpeError {
      category: ErrorCat::Misc,
      uid: E_MISC,
      msg: msg.to_owned(),
    }
  }
}
