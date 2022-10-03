CREATE TABLE "certificates" (
  id SERIAL PRIMARY KEY,
  revoke_pwd VARCHAR,
  info_pwd VARCHAR,
  serial_num BYTEA,
  req_id BYTEA,
  cert BYTEA
);
