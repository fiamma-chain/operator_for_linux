-- Add up migration script here
CREATE TABLE operator_challenges
(
    id INT NOT NULL,
    pegout_id INT NOT NULL,
    chain_id INT NOT NULL,
    bitcoin_tx_hash TEXT NOT NULL,
    sidechain_tx_hash TEXT NOT NULL,
    bitcoin_block_hash TEXT,
    bitcoin_block_height INT,
    constant_hash TEXT,
    chunk_index INT,

    status TEXT NOT NULL,

    public_inputs TEXT,
    proof TEXT,

    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    PRIMARY KEY (pegout_id)
);
CREATE INDEX idx_operator_challenges_id ON operator_challenges(id);
CREATE INDEX idx_operator_challenges_chain_id ON operator_challenges(chain_id);