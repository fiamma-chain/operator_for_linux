-- Add up migration script here
ALTER TABLE operator_challenges
    DROP COLUMN bitcoin_tx_hash,
    DROP COLUMN bitcoin_block_hash,
    DROP COLUMN bitcoin_block_height,
    ADD COLUMN bitcoin_tx TEXT NOT NULL DEFAULT '',
    ADD COLUMN pegin_id INT NOT NULL DEFAULT 0;