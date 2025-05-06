-- Add up migration script here
CREATE TABLE operator_pegout
(
    chain_id INT NOT NULL,
    operator_id INT NOT NULL,
    pegout_id INT NOT NULL,
    pegin_id INT NOT NULL,
    burn_tx_hash TEXT NOT NULL,
    burn_tx_log_index INT NOT NULL DEFAULT 0,
    amount BIGINT NOT NULL,
    bitcoin_tx_hash TEXT,
    bitcoin_tx TEXT,
    bitcoin_block_hash TEXT,
    merkle_path TEXT,
    public_inputs TEXT,
    proof TEXT,
    split_witness TEXT,
    tx_index INT,
    status TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    PRIMARY KEY (chain_id, operator_id, pegout_id)
);

CREATE INDEX idx_operator_pegout_pegout_id ON operator_pegout(pegout_id);
CREATE INDEX idx_operator_pegout_status ON operator_pegout(status);

CREATE TABLE operator_kickoff
(
    pre_tx_id TEXT NOT NULL,
    pre_tx_vout INT NOT NULL,
    operator_address TEXT NOT NULL,
    status TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    PRIMARY KEY (pre_tx_id, pre_tx_vout)
);

CREATE TABLE operator_pegin_tasks
(
    pegin_id INT NOT NULL,
    operator_id INT NOT NULL,
    status TEXT NOT NULL,
    amount BIGINT NOT NULL,
    pegin_tx TEXT NOT NULL,
    raw_take_tx TEXT NOT NULL,
    taproot_address TEXT NOT NULL,
    committees_script TEXT NOT NULL,
    committees_pubkey TEXT NOT NULL,
    pegin_id_nonce BIGINT,
    amount_nonce BIGINT,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    PRIMARY KEY (pegin_id, operator_id)
);