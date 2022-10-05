DROP TABLE IF EXISTS certificates;
CREATE TABLE certificates (
  id SERIAL PRIMARY KEY,
  status VARCHAR,
  date_from TIMESTAMP,
  date_to TIMESTAMP,
  revoke_pwd VARCHAR,
  info_pwd VARCHAR,
  serial_num BYTEA,
  req_id BYTEA,
  cert BYTEA
);
