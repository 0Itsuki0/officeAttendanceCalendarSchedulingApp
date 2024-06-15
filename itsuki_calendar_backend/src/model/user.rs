use diesel::prelude::*;
use serde::{Deserialize, Serialize};

#[derive(Debug, Queryable, Selectable, Serialize)]
#[diesel(table_name = crate::schema::users)]
#[serde(rename_all = "snake_case")]
pub struct User {
    pub id: String,
    pub username: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub password: Option<String>,
    pub total_attendance: i32,
    pub points_remained: i32,
    pub points_used: i32,
}

#[derive(Deserialize, Insertable)]
#[diesel(table_name = crate::schema::users)]
#[serde(rename_all = "snake_case")]
pub struct NewUser {
    pub id: String,
    pub username: String,
}
