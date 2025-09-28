-- Add up migration script here
CREATE TABLE operator_withdraws (
    id                       SERIAL PRIMARY KEY,
    lp_id                    INT NOT NULL,
    task_id                  INT NOT NULL UNIQUE,
    withdraw_id              INT NOT NULL UNIQUE,
    withdraw_txid            TEXT NOT NULL,
    log_index                INT NOT NULL,

    sidechain_id             INT NOT NULL,

    withdraw_amount          BIGINT NOT NULL CHECK (withdraw_amount > 0),    -- Amount in satoshi
    fee_rate                 INT NOT NULL CHECK ( fee_rate > 0),       -- Fee rate in sat/vByte

    user_sidechain_address   TEXT NOT NULL,
    lp_sidechain_address     TEXT,
    user_btc_address         TEXT NOT NULL,

    status                   TEXT NOT NULL,
    failure_reason           TEXT,
    btc_tx_id                TEXT UNIQUE,
    btc_tx_raw_hex           TEXT,
    unlock_tx_id             TEXT,

    created_at               TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at               TIMESTAMP NOT NULL DEFAULT NOW(),
    btc_tx_submitted_at      TIMESTAMP,
    btc_tx_confirmed_at      TIMESTAMP,

    UNIQUE (sidechain_id, withdraw_txid, log_index)
);

-- Add indexes
CREATE INDEX idx_withdraws_sidechain_id ON operator_withdraws (sidechain_id);
CREATE INDEX idx_withdraws_status ON operator_withdraws (status);
CREATE INDEX idx_withdraws_user_btc_address ON operator_withdraws (user_btc_address);
CREATE INDEX idx_withdraws_created_at ON operator_withdraws (created_at);


CREATE OR REPLACE FUNCTION set_updated_at_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_set_updated_at ON operator_withdraws;
CREATE TRIGGER trigger_set_updated_at
BEFORE UPDATE ON operator_withdraws
FOR EACH ROW
EXECUTE FUNCTION set_updated_at_timestamp();