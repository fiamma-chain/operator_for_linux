-- Add pegin_id column to operator_kickoff table for precise UTXO tracking
ALTER TABLE operator_kickoff ADD COLUMN IF NOT EXISTS pegin_id INT; 