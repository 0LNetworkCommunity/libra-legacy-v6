//! web-monitor

use crate::{node_health, check_runner, chain_info};
use futures::StreamExt;
use std::convert::Infallible;
use std::thread;
use std::time::Duration;
use tokio::time::interval;
use warp::{sse::ServerSentEvent, Filter};

// TODO: does this need to be a separate function?
// create server-sent event
fn sse_check(info: node_health::Items) -> Result<impl ServerSentEvent, Infallible> {
    Ok(warp::sse::json(info))
}

fn sse_chain_info(info: chain_info::ChainInfo) -> Result<impl ServerSentEvent, Infallible> {
    Ok(warp::sse::json(info))
}

fn sse_val_info(info: Vec<chain_info::ValidatorInfo>) -> Result<impl ServerSentEvent, Infallible> {
    Ok(warp::sse::json(info))
}


/// main server
#[tokio::main]
pub async fn start_server() {
    // TODO: Perhaps a better way to keep the check cache fresh?
    thread::spawn(|| {
        check_runner::mon(true, false);
    });

    //GET check/ (json api for check data)
    let check = warp::path("check").and(warp::get()).map(|| {
        // let mut health = node_health::NodeHealth::new();
        // create server event source from Check object
        let event_stream = interval(Duration::from_secs(1)).map(move |_| {
            let items = node_health::Items::read_cache().unwrap();
            // let items = health.refresh_checks();
            sse_check(items)
        });
        // reply using server-sent events
        warp::sse::reply(event_stream)
    });

    //GET chain/ (the json api)
    let chain = warp::path("chain").and(warp::get()).map(|| {
        // create server event source
        let event_stream = interval(Duration::from_secs(1)).map(move |_| {
            let info = crate::chain_info::read_chain_info_cache();
            sse_chain_info(info)
        });
        // reply using server-sent events
        warp::sse::reply(event_stream)
    });

    //GET validators/ (the json api)
    let validators = warp::path("validators").and(warp::get()).map(|| {
        // create server event source
        let event_stream = interval(Duration::from_secs(1)).map(move |_| {
            let info = crate::chain_info::read_val_info_cache();
            // TODO: Use a different data source for /explorer/ data.
            sse_val_info(info)
        });
        // reply using server-sent events
        warp::sse::reply(event_stream)
    });

    //GET /
    let home = warp::fs::dir("/root/libra/ol-cli/web-monitor/public/");

    warp::serve(home.or(check).or(chain).or(validators))
        .run(([0, 0, 0, 0], 3030)).await;
}
