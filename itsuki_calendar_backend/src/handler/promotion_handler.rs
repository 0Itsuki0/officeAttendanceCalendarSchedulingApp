use axum::http::StatusCode;
use axum::{
    extract::State,
    response::Json,
};
use diesel_async::pooled_connection::bb8::Pool;
use diesel_async::AsyncPgConnection;
use serde::{Deserialize, Serialize};
use serde_json::Value;

use crate::model::promotion::{NewPromotion, PromotionType};
use crate::service::promotion_service::{
    add_promotions, count_unused_promotions, exchange_promotion,
};
use crate::utility::result_to_response;

#[derive(Clone, Debug, Serialize, Deserialize, PartialEq, Eq)]
pub struct NewPromotionsVecParameter {
    pub promotions: Vec<NewPromotionParameter>,
}

#[derive(Clone, Debug, Serialize, Deserialize, PartialEq, Eq)]
pub struct NewPromotionParameter {
    pub r#type: PromotionType,
    pub code: String,
    pub promotion_value: Option<i32>,
    pub points_required: Option<i32>,
}

#[derive(Clone, Debug, Serialize, Deserialize, PartialEq, Eq)]
pub struct ExchangePromotionParameter {
    pub r#type: PromotionType,
    pub user_id: String,
}

pub async fn get_unused_promotions_count(
    State(pool): State<Pool<AsyncPgConnection>>,
    // Query(get_event_parameter): Query<GetEventQueryParams>,
) -> (StatusCode, Json<Value>) {
    let result = count_unused_promotions(&pool).await;
    result_to_response(result)
}

pub async fn post_exchange_promotion(
    State(pool): State<Pool<AsyncPgConnection>>,
    Json(get_promotion_type_params): Json<ExchangePromotionParameter>,
) -> (StatusCode, Json<Value>) {
    let result = exchange_promotion(
        &pool,
        get_promotion_type_params.r#type,
        get_promotion_type_params.user_id,
    )
    .await;
    result_to_response(result)
}

pub async fn post_promotions(
    State(pool): State<Pool<AsyncPgConnection>>,
    Json(new_promotions): Json<NewPromotionsVecParameter>,
) -> (StatusCode, Json<Value>) {
    let result = add_promotions(
        &pool,
        new_promotions
            .promotions
            .iter()
            .map(|promotion| {
                NewPromotion::new(promotion.r#type.to_owned(), promotion.code.to_owned(), promotion.promotion_value.to_owned(), promotion.points_required.to_owned())
            })
            .collect::<Vec<NewPromotion>>(),
    )
    .await;
    result_to_response(result)
}
