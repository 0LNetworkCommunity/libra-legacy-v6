use futures::StreamExt;
use std::convert::Infallible;
use std::thread;
use std::time::Duration;
use std::fs;
use std::path::PathBuf;
use tokio::{time::interval};
use warp::{sse::ServerSentEvent, Filter};

use crate::{cache::Vitals, check::runner, node::node::Node};

fn sse_vitals(data: Vitals) -> Result<impl ServerSentEvent, Infallible> {
    Ok(warp::sse::json(data))
}

#[tokio::main]
/// starts the web server
pub async fn start_server(node: Node) {
    let node_home: PathBuf = node.conf.workspace.node_home.clone();
    // TODO: Perhaps a better way to keep the check cache fresh?
    thread::spawn(|| { 
        runner::run_checks(node, true, false);
    });

    //GET check/ (json api for check data)
    let vitals_route = warp::path("vitals").and(warp::get()).map(move || {
      let path = node_home.clone(); 
        // let mut health = node_health::NodeHealth::new();
        // create server event source from Check object
        let event_stream = interval(Duration::from_secs(10)).map(move |_| {
           
          let vitals = Vitals::read_json(&path);
            // let items = health.refresh_checks();
            sse_vitals(vitals)
        });
        // reply using server-sent events
        warp::sse::reply(event_stream)
    });

    let account_template = warp::path("account.json")
    .and(warp::get()
    .map(|| { 
      fs::read_to_string("/root/.0L/account.json").unwrap()
      // let obj: Value = serde_json::from_str(&string);
      
     }));

    // let epoch = warp::path("epoch.json")
    // .and(warp::get()
    // .map(|| { 
    //   let vitals = Vitals::read_json(&path);
    //   let json = json!({
    //     "epoch": vitals.chain_view.epoch,
    //     "waypoint": vitals.chain_view.waypoint.unwrap().to_string()
    //   });
    //   json.to_string()
    // }));

    let dev_web_files = "/root/libra/ol-cli/web-monitor/public/";
    
    //GET /
    let home = warp::fs::dir(dev_web_files);

    warp::serve(home.or(account_template).or(vitals_route))
        .run(([0, 0, 0, 0], 3030)).await;
}