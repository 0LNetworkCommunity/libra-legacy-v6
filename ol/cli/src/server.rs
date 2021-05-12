//! `server`  web monitor http server
use futures::StreamExt;
use serde_json::json;
use std::{convert::Infallible, fs, path::PathBuf, process::Command, thread, time::Duration};
use tokio::time::interval;
use warp::{sse::ServerSentEvent, Filter};
use ol_types::config::IS_PROD;

use crate::{cache::Vitals, check::runner, node::node::Node};


#[tokio::main]
/// starts the web server
pub async fn start_server(mut node: Node, run_checks: bool) {
    let cfg = &node.conf;

    let node_home = cfg.clone().workspace.node_home.clone();
    //GET check/ (json api for check data)
    let vitals_route = warp::path("vitals").and(warp::get()).map(move || {
        let path = node_home.clone();
        // create server event source from Check object
        let event_stream = interval(Duration::from_secs(10)).map(move |_| {
            let vitals = Vitals::read_json(&path);
            // let items = health.refresh_checks();
            sse_vitals(vitals)
        });
        // reply using server-sent events
        warp::sse::reply(event_stream)
    });

    let account_template = warp::path("account.json").and(warp::get().map(|| {
        fs::read_to_string("/root/.0L/account.json").unwrap()
        // let obj: Value = serde_json::from_str(&string);
    }));

    let node_home = cfg.clone().workspace.node_home.clone();
    let epoch_route = warp::path("epoch.json").and(warp::get().map(move || {
        // let node_home = node_home_two.clone();
        let vitals = Vitals::read_json(&node_home).chain_view.unwrap();
        let json = json!({
          "epoch": vitals.epoch,
          "waypoint": vitals.waypoint.unwrap().to_string()
        });
        json.to_string()
    }));


    let node_home = cfg.clone().workspace.node_home.clone();
    let web_files = if *IS_PROD {
      node_home.join("web-monitor/public/")
        // for using `npm run dev`
    } else {
      PathBuf::from("/root/libra/ol/cli/web-monitor/public/")
    };

    //GET /
    let landing = warp::fs::dir(web_files);

    if run_checks {
      thread::spawn(move || {
          runner::run_checks(&mut node, false, true, false);
      });
    }

    warp::serve(landing.or(account_template).or(vitals_route).or(epoch_route))
        .run(([0, 0, 0, 0], 3030))
        .await;
}


fn sse_vitals(data: Vitals) -> Result<impl ServerSentEvent, Infallible> {
    Ok(warp::sse::json(data))
}

/// Fetch updated static web files from release, for web-monitor.
pub fn update_web(home_path: &PathBuf) {
  let file_name = "web-monitor.zip";
  let url = &format!("https://github.com/OLSF/libra/releases/latest/download/{}", file_name);
  println!("Fetching web files from, {}", url);
  let zip_path = home_path.join(file_name).to_str().unwrap().to_owned();

    match Command::new("curl")
    .arg("-L")      
    .arg("--progress-bar")
    .arg(format!("-o {:?}", &zip_path))  
    .arg(url)
    .spawn() {
      Ok(_) => {
        Command::new("unzip")
            .arg(&zip_path)
            .spawn()
            .expect("failed to unzip web files");
      },
      _ => {}
    }
}