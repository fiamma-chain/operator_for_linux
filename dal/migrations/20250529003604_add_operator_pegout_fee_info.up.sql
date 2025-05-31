-- Add up migration script here
ALTER TABLE operator_pegout ADD COLUMN pay_amount BIGINT;
ALTER TABLE operator_pegout ADD COLUMN protocol_fee_amount BIGINT;
ALTER TABLE operator_pegout ADD COLUMN operator_fee_amount BIGINT;
ALTER TABLE operator_pegout ADD COLUMN fee_rate INTEGER;
