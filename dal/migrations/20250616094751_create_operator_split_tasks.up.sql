-- Add up migration script here
CREATE TABLE operator_split_tasks
(
    split_id SERIAL PRIMARY KEY,
    operator_id INT NOT NULL,
    status TEXT NOT NULL,
    target_amount BIGINT NOT NULL,
    gas_fee BIGINT NOT NULL,
    split_tx_hash TEXT,
    input_amount BIGINT NOT NULL,
    output_count INT NOT NULL,
    change_amount BIGINT,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
); 