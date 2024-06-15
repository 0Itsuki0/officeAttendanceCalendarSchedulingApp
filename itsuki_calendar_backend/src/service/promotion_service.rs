use anyhow::{bail, Ok, Result};
use axum::Json;
use bb8::{Pool, PooledConnection};
use chrono::Utc;
use convert_case::{Case, Casing};
use diesel::{
    ExpressionMethods, QueryDsl, SelectableHelper,
};
use diesel_async::{
    pooled_connection::AsyncDieselConnectionManager, AsyncPgConnection, RunQueryDsl,
};
use serde_json::{json, Value};
use std::collections::HashMap;
use strum::IntoEnumIterator;

use crate::{
    model::{promotion::{NewPromotion, Promotion, PromotionType}, user::User},
    schema::{self, promotions::exchanged_by},
    service::user_service::{update_points_remained, update_points_used, user_exist},
};

const POINTS_REQUIRED: i32 = 50;


pub async fn count_unused_promotions(
    pool: &Pool<AsyncDieselConnectionManager<AsyncPgConnection>>,
) -> Result<Json<Value>> {
    let mut map: HashMap<String, usize> = HashMap::new();

    for r#type in PromotionType::iter() {
        let count = count_unused_promotions_by_type(&pool, r#type.clone()).await?;
        map.insert(r#type.to_string().to_case(Case::Snake), count);
    }

    Ok(Json(json!({
        "error": false,
        "promotion_count": map
    })))
}

pub async fn add_promotions(
    pool: &Pool<AsyncDieselConnectionManager<AsyncPgConnection>>,
    new_promotions: Vec<NewPromotion>,
) -> Result<Json<Value>> {
    use schema::promotions;

    let mut conn: PooledConnection<'_, AsyncDieselConnectionManager<AsyncPgConnection>> =
        pool.get().await?;

    let num_row = diesel::insert_into(promotions::table)
        .values(&new_promotions)
        .execute(&mut conn)
        .await?;

    Ok(Json(json!({
        "error": false,
        "promotions_added": num_row
    })))
}

pub async fn exchange_promotion(
    pool: &Pool<AsyncDieselConnectionManager<AsyncPgConnection>>,
    r#type: PromotionType,
    user_id: String,
) -> Result<Json<Value>> {
    if user_id.trim().is_empty() {
        bail!("User Id is required!")
    }
    if !user_exist(&pool, &user_id).await? {
        bail!("user does not exist!")
    }

    use schema::users::dsl::*;
    let mut conn: PooledConnection<'_, AsyncDieselConnectionManager<AsyncPgConnection>> =
        pool.get().await?;

    let user: User = users.find(&user_id).get_result(&mut conn).await?;
    if user.points_remained < POINTS_REQUIRED {
        bail!("Not enought points to exchange!")
    }
    
    use schema::promotions::dsl::{exchanged_date, promotion_type, promotions};

    let mut conn: PooledConnection<'_, AsyncDieselConnectionManager<AsyncPgConnection>> =
        pool.get().await?;

    let result: Promotion = promotions
        .filter(exchanged_date.is_null())
        .filter(promotion_type.eq(r#type))
        .first::<Promotion>(&mut conn)
        .await?;
    let promotion_id = &result.id;

    // update promotion exchanged by and date
    let _: usize = diesel::update(promotions.find(promotion_id))
        .set(exchanged_by.eq(&user_id))
        .returning(Promotion::as_returning())
        .execute(&mut conn)
        .await?;

    // reduct user's points
    update_points_used(&pool, &user_id, POINTS_REQUIRED).await?;
    update_points_remained(&pool, &user_id, -POINTS_REQUIRED).await?;

    let updated_promotion: Promotion = diesel::update(promotions.find(promotion_id))
        .set(exchanged_date.eq(Utc::now().naive_utc()))
        .returning(Promotion::as_returning())
        .get_result(&mut conn)
        .await?;

    Ok(Json(json!({
        "error": false,
        "promotion": updated_promotion
    })))
}

/*  Private  */
async fn count_unused_promotions_by_type(
    pool: &Pool<AsyncDieselConnectionManager<AsyncPgConnection>>,
    r#type: PromotionType,
) -> Result<usize> {
    use schema::promotions;

    let mut conn: PooledConnection<'_, AsyncDieselConnectionManager<AsyncPgConnection>> =
        pool.get().await?;

    // let results = promotions.load::<User>(&mut conn).await?;
    let results = promotions::table
        .filter(promotions::exchanged_date.is_null())
        .filter(promotions::promotion_type.eq(r#type))
        .execute(&mut conn)
        .await?;

    Ok(results)
}
