CREATE TABLE customers (
    customer_id VARCHAR(32) PRIMARY KEY,
    customer_unique_id VARCHAR(32),
    customer_zip_code_prefix VARCHAR(5),
    customer_city VARCHAR(100),
    customer_state VARCHAR(2)
);