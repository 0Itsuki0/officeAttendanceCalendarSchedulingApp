// use crate::event::Event;
// use crate::event_service::EventService;
use crate::handler_params::{PutTitleParams, QueryParams};

use anyhow::Result;
use axum::extract::Query;
use axum::http::StatusCode;
use axum::{
    extract::{Path, State},
    response::Json,
};
use serde_json::{json, Value};

// pub async fn get_events(
//     State(service): State<EventService>,
//     Query(params): Query<QueryParams>,
// ) -> (StatusCode, Json<Value>) {
//     let result = service.get_events(params).await;
//     result_to_response(result)
// }

// pub async fn post_event(
//     State(service): State<EventService>,
//     Json(event): Json<Event>,
// ) -> (StatusCode, Json<Value>) {
//     let result = service.post_event(event).await;
//     result_to_response(result)
// }

// pub async fn get_event_single(
//     State(service): State<EventService>,
//     Path(id): Path<String>,
// ) -> (StatusCode, Json<Value>) {
//     let result = service.get_event_single(id).await;
//     result_to_response(result)
// }

// pub async fn delete_event_single(
//     State(service): State<EventService>,
//     Path(id): Path<String>,
// ) -> (StatusCode, Json<Value>) {
//     let result = service.delete_event_single(id).await;
//     result_to_response(result)
// }

// pub async fn put_event_status(
//     State(service): State<EventService>,
//     Path(id): Path<String>,
//     Json(put_title_params): Json<PutTitleParams>,
// ) -> (StatusCode, Json<Value>) {
//     let result = service.put_event_status(id, put_title_params.status).await;
//     result_to_response(result)
// }

fn result_to_response(result: Result<Json<Value>>) -> (StatusCode, Json<Value>) {
    match result {
        Ok(json) => (StatusCode::OK, json),
        Err(error) => (
            StatusCode::BAD_REQUEST,
            Json(json!({
                "error": true,
                "message": error.to_string()
            })),
        ),
    }
}
