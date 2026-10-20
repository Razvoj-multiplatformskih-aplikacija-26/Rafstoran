-- migrate:up
CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE users (
  id text PRIMARY KEY,
  name text NOT NULL,
  role text NOT NULL CHECK (role IN ('guest', 'waiter', 'manager'))
);

CREATE TABLE opening_hours (
  weekday int PRIMARY KEY CHECK (weekday BETWEEN 1 AND 7),
  opens time NOT NULL,
  closes time NOT NULL
);

CREATE TABLE dining_tables (
  id text PRIMARY KEY,
  label text NOT NULL UNIQUE,
  capacity int NOT NULL CHECK (capacity > 0),
  area text NOT NULL
);

CREATE TABLE reservations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  guest_id text REFERENCES users (id),
  guest_name text,
  guest_phone text,
  table_id text NOT NULL REFERENCES dining_tables (id),
  starts_at timestamptz NOT NULL,
  ends_at timestamptz NOT NULL,
  party_size int NOT NULL,
  note text,
  status text NOT NULL CHECK (status IN ('pending', 'confirmed', 'cancelled', 'arrived', 'no_show')),
  status_by text REFERENCES users (id),
  status_at timestamptz,
  cancel_reason text,
  created_at timestamptz NOT NULL,
  entered_by text REFERENCES users (id),
  CONSTRAINT reservations_account_or_phone CHECK (
    (guest_id IS NOT NULL AND guest_name IS NULL AND guest_phone IS NULL)
    OR (guest_id IS NULL AND guest_name IS NOT NULL AND guest_phone IS NOT NULL)
  ),
  CONSTRAINT reservations_no_double_booking EXCLUDE USING gist (
    table_id WITH =,
    tstzrange(starts_at, ends_at) WITH &&
  ) WHERE (status IN ('pending', 'confirmed', 'arrived')),
  CONSTRAINT reservations_one_table_per_account EXCLUDE USING gist (
    guest_id WITH =,
    tstzrange(starts_at, ends_at) WITH &&
  ) WHERE (status IN ('pending', 'confirmed', 'arrived') AND guest_id IS NOT NULL),
  CONSTRAINT reservations_one_table_per_phone EXCLUDE USING gist (
    guest_phone WITH =,
    tstzrange(starts_at, ends_at) WITH &&
  ) WHERE (status IN ('pending', 'confirmed', 'arrived') AND guest_phone IS NOT NULL)
);

CREATE INDEX reservations_by_guest ON reservations (guest_id);
CREATE INDEX reservations_by_start ON reservations (starts_at);

-- migrate:down
DROP TABLE reservations;
DROP TABLE dining_tables;
DROP TABLE opening_hours;
DROP TABLE users;
