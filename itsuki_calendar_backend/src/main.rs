pub mod handler;
pub mod model;
pub mod schema;
pub mod service;
pub mod utility;

use axum::{
    routing::{delete, get, post, put},
    Router,
};
use bb8::Pool;
use diesel_async::{pooled_connection::AsyncDieselConnectionManager, AsyncPgConnection};
use lambda_http::{run, tracing, Error};
use std::env::{self, set_var};

#[tokio::main]
async fn main() -> Result<(), Error> {
    tracing::init_default_subscriber();
    set_var("AWS_LAMBDA_HTTP_IGNORE_STAGE_IN_PATH", "true");

    let db_url = env::var("DATABASE_URL")?;

    let pool: Pool<AsyncDieselConnectionManager<AsyncPgConnection>> =
        get_connection_pool(&db_url).await?;

    let user_api = Router::new()
        .route("/", post(handler::user_handler::post_user))
        .route(
            "/:user_id",
            get(handler::user_handler::get_user_single).put(handler::user_handler::put_userinfo),
        )
        .route(
            "/:user_id/verify",
            post(handler::user_handler::post_user_verify),
        );

    let event_api = Router::new()
        .route(
            "/",
            get(handler::event_handler::get_events).post(handler::event_handler::post_event),
        )
        .route(
            "/:event_id",
            delete(handler::event_handler::delete_event_single),
        )
        .route("/:event_id", put(handler::event_handler::put_event_status));

    let promotion_api = Router::new()
        .route("/", post(handler::promotion_handler::post_promotions))
        .route(
            "/unused_count",
            get(handler::promotion_handler::get_unused_promotions_count),
        )
        .route(
            "/exchange",
            post(handler::promotion_handler::post_exchange_promotion),
        );

    // app router
    let app = Router::new()
        .nest("/users", user_api)
        .nest("/events", event_api)
        .nest("/promotions", promotion_api)
        .with_state(pool);

    run(app).await
    // Ok(())
}

pub async fn get_connection_pool(
    db_url: &str,
) -> Result<Pool<AsyncDieselConnectionManager<AsyncPgConnection>>, Error> {
    let config = AsyncDieselConnectionManager::<AsyncPgConnection>::new(db_url);
    let pool = Pool::builder().build(config).await?;
    Ok(pool)
}
