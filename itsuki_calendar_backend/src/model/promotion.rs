use chrono::NaiveDateTime;
use diesel::prelude::*;
use serde::{Deserialize, Serialize};
use std::{fmt, io::Write};
use strum_macros::EnumIter;

use diesel::{
    deserialize::{self, FromSql, FromSqlRow},
    expression::AsExpression,
    pg::{Pg, PgValue},
    serialize::{self, IsNull, Output, ToSql},
};

#[derive(
    Debug, AsExpression, FromSqlRow, Serialize, Deserialize, Clone, PartialEq, Eq, EnumIter,
)]
#[diesel(sql_type = crate::schema::sql_types::PromotionType)]
#[serde(rename_all = "snake_case")]
pub enum PromotionType {
    Apple,
    Amazon,
    GooglePlay,
    Nintendo,
}
impl fmt::Display for PromotionType {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{:?}", self)
    }
}

impl ToSql<crate::schema::sql_types::PromotionType, Pg> for PromotionType {
    fn to_sql<'b>(&'b self, out: &mut Output<'b, '_, Pg>) -> serialize::Result {
        match *self {
            PromotionType::Apple => out.write_all(b"Apple")?,
            PromotionType::Amazon => out.write_all(b"Amazon")?,
            PromotionType::GooglePlay => out.write_all(b"GooglePlay")?,
            PromotionType::Nintendo => out.write_all(b"Nintendo")?,
        }
        Ok(IsNull::No)
    }
}

impl FromSql<crate::schema::sql_types::PromotionType, Pg> for PromotionType {
    fn from_sql(bytes: PgValue) -> deserialize::Result<Self> {
        match bytes.as_bytes() {
            b"Apple" => Ok(PromotionType::Apple),
            b"Amazon" => Ok(PromotionType::Amazon),
            b"GooglePlay" => Ok(PromotionType::GooglePlay),
            b"Nintendo" => Ok(PromotionType::Nintendo),
            _ => Err("Unrecognized enum variant".into()),
        }
    }
}

#[derive(Queryable, Selectable, Serialize, Debug, Deserialize, Clone)]
#[diesel(table_name = crate::schema::promotions)]
pub struct Promotion {
    pub id: String,
    pub promotion_type: PromotionType,
    pub promotion_code: String,
    pub promotion_value: i32,
    pub points_required: i32,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub exchanged_date: Option<NaiveDateTime>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub exchanged_by: Option<String>,
}

#[derive(Deserialize, Insertable)]
#[diesel(table_name = crate::schema::promotions)]
pub struct NewPromotion {
    pub id: String,
    pub promotion_type: PromotionType,
    pub promotion_code: String,

    #[serde(skip_serializing_if = "Option::is_none")]
    pub promotion_value: Option<i32>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub points_required: Option<i32>,

}

impl NewPromotion {
    pub fn new(r#type: PromotionType, code: String, promotion_value: Option<i32>, points_required: Option<i32>) -> Self {
        Self {
            id: r#type.to_string() + &code.clone(), // to avoid duplicate registration
            promotion_type: r#type,
            promotion_code: code,
            promotion_value, 
            points_required
        }
    }
}

#[derive(Deserialize, Serialize)]
pub struct PromotionCounts {
    pub apple: usize,
    pub amazon: usize,
    pub google_play: usize,
    pub nintendo: usize,
}
