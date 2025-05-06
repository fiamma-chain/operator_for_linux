-- Add up migration script here
CREATE TABLE IF NOT EXISTS stake_unstake_transactions (
    operator_address TEXT NOT NULL,
    stake_id TEXT NOT NULL,
    stake_hex TEXT NOT NULL,
    unstake_hex TEXT,
    stake_at TIMESTAMP NOT NULL,
    unstake_at TIMESTAMP NOT NULL,
    PRIMARY KEY (operator_address, stake_id)
);