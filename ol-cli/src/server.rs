//! server

#![deny(warnings)]
use std::sync::Arc;

use handlebars::Handlebars;
use serde::Serialize;
use serde_json::json;
use warp::Filter;
use crate::{check, monitor};
struct WithTemplate<T: Serialize> {
    name: &'static str,
    value: T,
}

fn render<T>(template: WithTemplate<T>, hbs: Arc<Handlebars>) -> impl warp::Reply
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
    let template = "<!DOCTYPE html>
                    <link rel='stylesheet' href='https://cdn.jsdelivr.net/npm/uikit@3.6.18/dist/css/uikit.min.css' />
                    <script src='https://cdn.jsdelivr.net/npm/uikit@3.6.18/dist/js/uikit.min.js'></script>
                    <script src='https://cdn.jsdelivr.net/npm/uikit@3.6.18/dist/js/uikit-icons.min.js'></script>
                    <html>
                      <head>
                        <title>0L</title>
                      </head>
                      <body>
                      <div class='uk-container uk-container-small'>
                        <div class='uk-card uk-card-default uk-card-body uk-width-1-2@m'>
                            <h3 class='uk-card-title'>Node info</h3>
                            <p>Node is synced: {{is_synced}}</p>
                        </div>
                        </div>
                    </body>
                </html>";

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
            let items = check::Items::read_cache().unwrap();
            WithTemplate {
                name: "template.html",
                value: json!({"is_synced" : items.is_synced }),
            }
        })
        .map(handlebars);
    
    // TODO: Server runs monitor in background.
    // monitor::mon();
    warp::serve(route).run(([127, 0, 0, 1], 3030)).await;


}