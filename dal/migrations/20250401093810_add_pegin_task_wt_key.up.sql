-- Add up migration script here
ALTER TABLE operator_pegin_tasks ADD COLUMN wt_keys TEXT NOT NULL;
