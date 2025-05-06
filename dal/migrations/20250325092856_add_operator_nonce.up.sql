-- Add up migration script here
CREATE TABLE operator_nonce
(
    operator_address TEXT NOT NULL PRIMARY KEY,
    nonce BIGINT NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);
