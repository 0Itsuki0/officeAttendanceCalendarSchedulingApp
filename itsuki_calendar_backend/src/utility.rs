use anyhow::Result;
use axum::http::StatusCode;
use axum::response::Json;
use serde_json::{json, Value};
use std::time::{Duration, SystemTime, UNIX_EPOCH};


// u64 timestamp to system time
pub fn timestamp_to_systemtime(timestamp: u64) -> SystemTime {
    return UNIX_EPOCH + Duration::from_secs(timestamp);
}

pub fn result_to_response(result: Result<Json<Value>>) -> (StatusCode, Json<Value>) {
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
