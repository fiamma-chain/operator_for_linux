-- Add down migration script here
ALTER TABLE operator_challenges
    ADD COLUMN bitcoin_tx_hash TEXT NOT NULL DEFAULT '',
    ADD COLUMN bitcoin_block_hash TEXT NOT NULL DEFAULT '',
    ADD COLUMN bitcoin_block_height INT NOT NULL DEFAULT 0,
    DROP COLUMN bitcoin_tx,
    DROP COLUMN pegin_id;