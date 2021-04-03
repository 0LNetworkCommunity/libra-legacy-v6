//! web-monitor

use crate::{check, check_runner};
use futures::StreamExt;
use std::convert::Infallible;
use std::thread;
use std::time::Duration;
use tokio::time::interval;
use warp::{sse::ServerSentEvent, Filter};

// TODO: does this need to be a separate function?
// create server-sent event
fn sse_check(info: check::Items) -> Result<impl ServerSentEvent, Infallible> {
    Ok(warp::sse::json(info))
}

/// main server
#[tokio::main]
pub async fn main() {
    // TODO: Perhaps a better way to keep the check cache fresh?
    thread::spawn(|| {
        check_runner::mon(true);
    });

    //GET check/ (json api for check data)
    let check = warp::path("check").and(warp::get()).map(|| {
        // create server event source from Check object
        let event_stream = interval(Duration::from_secs(1)).map(move |_| {
            // counter += 1;
            let items = check::Items::read_cache().unwrap();

            sse_check(items)
        });
        // reply using server-sent events
        warp::sse::reply(event_stream)
    });

    //GET dash/ (json api for check data)
    let dash = warp::fs::dir("/root/libra/ol-cli/web-monitor/public/");

    //GET explorer/ (the json api for explorer)
    let _explorer = warp::path("explorer").and(warp::get()).map(|| {
        // create server event source
        let event_stream = interval(Duration::from_secs(1)).map(move |_| {
            let items = check::Items::read_cache().unwrap();

            // TODO: Use a different data source for /explorer/ data.
            sse_check(items)
        });
        // reply using server-sent events
        warp::sse::reply(event_stream)
    });

    warp::serve(dash.or(check))
        .run(([127, 0, 0, 1], 3030))
        .await;
}
