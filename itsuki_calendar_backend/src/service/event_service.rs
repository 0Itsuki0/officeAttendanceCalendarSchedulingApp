use anyhow::{bail, Ok, Result};
use axum::Json;
use bb8::{Pool, PooledConnection};
use chrono::NaiveDateTime;
use diesel::{
    dsl::sql,
    sql_types::{Bool, Timestamp},
    ExpressionMethods, QueryDsl, SelectableHelper,
};
use diesel_async::{
    pooled_connection::AsyncDieselConnectionManager, AsyncPgConnection, RunQueryDsl,
};
use serde_json::{json, Value};

use crate::{
    model::event::{Event, EventResponse, NewEvent, Status},
    schema::{self},
    service::user_service,
};

pub async fn list_events(
    pool: &Pool<AsyncDieselConnectionManager<AsyncPgConnection>>,
    user_id: Option<String>,
    start: Option<NaiveDateTime>,
    end: Option<NaiveDateTime>,
) -> Result<Json<Value>> {
    use schema::{events, users};

    // get connection
    let mut conn: PooledConnection<'_, AsyncDieselConnectionManager<AsyncPgConnection>> =
        pool.get().await?;

    let mut query = events::table.inner_join(users::table).into_boxed();
    if let Some(user_id) = user_id {
        query = query.filter(events::user_id.eq(user_id));
    }

    if let Some(start) = start {
        query = query
            .filter(sql::<Bool>("DATE_TRUNC('second', timestamp) >= ").bind::<Timestamp, _>(start))
    }
    if let Some(end) = end {
        query = query
            .filter(sql::<Bool>("DATE_TRUNC('second', timestamp) <= ").bind::<Timestamp, _>(end))
    }

    let results = query
        .select((Event::as_select(), users::username))
        .load::<(Event, String)>(&mut conn)
        .await?;

    Ok(Json(json!({
        "error": false,
        "events": results.iter().map(|(event, user_name)| EventResponse::new(event.to_owned(), user_name.to_owned())).collect::<Vec<EventResponse>>()
    })))
}

pub async fn create_new_event(
    pool: &Pool<AsyncDieselConnectionManager<AsyncPgConnection>>,
    new_event: NewEvent,
) -> Result<Json<Value>> {
    use schema::events;

    let mut conn: PooledConnection<'_, AsyncDieselConnectionManager<AsyncPgConnection>> =
        pool.get().await?;

    // check if event already exist for the user
    let event: Vec<Event> = events::table
        .filter(events::user_id.eq(&new_event.user_id))
        .filter(events::timestamp.eq(new_event.timestamp))
        .select(Event::as_select())
        .load(&mut conn)
        .await?;
    if !event.is_empty() {
        bail!("Event already exists at this date!")
    }

    let _num_row = diesel::insert_into(events::table)
        .values(&new_event)
        .returning(Event::as_returning())
        .execute(&mut conn)
        .await?;

    let new_event = get_event_single(&pool, &new_event.id).await?;

    Ok(Json(json!({
        "error": false,
        "event": new_event
    })))
}

pub async fn delete_event(
    pool: &Pool<AsyncDieselConnectionManager<AsyncPgConnection>>,
    event_id: &str,
) -> Result<Json<Value>> {
    if event_id.trim().is_empty() {
        bail!("Event Id is required!")
    }

    if event_exist(&pool, event_id).await? == false {
        bail!("Cannot delete non-existing event!")
    }
    use schema::events::dsl::*;

    let mut conn: PooledConnection<'_, AsyncDieselConnectionManager<AsyncPgConnection>> =
        pool.get().await?;

    let event_deleted: Event = diesel::delete(events.find(event_id))
        .get_result(&mut conn)
        .await?;

    println!(" event deleted: {:?}", event_deleted);

    Ok(Json(json!({
        "error": false
    })))
}

pub async fn update_event(
    pool: &Pool<AsyncDieselConnectionManager<AsyncPgConnection>>,
    event_id: &str,
    new_status: Status,
) -> Result<Json<Value>> {
    if event_id.trim().is_empty() {
        bail!("Event Id is required!")
    }
    if new_status != Status::Went {
        bail!("Modifying Status to Going or Absence is not allowed!")
    }

    if event_exist(&pool, event_id).await? == false {
        bail!("Cannot update non-existing event!")
    }
    use schema::events::dsl::{events, status};

    let mut conn: PooledConnection<'_, AsyncDieselConnectionManager<AsyncPgConnection>> =
        pool.get().await?;

    let updated_rows: usize = diesel::update(events.find(event_id))
        .filter(status.ne(Status::Went))
        .set(status.eq(new_status))
        .returning(Event::as_returning())
        .execute(&mut conn)
        .await?;

    if updated_rows == 0 {
        bail!("Event is already in Went status!")
    }

    let updated_event = get_event_single(&pool, event_id).await?;
    let user = user_service::plus_total_attendance(&pool, &updated_event.user_id).await?;

    println!("event updated: {:?}", updated_rows);
    println!("user: {:?}", user);

    Ok(Json(json!({
        "error": false,
        "event": updated_event
    })))
}

/*  Private  */
async fn get_event_single(
    pool: &Pool<AsyncDieselConnectionManager<AsyncPgConnection>>,
    event_id: &str,
) -> Result<EventResponse> {
    use schema::{events, users};

    // get connection
    let mut conn: PooledConnection<'_, AsyncDieselConnectionManager<AsyncPgConnection>> =
        pool.get().await?;

    let result = events::table
        .find(event_id)
        .inner_join(users::table)
        .select((Event::as_select(), users::username))
        .first::<(Event, String)>(&mut conn)
        .await?;
    let event_response = EventResponse::new(result.0, result.1);
    Ok(event_response)
}
async fn event_exist(
    pool: &Pool<AsyncDieselConnectionManager<AsyncPgConnection>>,
    event_id: &str,
) -> Result<bool> {
    if event_id.trim().is_empty() {
        bail!("Event Id is required!")
    }
    use schema::events::dsl::*;

    // get connection
    let mut conn: PooledConnection<'_, AsyncDieselConnectionManager<AsyncPgConnection>> =
        pool.get().await?;

    let count = events.find(event_id).execute(&mut conn).await?;
    println!("event count {:?}", count);

    Ok(count != 0)
}
