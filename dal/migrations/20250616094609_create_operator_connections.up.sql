-- Add up migration script here
CREATE TABLE operator_connections (
    connection_id SERIAL PRIMARY KEY,
    operator_id INTEGER NOT NULL,
    connected_at TIMESTAMP NOT NULL,
    disconnected_at TIMESTAMP,
    duration_seconds INTEGER,
    status TEXT NOT NULL DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
); 