-- Add up migration script here
CREATE TABLE operator_winternitz
(
    operator_address TEXT NOT NULL,
    nonce BIGINT NOT NULL,
    sign_type TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    PRIMARY KEY (operator_address, nonce)
);
