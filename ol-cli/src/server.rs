//! server

use std::sync::Arc;
use handlebars::Handlebars;
use serde::Serialize;
use serde_json::json;
use futures::StreamExt;
use std::convert::Infallible;
use std::time::Duration;
use tokio::time::interval;  
use warp::{sse::ServerSentEvent, Filter};
use crate::{check, check_runner};
use std::thread;


struct WithTemplate<T: Serialize> {
    name: &'static str,
    value: T,
}

// TODO: does this need to be a separate function?
// create server-sent event
fn sse_check(info: check::Items) -> Result<impl ServerSentEvent, Infallible> {
    Ok(warp::sse::json(info))
}

fn render<T>(template: WithTemplate<T>, hbs: Arc<Handlebars<'_>>) -> impl warp::Reply
where
    T: Serialize,
{
    let render = hbs
        .render(template.name, &template.value)
        .unwrap_or_else(|err| err.to_string());
    warp::reply::html(render)
}

/// Web Template
pub const TEMPLATE: &'static str = std::include_str!("../web/index.html");

/// main server
#[tokio::main]
pub async fn main() {

    // TODO: Perhaps a better way to keep the check cache fresh?
    thread::spawn(|| {
        check_runner::mon(true);
    });

    let mut hb = Handlebars::new();
    // register the template
    hb.register_template_string("template.html", TEMPLATE)
        .unwrap();

    // Turn Handlebars instance into a Filter so we can combine it
    // easily with others...
    let hb = Arc::new(hb);

    // Create a reusable closure to render template
    let handlebars = move |with_template| render(with_template, hb.clone());

    //GET / (index html)
    let route = warp::get()
        .and(warp::path::end())
        .map(|| {
            let items = check::Items::read_cache().unwrap_or_default();
            WithTemplate {
                name: "template.html",
                value: json!({"is_synced" : items.is_synced }),
            }
        })
        .map(handlebars);
    
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

    warp::serve(route.or(check)).run(([127, 0, 0, 1], 3030)).await;
}