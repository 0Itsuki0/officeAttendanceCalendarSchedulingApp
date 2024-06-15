-- Your SQL goes here

CREATE TYPE PROMOTION_TYPE AS ENUM (
    'Apple', 'Amazon', 'GooglePlay', 'Nintendo'
);


CREATE TABLE promotions (
    id VARCHAR PRIMARY KEY,
    promotion_type PROMOTION_TYPE NOT NULL,
    promotion_code VARCHAR NOT NULL,
    promotion_value INTEGER NOT NULL DEFAULT 500,
    points_required INTEGER NOT NULL DEFAULT 50,
    exchanged_date TIMESTAMP DEFAULT NULL,
    exchanged_by VARCHAR DEFAULT NULL REFERENCES users(id)
)