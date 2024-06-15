use anyhow::{bail, Ok, Result};
use axum::Json;
use bb8::{Pool, PooledConnection};
use diesel::{ExpressionMethods, QueryDsl, SelectableHelper};
use diesel_async::{
    pooled_connection::AsyncDieselConnectionManager, AsyncPgConnection, RunQueryDsl,
};
use serde_json::{json, Value};

use crate::{
    model::user::{ NewUser, User},
    schema,
};

pub async fn list_users(
    pool: &Pool<AsyncDieselConnectionManager<AsyncPgConnection>>,
) -> Result<Json<Value>> {
    use schema::users::dsl::*;

    let mut conn: PooledConnection<'_, AsyncDieselConnectionManager<AsyncPgConnection>> =
        pool.get().await?;

    let results = users.load::<User>(&mut conn).await?;

    Ok(Json(json!({
        "error": false,
        "users": results
    })))
}

pub async fn create_new_user(
    pool: &Pool<AsyncDieselConnectionManager<AsyncPgConnection>>,
    new_user: NewUser,
) -> Result<Json<Value>> {
    if user_exist(&pool, &new_user.id).await? == true {
        bail!("User already exists!")
    }

    use schema::users;

    let mut conn: PooledConnection<'_, AsyncDieselConnectionManager<AsyncPgConnection>> =
        pool.get().await?;

    let user: User = diesel::insert_into(users::table)
        .values(&new_user)
        .returning(User::as_returning())
        .get_result(&mut conn)
        .await?;

    Ok(Json(json!({
        "error": false,
        "user": user
    })))
}

pub async fn register_password(
    pool: &Pool<AsyncDieselConnectionManager<AsyncPgConnection>>,
    user_id: &str,
    sync_password: &str,
) -> Result<Json<Value>> {
    if sync_password.trim().is_empty() || user_id.trim().is_empty() {
        bail!("User Id and Password is required!")
    }
    if user_exist(&pool, user_id).await? == false {
        bail!("Cannot register password for unknown user!")
    }
    use schema::users::dsl::{password, users};
    let mut conn: PooledConnection<'_, AsyncDieselConnectionManager<AsyncPgConnection>> =
        pool.get().await?;

    let user: User = diesel::update(users.find(user_id))
        .set(password.eq(sync_password))
        .returning(User::as_returning())
        .get_result(&mut conn)
        .await?;
    println!("registered password for user: {:?}", user);

    Ok(Json(json!({
        "error": false,
        "user": user
    })))
}

pub async fn change_username(
    pool: &Pool<AsyncDieselConnectionManager<AsyncPgConnection>>,
    user_id: &str,
    new_username: &str,
) -> Result<Json<Value>> {
    if new_username.trim().is_empty() || user_id.trim().is_empty() {
        bail!("User Id and username is required!")
    }
    if user_exist(&pool, user_id).await? == false {
        bail!("Cannot register password for unknown user!")
    }
    use schema::users::dsl::{username, users};
    let mut conn: PooledConnection<'_, AsyncDieselConnectionManager<AsyncPgConnection>> =
        pool.get().await?;

    let user: User = diesel::update(users.find(user_id))
        .set(username.eq(new_username))
        .returning(User::as_returning())
        .get_result(&mut conn)
        .await?;
    println!("registered new_username for user: {:?}", user);

    Ok(Json(json!({
        "error": false,
        "user": user
    })))
}

pub async fn plus_total_attendance(
    pool: &Pool<AsyncDieselConnectionManager<AsyncPgConnection>>,
    user_id: &str,
) -> Result<Json<Value>> {
    if user_id.trim().is_empty() {
        bail!("User Id is required!")
    }
    if user_exist(&pool, user_id).await? == false {
        bail!("Cannot update attendance for unknown user!")
    }
    use schema::users::dsl::{total_attendance, users};
    let mut conn: PooledConnection<'_, AsyncDieselConnectionManager<AsyncPgConnection>> =
        pool.get().await?;

    // update attendance count
    diesel::update(users.find(user_id))
        .set(total_attendance.eq(total_attendance + 1))
        .returning(User::as_returning())
        .execute(&mut conn)
        .await?;

    // update points
    update_points_remained(&pool, user_id, 1).await?;
    let user: User = users.find(user_id).get_result(&mut conn).await?;
    println!("attendance updated for user: {:?}", user);
    
    Ok(Json(json!({
        "error": false,
        "user": user
    })))
}

