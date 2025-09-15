-- Add up migration script here
CREATE TABLE operator_sidechain_transactions (
    chain_id INT NOT NULL,
    tx_hash TEXT NOT NULL,
    lp_id INT NOT NULL,
    tx_type TEXT NOT NULL, -- e.g., 'burn'
    status TEXT NOT NULL, -- options: pending/success/failed
    data JSONB NOT NULL, -- pegin_id, operator_id, btc_address, amount, fee_rate

    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (chain_id, tx_hash)
);

CREATE INDEX idx_sidechain_tx_hash ON operator_sidechain_transactions (tx_hash);
CREATE INDEX idx_sidechain_chain_lp ON operator_sidechain_transactions (chain_id, lp_id);