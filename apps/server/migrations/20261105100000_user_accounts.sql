-- migrate:up
ALTER TABLE users ADD COLUMN login text UNIQUE;
ALTER TABLE users ADD COLUMN password_hash text;

-- migrate:down
ALTER TABLE users DROP COLUMN password_hash;
ALTER TABLE users DROP COLUMN login;
