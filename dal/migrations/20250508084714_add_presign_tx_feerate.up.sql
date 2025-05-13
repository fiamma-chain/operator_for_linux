-- Add up migration script here
ALTER TABLE operator_pegout ADD COLUMN presign_tx_feerate INTEGER NOT NULL DEFAULT 1;