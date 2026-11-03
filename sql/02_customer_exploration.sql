-- 1. Berapa kota dan pelanggan unik?
SELECT
    COUNT(DISTINCT customer_city) AS total_unique_cities,
    count(distinct  customer_unique_id) as total_unique_id 
FROM customers;

-- 2. Top 10 kota berdasarkan jumlah pelanggan
SELECT
    customer_city,
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM customers
GROUP BY customer_city
ORDER BY total_customers DESC
LIMIT 10;

-- 3. Top 5 state berdasarkan jumlah pelanggan
SELECT
    customer_state,
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM customers
GROUP BY customer_state
ORDER BY total_customers DESC
LIMIT 5;

-- 4. Berapa pelanggan yang punya lebih dari satu customer_id (pelanggan berulang)?
SELECT
    COUNT(*) AS total_customers
FROM (
    SELECT customer_unique_id
    FROM customers
    GROUP BY customer_unique_id
    HAVING COUNT(DISTINCT customer_id) > 1
) AS multiple_customers;