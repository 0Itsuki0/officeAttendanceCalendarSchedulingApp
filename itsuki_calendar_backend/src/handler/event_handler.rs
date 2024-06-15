use axum::extract::Query;
use axum::http::StatusCode;
use axum::{
    extract::{Path, State},
    response::Json,
};
use chrono::NaiveDateTime;
use diesel_async::pooled_connection::bb8::Pool;
use diesel_async::AsyncPgConnection;
use serde::{Deserialize, Serialize};
use serde_json::Value;

use crate::model::event::{NewEvent, Status};
use crate::service::event_service::{create_new_event, delete_event, list_events, update_event};
use crate::utility::result_to_response;

#[derive(Clone, Debug, Serialize, Deserialize, PartialEq, Eq)]
pub struct GetEventQueryParams {
    pub user_id: Option<String>,
    pub start_time: Option<NaiveDateTime>,
    pub end_time: Option<NaiveDateTime>,
}

#[derive(Clone, Debug, Serialize, Deserialize, PartialEq, Eq)]
pub struct StatusParameter {
    pub status: Status,
}

pub async fn get_events(
    State(pool): State<Pool<AsyncPgConnection>>,
    Query(get_event_parameter): Query<GetEventQueryParams>,
) -> (StatusCode, Json<Value>) {
    let result = list_events(
        &pool,
        get_event_parameter.user_id,
        get_event_parameter.start_time,
        get_event_parameter.end_time,
    )
    .await;
    result_to_response(result)
}

pub async fn post_event(
    State(pool): State<Pool<AsyncPgConnection>>,
    Json(new_event): Json<NewEvent>,
) -> (StatusCode, Json<Value>) {
    let result = create_new_event(&pool, new_event).await;
    result_to_response(result)
}

pub async fn delete_event_single(
    State(pool): State<Pool<AsyncPgConnection>>,
    Path(event_id): Path<String>,
) -> (StatusCode, Json<Value>) {
    let result = delete_event(&pool, &event_id).await;
    result_to_response(result)
}

pub async fn put_event_status(
    State(pool): State<Pool<AsyncPgConnection>>,
    Path(event_id): Path<String>,
    Json(status_parameter): Json<StatusParameter>,
) -> (StatusCode, Json<Value>) {
    let result = update_event(&pool, &event_id, status_parameter.status).await;
    result_to_response(result)
}