// verify user
pub async fn verify_user(
    pool: &Pool<AsyncDieselConnectionManager<AsyncPgConnection>>,
    user_id: &str,
    sync_password: &str,
) -> Result<Json<Value>> {
    if sync_password.trim().is_empty() || user_id.trim().is_empty() {
        bail!("User Id and Password is required!")
    }

    if user_exist(&pool, user_id).await? == false {
        bail!("Cannot vefiry for unknown user!")
    }

    use schema::users::dsl::*;

    let mut conn: PooledConnection<'_, AsyncDieselConnectionManager<AsyncPgConnection>> =
        pool.get().await?;

    let result : Result<User, diesel::result::Error>= users
        .find(user_id)
        .filter(password.eq(sync_password))
        .get_result(&mut conn)
        .await;
    
    if result.is_err() {
        bail!("Bad Password!")
    }  

    Ok(Json(json!({
        "error": false,
        "user": result.unwrap()
    })))
}

pub async fn get_user(
    pool: &Pool<AsyncDieselConnectionManager<AsyncPgConnection>>,
    user_id: &str,
) -> Result<Json<Value>> {
    if user_id.trim().is_empty() {
        bail!("User Id is required!")
    }

    use schema::users::dsl::*;
    // get connection
    let mut conn: PooledConnection<'_, AsyncDieselConnectionManager<AsyncPgConnection>> =
        pool.get().await?;

    let user: User = users.find(user_id).get_result(&mut conn).await?;

    Ok(Json(json!({
        "error": false,
        "user": user
    })))
}

pub async fn user_exist(
    pool: &Pool<AsyncDieselConnectionManager<AsyncPgConnection>>,
    user_id: &str,
) -> Result<bool> {
    if user_id.trim().is_empty() {
        bail!("User Id and Password is required!")
    }

    use schema::users::dsl::*;

    let mut conn: PooledConnection<'_, AsyncDieselConnectionManager<AsyncPgConnection>> =
        pool.get().await?;

    let count = users.find(user_id).execute(&mut conn).await?;
    println!("user count {:?}", count);

    Ok(count != 0)
}

pub async fn update_points_remained(
    pool: &Pool<AsyncDieselConnectionManager<AsyncPgConnection>>,
    user_id: &str,
    points_remained_change: i32,
) -> Result<()> {
    if user_id.trim().is_empty() {
        bail!("User Id is required!")
    }
    use schema::users::dsl::{points_remained, users};
    let mut conn: PooledConnection<'_, AsyncDieselConnectionManager<AsyncPgConnection>> =
        pool.get().await?;

    diesel::update(users.find(user_id))
        .set(points_remained.eq(points_remained + points_remained_change))
        .returning(User::as_returning())
        .execute(&mut conn)
        .await?;

    Ok(())
}


pub async fn update_points_used(
    pool: &Pool<AsyncDieselConnectionManager<AsyncPgConnection>>,
    user_id: &str,
    points_used_change: i32,
) -> Result<()> {
    if user_id.trim().is_empty() {
        bail!("User Id is required!")
    }
    use schema::users::dsl::{points_used, users};
    let mut conn: PooledConnection<'_, AsyncDieselConnectionManager<AsyncPgConnection>> =
        pool.get().await?;


    diesel::update(users.find(user_id))
        .set(points_used.eq(points_used + points_used_change))
        .returning(User::as_returning())
        .execute(&mut conn)
        .await?;

    Ok(())
}


