// @generated automatically by Diesel CLI.

pub mod sql_types {
    #[derive(diesel::query_builder::QueryId, diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "location"))]
    pub struct Location;

    #[derive(diesel::query_builder::QueryId, diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "promotion_type"))]
    pub struct PromotionType;

    #[derive(diesel::query_builder::QueryId, diesel::sql_types::SqlType)]
    #[diesel(postgres_type(name = "status"))]
    pub struct Status;
}

diesel::table! {
    use diesel::sql_types::*;
    use super::sql_types::Location;
    use super::sql_types::Status;

    events (id) {
        id -> Varchar,
        location -> Location,
        status -> Status,
        timestamp -> Timestamp,
        user_id -> Varchar,
    }
}

diesel::table! {
    use diesel::sql_types::*;
    use super::sql_types::PromotionType;

    promotions (id) {
        id -> Varchar,
        promotion_type -> PromotionType,
        promotion_code -> Varchar,
        promotion_value -> Int4,
        points_required -> Int4,
        exchanged_date -> Nullable<Timestamp>,
        exchanged_by -> Nullable<Varchar>,
    }
}

diesel::table! {
    users (id) {
        id -> Varchar,
        username -> Varchar,
        password -> Nullable<Varchar>,
        total_attendance -> Int4,
        points_remained -> Int4,
        points_used -> Int4,
    }
}

diesel::joinable!(events -> users (user_id));
diesel::joinable!(promotions -> users (exchanged_by));

diesel::allow_tables_to_appear_in_same_query!(
    events,
    promotions,
    users,
);
