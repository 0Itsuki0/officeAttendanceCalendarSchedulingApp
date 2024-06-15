use chrono::NaiveDateTime;
use diesel::prelude::*;
use serde::{Deserialize, Serialize};
use std::io::Write;

use diesel::{
    deserialize::{self, FromSql, FromSqlRow},
    expression::AsExpression,
    pg::{Pg, PgValue},
    serialize::{self, IsNull, Output, ToSql},
};

#[derive(Debug, AsExpression, FromSqlRow, Serialize, Deserialize, Clone)]
#[diesel(sql_type = crate::schema::sql_types::Location)]
#[serde(rename_all = "snake_case")]
pub enum Location {
    Nagoya,
    Tokyo,
    Nagaoka,
}

impl ToSql<crate::schema::sql_types::Location, Pg> for Location {
    fn to_sql<'b>(&'b self, out: &mut Output<'b, '_, Pg>) -> serialize::Result {
        match *self {
            Location::Nagoya => out.write_all(b"Nagoya")?,
            Location::Tokyo => out.write_all(b"Tokyo")?,
            Location::Nagaoka => out.write_all(b"Nagaoka")?,
        }
        Ok(IsNull::No)
    }
}

impl FromSql<crate::schema::sql_types::Location, Pg> for Location {
    fn from_sql(bytes: PgValue) -> deserialize::Result<Self> {
        match bytes.as_bytes() {
            b"Nagoya" => Ok(Location::Nagoya),
            b"Tokyo" => Ok(Location::Tokyo),
            b"Nagaoka" => Ok(Location::Nagaoka),
            _ => Err("Unrecognized enum variant".into()),
        }
    }
}

#[derive(Debug, AsExpression, FromSqlRow, Serialize, Deserialize, Clone, PartialEq, Eq)]
#[diesel(sql_type = crate::schema::sql_types::Status)]
#[serde(rename_all = "snake_case")]
pub enum Status {
    Went,
    Absence,
    Going,
}

impl ToSql<crate::schema::sql_types::Status, Pg> for Status {
    fn to_sql<'b>(&'b self, out: &mut Output<'b, '_, Pg>) -> serialize::Result {
        match *self {
            Status::Went => out.write_all(b"Went")?,
            Status::Absence => out.write_all(b"Absence")?,
            Status::Going => out.write_all(b"Going")?,
        }
        Ok(IsNull::No)
    }
}

impl FromSql<crate::schema::sql_types::Status, Pg> for Status {
    fn from_sql(bytes: PgValue) -> deserialize::Result<Self> {
        match bytes.as_bytes() {
            b"Went" => Ok(Status::Went),
            b"Absence" => Ok(Status::Absence),
            b"Going" => Ok(Status::Going),
            _ => Err("Unrecognized enum variant".into()),
        }
    }
}

#[derive(Queryable, Selectable, Serialize, Debug, Deserialize, Clone)]
#[diesel(table_name = crate::schema::events)]
pub struct Event {
    pub id: String,
    pub location: Location,
    pub status: Status,
    pub timestamp: NaiveDateTime, // yyyy-MM-ddTHH:mm:ss or yyyy-MM-ddTHH:mm:ss.000
    pub user_id: String,
}

#[derive(Deserialize, Insertable)]
#[diesel(table_name = crate::schema::events)]
#[serde(rename_all = "snake_case")]
pub struct NewEvent {
    pub id: String,
    pub location: Location,
    pub timestamp: NaiveDateTime,
    pub user_id: String,
}

#[derive(Deserialize, Serialize)]
#[serde(rename_all = "snake_case")]
pub struct EventResponse {
    pub id: String,
    pub location: Location,
    pub status: Status,
    pub timestamp: NaiveDateTime, // yyyy-MM-ddTHH:mm:ss or yyyy-MM-ddTHH:mm:ss.000
    pub user_id: String,
    pub user_name: String,
}

impl EventResponse {
    pub fn new(event: Event, user_name: String) -> Self {
        Self {
            id: event.id,
            location: event.location,
            status: event.status,
            timestamp: event.timestamp,
            user_id: event.user_id,
            user_name: user_name.to_owned(),
        }
    }
}
