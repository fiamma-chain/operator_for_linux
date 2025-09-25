-- Add down migration script here
DROP INDEX IF EXISTS idx_sidechain_tx_hash;
DROP INDEX IF EXISTS idx_sidechain_chain_lp;
DROP TABLE IF EXISTS sidechain_transactions;