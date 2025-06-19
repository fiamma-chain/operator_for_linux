-- Add up migration script here
ALTER TABLE operator_pegin_tasks ADD COLUMN income BIGINT; 
ALTER TABLE operator_pegin_tasks ADD COLUMN expense BIGINT; 
