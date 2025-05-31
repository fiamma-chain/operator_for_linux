-- Add down migration script here
ALTER TABLE operator_pegout DROP COLUMN IF EXISTS fee_rate;
ALTER TABLE operator_pegout DROP COLUMN IF EXISTS operator_fee_amount;
ALTER TABLE operator_pegout DROP COLUMN IF EXISTS protocol_fee_amount;
ALTER TABLE operator_pegout DROP COLUMN IF EXISTS pay_amount;
