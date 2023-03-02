// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

use crate::{
    accounts,
    context::Context,
    events,
    failpoint::fail_point,
    log,
    metrics::{metrics, status_metrics},
    transactions,
};
use diem_api_types::{Error, Response, U64};
use diem_types::waypoint::Waypoint;
use serde::Serialize;

use std::convert::Infallible;
use warp::{
    body::BodyDeserializeError,
    cors::CorsForbidden,
    filters::BoxedFilter,
    http::{header, StatusCode},
    reject::{LengthRequired, MethodNotAllowed, PayloadTooLarge, UnsupportedMediaType},
    reply, Filter, Rejection, Reply,
};

const OPEN_API_HTML: &str = include_str!("../doc/spec.html");
const OPEN_API_SPEC: &str = include_str!("../doc/openapi.yaml");

/////// 0L ////////
// modify the index of the API to show a waypoint
#[derive(Clone, Debug, Serialize, PartialEq)]
struct Index {
  chain_id: u8,
  ledger_version: U64,
  ledger_timestamp: U64,
  waypoint: Waypoint,
  epoch: U64,
  epoch_waypoint: Option<Waypoint>,
}


pub fn routes(context: Context) -> impl Filter<Extract = impl Reply, Error = Infallible> + Clone {
    index(context.clone())
        .or(openapi_spec())
        .or(accounts::get_account(context.clone()))
        .or(accounts::get_account_resources(context.clone()))
        .or(accounts::get_account_resources_by_ledger_version(
            context.clone(),
        ))
        .or(accounts::get_account_modules(context.clone()))
        .or(accounts::get_account_modules_by_ledger_version(
            context.clone(),
        ))
        .or(transactions::get_transaction(context.clone()))
        .or(transactions::get_transactions(context.clone()))
        .or(transactions::get_account_transactions(context.clone()))
        .or(transactions::submit_bcs_transactions(context.clone()))
        .or(transactions::submit_json_transactions(context.clone()))
        .or(transactions::create_signing_message(context.clone()))
        .or(events::get_events_by_event_key(context.clone()))
        .or(events::get_events_by_event_handle(context.clone()))
        .or(context.health_check_route().with(metrics("health_check")))
        // jsonrpc routes must before `recover` and after `index`
        // so that POST '/' can be handled by jsonrpc routes instead of `index` route
        .or(context.jsonrpc_routes().with(metrics("json_rpc")))
        .with(
            warp::cors()
                .allow_any_origin()
                .allow_methods(vec!["POST", "GET"])
                .allow_headers(vec![header::CONTENT_TYPE]),
        )
        .recover(handle_rejection)
        .with(log::logger())
        .with(status_metrics())
}

// GET /openapi.yaml
// GET /spec.html
pub fn openapi_spec() -> BoxedFilter<(impl Reply,)> {
    let spec = warp::path!("openapi.yaml")
        .and(warp::get())
        .map(|| OPEN_API_SPEC)
        .with(metrics("openapi_yaml"))
        .boxed();
    let html = warp::path!("spec.html")
        .and(warp::get())
        .map(|| reply::html(open_api_html()))
        .with(metrics("spec_html"))
        .boxed();
    spec.or(html).boxed()
}

// GET /
pub fn index(context: Context) -> BoxedFilter<(impl Reply,)> {
    warp::path::end()
        .and(warp::get())
        .and(context.filter())
        .and_then(handle_index)
        .with(metrics("get_ledger_info"))
        .boxed()
}

pub async fn handle_index(context: Context) -> Result<impl Reply, Rejection> {
    fail_point("endpoint_index")?;
    let info = context.get_latest_ledger_info()?;

    let li_type = context.get_latest_ledger_info_with_signatures()
    .map_err(|e| Error::from(e))?;

    let current_epoch = li_type.ledger_info().epoch();
    let prev_epoch = if current_epoch > 0 { current_epoch - 1 } else {0};

    let prev_epoch_li = context.get_epoch_change_proof(prev_epoch, current_epoch)
    .map_err(|e| Error::from(e));

    let epoch_wp = match prev_epoch_li {
        Ok(mut vec) => {
          let prev_epoch_li = vec.pop();
          
          if let Some(li) = prev_epoch_li {
            Some(Waypoint::new_any(&li.ledger_info()))
          } else {
            None
          }
        },
        Err(_) => None
    };

    let wp = Waypoint::new_any(&li_type.ledger_info());

    let i = Index {
        chain_id: info.chain_id,
        ledger_version: info.ledger_version,
        ledger_timestamp: info.ledger_timestamp,
        waypoint: wp,
        epoch: U64(current_epoch),
        epoch_waypoint: epoch_wp,
    };

    Ok(Response::new(info.clone(), &i)?)
}

async fn handle_rejection(err: Rejection) -> Result<impl Reply, Infallible> {
    let code;
    let body;

    if err.is_not_found() {
        code = StatusCode::NOT_FOUND;
        body = reply::json(&Error::new(code, "Not Found".to_owned()));
    } else if let Some(error) = err.find::<Error>() {
        code = error.status_code();
        body = reply::json(error);
    } else if let Some(cause) = err.find::<CorsForbidden>() {
        code = StatusCode::FORBIDDEN;
        body = reply::json(&Error::new(code, cause.to_string()));
    } else if let Some(cause) = err.find::<BodyDeserializeError>() {
        code = StatusCode::BAD_REQUEST;
        body = reply::json(&Error::new(code, cause.to_string()));
    } else if let Some(cause) = err.find::<LengthRequired>() {
        code = StatusCode::LENGTH_REQUIRED;
        body = reply::json(&Error::new(code, cause.to_string()));
    } else if let Some(cause) = err.find::<PayloadTooLarge>() {
        code = StatusCode::PAYLOAD_TOO_LARGE;
        body = reply::json(&Error::new(code, cause.to_string()));
    } else if let Some(cause) = err.find::<UnsupportedMediaType>() {
        code = StatusCode::UNSUPPORTED_MEDIA_TYPE;
        body = reply::json(&Error::new(code, cause.to_string()));
    } else if let Some(cause) = err.find::<MethodNotAllowed>() {
        code = StatusCode::METHOD_NOT_ALLOWED;
        body = reply::json(&Error::new(code, cause.to_string()));
    } else {
        code = StatusCode::INTERNAL_SERVER_ERROR;
        body = reply::json(&Error::new(code, format!("unexpected error: {:?}", err)));
    }
    Ok(reply::with_status(body, code))
}

fn open_api_html() -> String {
    OPEN_API_HTML.replace("hideTryIt=\"true\"", "")
}
