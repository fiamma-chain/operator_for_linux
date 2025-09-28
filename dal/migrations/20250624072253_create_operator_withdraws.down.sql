-- Add down migration script here
DROP TRIGGER IF EXISTS trigger_set_updated_at ON operator_withdraws;
DROP FUNCTION IF EXISTS set_updated_at_timestamp;

DROP INDEX IF EXISTS idx_withdraws_sidechain_id;
DROP INDEX IF EXISTS idx_withdraws_status;
DROP INDEX IF EXISTS idx_withdraws_user_btc_address;
DROP INDEX IF EXISTS idx_withdraws_created_at;

DROP TABLE IF EXISTS withdraws;