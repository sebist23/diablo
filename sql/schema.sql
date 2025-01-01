-- sql/schema.sql

-- Create the users table if it doesn't exist
CREATE TABLE IF NOT EXISTS users (
    identifier VARCHAR(50) NOT NULL PRIMARY KEY,
    hours FLOAT DEFAULT 0
);

-- Ensure the hours column exists and is of the correct type
ALTER TABLE users
ADD COLUMN IF NOT EXISTS hours FLOAT DEFAULT 0;
