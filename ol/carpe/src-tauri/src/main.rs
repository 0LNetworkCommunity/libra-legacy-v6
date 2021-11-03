#![cfg_attr(
	all(not(debug_assertions), target_os = "windows"),
	windows_subsystem = "windows"
)]

pub mod commands;
pub mod key_manager;
pub mod configs;
pub mod carpe_error;
pub mod seed_peers;
use std::env;

// use tauri::Manager;

use crate::{commands::*};

fn main() {
  env::set_var("NODE_ENV", "test");

	tauri::Builder::default()
  // .setup(|app| {
  //   let config = get_cfg();
  //   let tx_params = get_tx_params(None).unwrap();
  //   let w = app.get_window("main").unwrap();
  //   app.listen_global("tower-make-proof", move |e| {
  //     println!("received tower-make-proof event");
  //     println!("received event {:?}", e);
  //       match mine_and_commit_one_proof(&config, &tx_params) {
  //         Ok(proof) => {
  //           w.emit("tower-event", proof).unwrap();
  //         }
  //         Err(e) => {
  //           w.emit("tower-error", e).unwrap();
  //         }
  //       }
  //   });
    // Ok(())
  // })
	.invoke_handler(tauri::generate_handler![
    // Accounts
		get_all_accounts,
		add_account,
		keygen,
    init_from_mnem,
    remove_accounts,
    switch_profile,
    // Networks
    update_upstream,
    get_networks,
    refresh_waypoint,
    toggle_network,
    // Queries
    query_balance,
    // Transactions
    demo_tx,
    create_user_account,
    wallet_type,
    //Tower
    start_tower_listener,
    submit_backlog,
 
    // Debug
    init_swarm,
    swarm_miner,
    swarm_files,
    swarm_process,
    easy_swarm,
    debug_error,
    debug_emit_event,
    delay_async,
    get_onchain_tower_state,
    receive_event,
    mock_build_tower,
    start_forever_task,
    debug_start_listener,
	])
	.run(tauri::generate_context!())
	.expect("error while running tauri application");
}
