-- Add down migration script here
DROP TABLE IF EXISTS operator_challenges;
DROP INDEX IF EXISTS idx_operator_challenges_chain_id;