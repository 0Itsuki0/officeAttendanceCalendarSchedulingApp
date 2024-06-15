-- Your SQL goes here

CREATE TYPE Location AS ENUM (
    'Nagoya', 'Tokyo', 'Nagaoka'
);

CREATE TYPE Status AS ENUM (
    'Went', 'Absence', 'Going'
);


CREATE TABLE events (
  id VARCHAR PRIMARY KEY,
  location Location NOT NULL,
  status Status NOT NULL DEFAULT 'Going',
  timestamp TIMESTAMP NOT NULL,
  user_id VARCHAR NOT NULL REFERENCES users(id)
)