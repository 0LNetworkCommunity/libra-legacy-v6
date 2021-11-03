//! client






use crate::configs::get_tx_params;


#[tauri::command]
pub fn show_tx_params() -> String {
  let txp = get_tx_params( None);
  format!("{:?}", txp)
}
