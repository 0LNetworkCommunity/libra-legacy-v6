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


// fn sse_check(info: Items) -> Result<impl ServerSentEvent, Infallible> {
//     Ok(warp::sse::json(info))
// }

// fn sse_chain_info(info: ChainView) -> Result<impl ServerSentEvent, Infallible> {
//     Ok(warp::sse::json(info))
// }

// fn sse_val_info(info: Vec<ValidatorView>) -> Result<impl ServerSentEvent, Infallible> {
//     Ok(warp::sse::json(info))
// }

// fn sse_account_info(info: OwnerAccountView) -> Result<impl ServerSentEvent, Infallible> {
//     Ok(warp::sse::json(info))
// }

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

    // //GET check/ (json api for check data)
    // let check = warp::path("check").and(warp::get()).map(|| {
    //     // let mut health = node_health::NodeHealth::new();
    //     // create server event source from Check object
    //     let event_stream = interval(Duration::from_secs(10)).map(move |_| {
    //         let items = node.vitals.items;
    //         // let items = health.refresh_checks();
    //         sse_check(items)
    //     });
    //     // reply using server-sent events
    //     warp::sse::reply(event_stream)
    // });

    // //GET chain/ (the json api)
    // let chain_live = warp::path("chain_live").and(warp::get()).map(|| {
    //     // create server event source
    //     let event_stream = interval(Duration::from_secs(10)).map(move |_| {
    //         let info = node.vitals.chain_view.unwrap();
    //         sse_chain_info(info)
    //     });
    //     // reply using server-sent events
    //     warp::sse::reply(event_stream)
    // });

    // // let configs = warp::path("static")
    // // .and(warp::fs::file("/root/.0L/genesis_waypoint"));
    // let vals = warp::path("vals")
    // .and(warp::get()
    // .map(|| { 
    //   let vals = node.vitals.;
    //   warp::reply::json(&vals)
    //  }));

    // let chain = warp::path("chain")
    // .and(warp::get()
    // .map(|| { 
    //   let chain = read_chain_info_cache();
    //   warp::reply::json(&chain)
    //  }));

    let account_template = warp::path("account.json")
    .and(warp::get()
    .map(|| { 
      fs::read_to_string("/root/.0L/account.json").unwrap()
      // let obj: Value = serde_json::from_str(&string);
      
     }));

    // let epoch = warp::path("epoch.json")
    // .and(warp::get()
    // .map(|| { 
    //   let ci = read_chain_info_cache();
    //   let json = json!({
    //     "epoch": ci.epoch,
    //     "waypoint": ci.waypoint.unwrap().to_string()
    //   });
    //   json.to_string()
    // }));


    //GET account/ (the json api)
    // let account = warp::path("account").and(warp::get()).map(|| {
    //     // create server event source
    //     let event_stream = interval(Duration::from_secs(60)).map(move |_| {
    //         let info = node.vitals.account_view;
    //         sse_account_info(info)
    //     });
    //     // reply using server-sent events
    //     warp::sse::reply(event_stream)
    // });


    //GET validators/ (the json api)
    // let vals_live = warp::path("validators").and(warp::get()).map(|| {
    //     // create server event source
    //     let event_stream = interval(Duration::from_secs(60)).map(move |_| {
    //         let info = read_val_info_cache();
    //         // TODO: Use a different data source for /explorer/ data.
    //         sse_val_info(info)
    //     });
    //     // reply using server-sent events
    //     warp::sse::reply(event_stream)
    // });

    let dev_web_files = "/root/libra/ol-cli/web-monitor/public/";
    //GET /
    let home = warp::fs::dir(dev_web_files);

    warp::serve(home.or(account_template).or(vitals_route))
        .run(([0, 0, 0, 0], 3030)).await;
}