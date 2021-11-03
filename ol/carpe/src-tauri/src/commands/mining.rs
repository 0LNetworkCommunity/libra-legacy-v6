use crate::{
  carpe_error::CarpeError,
  configs::{get_cfg, get_diem_client, get_tx_params},
};
use diem_json_rpc_types::views::TowerStateResourceView;
use ol::config::AppCfg;
use ol_types::block::VDFProof;

use tauri::Window;
use tauri::Manager;
use tower::{backlog::process_backlog, commit_proof, proof::mine_once};
use txs::submit_tx::{eval_tx_status, TxParams};
// use crate::configs::{get_cfg, get_tx_params};

/// A new listener needs to be started whenever the user changes profiles i.e. using a different signing account.
/// This is because the private key gets loaded in member when then listener is initialized.

//TODO: there's a risk of multiple tower listeners being initialized. This is handled on the JS window side, but we likely need more guarantees on the rust side. Unsure how to do this without implementing a proper queue.
#[tauri::command]
pub async fn start_tower_listener(window: Window) -> Result<(), CarpeError> {
  
  println!("starting tower builder, listening for tower-make-proof");
  // prepare listener to receive events
  // TODO: this is gross. Prevent cloning when using in closures
  let window_clone = window.clone();
  let new_clone = window_clone.clone();

  let config = get_cfg()?;
  let tx_params = get_tx_params(None).unwrap();

  let h = window.listen("tower-make-proof", move |e| {
    println!("received tower-make-proof event");
    println!("received event {:?}", e);

    match mine_and_commit_one_proof(&config, &tx_params) {
      Ok(proof) => {
        window_clone.emit("tower-event", proof).unwrap();
      }
      Err(e) => {
        window_clone.emit("tower-error", e).unwrap();
      }
    }
  });

  window.once("kill-listener", move |_| {
    println!("received kill listener event");
    new_clone.unlisten(h);
  });

  Ok(())
}


#[derive(Clone, serde::Serialize)]
struct BacklogSuccess {
  success: bool,
}

#[tauri::command]
pub async fn submit_backlog(window: Window) -> Result<(), CarpeError> {
  let config = get_cfg()?;
  let tx_params = get_tx_params(None)
    .map_err(|_e| CarpeError::tower("could getch tx_params while sending backlog."))?;

  match backlog(&config, &tx_params) {
      Ok(_) => window.emit("backlog-success", BacklogSuccess {success: true}),
      Err(_) => window.emit("backlog-error", CarpeError::tower("could not submit backlog)"))
  };
    
  Ok(())
}


/// flush a backlog of proofs at once to the chain.
pub fn backlog(
  config: &AppCfg,
  tx_params: &TxParams,
) -> Result<(), CarpeError> {
  // TODO: This does not return an error on transaction failure. Change in upstream.
  process_backlog(config, tx_params, false)
    .map_err(|e| { 
      CarpeError::tower(&format!("could not complete sending of backlog, message: {:?}", &e))
    })?;
  Ok(())
}

/// creates one proof and submits
pub fn mine_and_commit_one_proof(
  config: &AppCfg,
  tx_params: &TxParams,
) -> Result<VDFProof, CarpeError> {
  match mine_once(&config) {
    Ok(b) => match commit_proof::commit_proof_tx(&tx_params, b.clone(), false) {
      Ok(tx_view) => match eval_tx_status(&tx_view) {
        Ok(_) => Ok(b),
        Err(e) => {
          let msg = format!(
            "ERROR: Tower proof NOT committed to chain, message: \n{:?}",
            e
          );
          println!("{}", &msg);
          Err(CarpeError::tower(&msg))
        }
      },
      Err(e) => {
        let msg = format!("Tower transaction rejected, message: \n{:?}", e);
        println!("{}", &msg);
        Err(CarpeError::tower(&msg))
      }
    },
    Err(e) => {
      let msg = format!("Error mining tower proof, message: {:?}", e);
      println!("{}", &msg);
      Err(CarpeError::tower(&msg))
    }
  }
}

// TODO: Resubmit backlog

#[tauri::command]
pub fn get_onchain_tower_state() -> Result<TowerStateResourceView, CarpeError> {
  println!("fetching onchain tower state");
  let cfg = get_cfg()?;
  let client = get_diem_client(&cfg)?;

  match client.get_miner_state(&cfg.profile.account) {
    Ok(Some(t)) => {
      dbg!(&t);
      Ok(t)
    }
    _ => Err(CarpeError::tower("could not get tower state from chain")),
  }
}
