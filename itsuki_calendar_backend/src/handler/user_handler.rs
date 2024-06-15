use axum::http::StatusCode;
use axum::{
    extract::{Path, State},
    response::Json,
};
use diesel_async::pooled_connection::bb8::Pool;
use diesel_async::AsyncPgConnection;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};

use crate::model::user::NewUser;
use crate::service::user_service::{
    change_username, create_new_user, get_user, register_password, verify_user,
};
use crate::utility::result_to_response;

#[derive(Clone, Debug, Serialize, Deserialize, PartialEq, Eq)]
pub struct PutUserInfoParameter {
    pub password: Option<String>,
    pub username: Option<String>,
}

#[derive(Clone, Debug, Serialize, Deserialize, PartialEq, Eq)]
pub struct PostVerifyParameter {
    pub password: String,
}

pub async fn get_user_single(
    State(pool): State<Pool<AsyncPgConnection>>,
    Path(user_id): Path<String>,
) -> (StatusCode, Json<Value>) {
    let result = get_user(&pool, &user_id).await;
    result_to_response(result)
}

pub async fn post_user(
    State(pool): State<Pool<AsyncPgConnection>>,
    Json(new_user): Json<NewUser>,
) -> (StatusCode, Json<Value>) {
    let result = create_new_user(&pool, new_user).await;
    result_to_response(result)
}

pub async fn post_user_verify(
    State(pool): State<Pool<AsyncPgConnection>>,
    Path(user_id): Path<String>,
    Json(password_parameter): Json<PostVerifyParameter>,
) -> (StatusCode, Json<Value>) {
    let result = verify_user(&pool, &user_id, &password_parameter.password).await;
    result_to_response(result)
}

pub async fn put_userinfo(
    State(pool): State<Pool<AsyncPgConnection>>,
    Path(user_id): Path<String>,
    Json(put_userinfo_params): Json<PutUserInfoParameter>,
) -> (StatusCode, Json<Value>) {
    if put_userinfo_params.password.is_some() && put_userinfo_params.username.is_some() {
        return (
            StatusCode::BAD_REQUEST,
            Json(json!({
                "error": true,
                "message": "Cannot change username and password at the same time!"
            })),
        );
    }

    if put_userinfo_params.password.is_none() && put_userinfo_params.username.is_none() {
        return (
            StatusCode::BAD_REQUEST,
            Json(json!({
                "error": true,
                "message": "Both set either a Password or a  user name to change!"
            })),
        );
    }

    if let Some(password) = put_userinfo_params.password {
        let result = register_password(&pool, &user_id, &password).await;
        return result_to_response(result);
    }

    if let Some(username) = put_userinfo_params.username {
        let result = change_username(&pool, &user_id, &username).await;
        return result_to_response(result);
    }

    return (
        StatusCode::BAD_REQUEST,
        Json(json!({
            "error": true,
            "message": "Bad request!"
        })),
    );
}
