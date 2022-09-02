//! `server`  web monitor http server
// use futures::StreamExt;
use futures::StreamExt;
use ol_types::config::IS_PROD;
use reqwest;
use serde_json::json;
use serde_json::Error;
use std::{fs, io, path::PathBuf, process::Command, thread, time::Duration};
use tokio::time::interval;
use tokio_stream::wrappers::IntervalStream;
use warp::{sse::Event, Filter};
use std::process::exit;

use crate::{cache::Vitals, check::runner, node::node::Node};

#[tokio::main]
/// starts the web server
pub async fn start_server(mut node: Node, _run_checks: bool) {
    let cfg = node.app_conf.clone();

    // if run_checks {
    thread::spawn(move || {
        runner::run_checks(&mut node, false, true, false, false);
    });
    // }

    //GET check/ (json api for check data)
    let node_home = cfg.clone().workspace.node_home.clone();
    let vitals_route = warp::path("vitals").and(warp::get()).map(move || {
        let path = node_home.clone();
        let interval = interval(Duration::from_secs(10));
        let stream = IntervalStream::new(interval);
        let event_stream = stream.map(move |_| {
            let vitals = Vitals::read_json(&path);
            sse_vitals(vitals)
        });
        // reply using server-sent events
        warp::sse::reply(event_stream)
    });

    // TODO: re-assigning node_home because warp moves it.
    let node_home = cfg.clone().workspace.node_home.clone();
    let account_file_name = "account.json";
    let account_template = warp::path(account_file_name).and(warp::get()).map(move || {
        let account_path = node_home.join(account_file_name);
        match fs::read_to_string(account_path) {
            Ok(value) => value,
            Err(msg) => {
                println!("Could not read {}: \nError {}", account_file_name, msg);
                exit(1)
            },
        }
    });

    let node_home = cfg.clone().workspace.node_home.clone();
    let epoch_route = warp::path("epoch.json").and(warp::get()).map(move || {
        // let node_home = node_home_two.clone();
        let vitals = Vitals::read_json(&node_home).chain_view.unwrap();
        let json = json!({
          "epoch": vitals.epoch,
          "waypoint": vitals.waypoint.unwrap().to_string()
        });
        json.to_string()
    });

    let node_home = cfg.clone().workspace.node_home.clone();
    let web_files = if *IS_PROD {
        node_home.join("web-monitor/")
    // for using `npm run dev`
    } else {
        let source_path = env!("CARGO_MANIFEST_DIR");
        let path = PathBuf::from(source_path);
        path.join("web-monitor/public/")
    };

    //GET /
    let landing = warp::fs::dir(web_files);

    warp::serve(
        landing
            .or(account_template)
            .or(vitals_route)
            .or(epoch_route),
    )
    .run(([0, 0, 0, 0], 3030))
    .await;
}

/// Prepare to start server
pub fn init(node: &mut Node, _run_checks: bool) {
    // if run_checks {
    /*
        Initialize cache to avoid:
        - read a cache file not created yet
        - load old cache with invalid structs
    */
    node.check_once(false);
    // }
}

fn sse_vitals(data: Vitals) -> Result<Event, Error> {
    Event::default().json_data(data)
}

/// Fetch updated static web files from release, for web-monitor.
pub fn update_web(home_path: &PathBuf) {
    let file_name = "web-monitor.tar.gz";
    let dir_name = "web-monitor/";
    let url = &format!(
        "https://github.com/OLSF/libra/releases/latest/download/{}",
        file_name
    );
    println!("Fetching web files from, {}", url);
    let zip_path = home_path.join(file_name).to_str().unwrap().to_owned();
    let dir_path = home_path.join(dir_name).to_str().unwrap().to_owned();
    fs::create_dir_all(&dir_path).expect("cannot create web files directory");
    dbg!(&zip_path);
    dbg!(&dir_path);
    let mut resp = reqwest::blocking::get(url).expect("failed to fetch web files from github");
    let mut out = fs::File::create(&zip_path).expect("cannot create web files zip");
    io::copy(&mut resp, &mut out).expect("failed to write to web files zip");
    println!("fetched web files from github, copied to {:?}", &zip_path);
    let mut child = Command::new("tar")
        .arg("-xf")
        .arg(&zip_path)
        .arg("-C")
        .arg(&dir_path)
        .spawn()
        .expect(&format!(
            "failed to unzip {:?} into {:?}",
            &zip_path, &dir_path
        ));

    let ecode = child.wait().expect("failed to wait on child");
    assert!(ecode.success());
}
