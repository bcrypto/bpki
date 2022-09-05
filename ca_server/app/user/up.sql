CREATE TABLE "certificates" (
  id SERIAL PRIMARY KEY,
  req_id VARCHAR UNIQUE,
  info_pwd VARCHAR,
  e_pwd VARCHAR,
  cert BYTEA
);
