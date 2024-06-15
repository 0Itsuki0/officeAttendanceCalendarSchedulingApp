-- Your SQL goes here
CREATE TABLE users (
  id VARCHAR PRIMARY KEY,
  username VARCHAR NOT NULL, 
  password VARCHAR DEFAULT NULL,
  total_attendance INTEGER NOT NULL DEFAULT 0,
  points_remained INTEGER NOT NULL DEFAULT 0,
  points_used INTEGER NOT NULL DEFAULT 0
)
