//! server

#![deny(warnings)]
use std::{fs, sync::Arc};
use handlebars::Handlebars;
use serde::Serialize;
use serde_json::json;
use futures::StreamExt;
use std::convert::Infallible;
use std::time::Duration;
use tokio::time::interval;  
use warp::{sse::ServerSentEvent, Filter};
use crate::check;

struct WithTemplate<T: Serialize> {
    name: &'static str,
    value: T,
}

// create server-sent event
fn sse_counter(info: check::Items) -> Result<impl ServerSentEvent, Infallible> {
    // Ok(warp::sse::data(format!("{:#?}", serde_json::to_string(&info))));
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

/// main server
#[tokio::main]
pub async fn main() {
    let template = fs::read_to_string("/root/libra/ol-cli/web/index.html").expect("cannot find index.html");

    let mut hb = Handlebars::new();
    // register the template
    hb.register_template_string("template.html", template)
        .unwrap();

    // Turn Handlebars instance into a Filter so we can combine it
    // easily with others...
    let hb = Arc::new(hb);

    // Create a reusable closure to render template
    let handlebars = move |with_template| render(with_template, hb.clone());


    //GET /
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
    
    //GET ticks/
    let ticks = warp::path("check").and(warp::get()).map(|| {

        // let mut counter: u64 = 0;
        // create server event source
        let event_stream = interval(Duration::from_secs(1)).map(move |_| {
            // counter += 1;
            let items = check::Items::read_cache().unwrap();

            sse_counter(items)
        });
        // reply using server-sent events
        warp::sse::reply(event_stream)
    });
    // TODO: Server runs monitor in background.
    // monitor::mon();
    warp::serve(route.or(ticks)).run(([127, 0, 0, 1], 3030)).await;


}