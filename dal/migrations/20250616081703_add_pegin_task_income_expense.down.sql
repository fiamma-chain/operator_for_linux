-- Add down migration script here
ALTER TABLE operator_pegin_tasks DROP COLUMN IF EXISTS income;
ALTER TABLE operator_pegin_tasks DROP COLUMN IF EXISTS expense;