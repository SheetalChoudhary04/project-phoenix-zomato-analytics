-- ============================================================
-- PROJECT PHOENIX — ZOMATO ANALYTICS
-- SQL Analysis & Data Preparation
-- 
-- ============================================================
-- 1. DATABASE SETUP
-- ============================================================

CREATE DATABASE IF NOT EXISTS zomato_analytics;
USE zomato_analytics;

-- ============================================================
-- 2. RESTAURANT TABLE — INITIAL SCHEMA
-- ============================================================

CREATE TABLE restaurants (
    restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_name VARCHAR(255),
    online_order VARCHAR(10),
    rating DECIMAL(2,1),
    votes INT,
    location VARCHAR(100),
    restaurant_type VARCHAR(100),
    cuisines VARCHAR(500),
    approx_cost_for_two DECIMAL(10,2)
);

-- Inspect table structure
DESCRIBE restaurants;
SHOW CREATE TABLE restaurants;
SHOW COLUMNS FROM `zomato_analytics`.`restaurants`;

-- ============================================================
-- 3. RESTAURANT DATA — BASIC VALIDATION
-- ============================================================

SELECT COUNT(*) AS total_restaurants
FROM restaurants;

SELECT COUNT(*) AS total_rows
FROM restaurants;

SELECT MIN(restaurant_id) AS min_id,
       MAX(restaurant_id) AS max_id
FROM restaurants;

SELECT *
FROM restaurants
LIMIT 5;

SELECT
    restaurant_id,
    restaurant_name,
    online_order,
    rating,
    votes,
    location,
    restaurant_type,
    cuisines,
    approx_cost_for_two
FROM `zomato_analytics`.`restaurants`;

SELECT COUNT(*) AS records_with_missing_values
FROM restaurants
WHERE restaurant_name IS NULL
   OR online_order IS NULL
   OR rating IS NULL
   OR votes IS NULL
   OR location IS NULL
   OR restaurant_type IS NULL
   OR cuisines IS NULL
   OR approx_cost_for_two IS NULL;

SELECT COUNT(DISTINCT restaurant_id) AS unique_ids
FROM restaurants;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT restaurant_name) AS unique_restaurants,
    COUNT(*) - COUNT(restaurant_name) AS missing_names
FROM restaurants;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT
        CONCAT_WS('|',
            restaurant_name,
            online_order,
            rating,
            votes,
            location,
            restaurant_type,
            cuisines,
            approx_cost_for_two
        )
    ) AS unique_complete_records
FROM restaurants;

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(DISTINCT restaurant_id) AS duplicate_ids
FROM restaurants;

-- ============================================================
-- 4. RESTAURANT STAGING TABLE & DATA LOAD
-- ============================================================

CREATE TABLE restaurants_staging (
    restaurant_name VARCHAR(255),
    online_order VARCHAR(10),
    rating VARCHAR(20),
    votes VARCHAR(20),
    location VARCHAR(100),
    restaurant_type VARCHAR(100),
    cuisines VARCHAR(500),
    approx_cost_for_two VARCHAR(50)
);

SHOW COLUMNS FROM `zomato_analytics`.`restaurants_staging`;

-- Load the cleaned CSV into the staging table.
-- Update the local path if running on another machine.
LOAD DATA LOCAL INFILE
'C:/Users/SHEETAL/OneDrive/Desktop/Project Phoenix/data/cleaned/zomato_restaurants.csv'
INTO TABLE restaurants_staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    restaurant_name,
    online_order,
    rating,
    votes,
    location,
    restaurant_type,
    cuisines,
    approx_cost_for_two
);

SELECT COUNT(*) AS staging_rows
FROM restaurants_staging;

SELECT COUNT(*) AS total_rows
FROM restaurants_staging;

SELECT COUNT(*) AS rows_with_missing_values
FROM restaurants_staging
WHERE restaurant_name IS NULL
   OR online_order IS NULL
   OR rating IS NULL
   OR votes IS NULL
   OR location IS NULL
   OR restaurant_type IS NULL
   OR cuisines IS NULL
   OR approx_cost_for_two IS NULL;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT
        CONCAT_WS('|',
            restaurant_name,
            online_order,
            rating,
            votes,
            location,
            restaurant_type,
            cuisines,
            approx_cost_for_two
        )
    ) AS unique_records
FROM restaurants_staging;

SELECT COUNT(*) AS matching_rows
FROM restaurants_staging s
INNER JOIN restaurants r
    ON r.restaurant_name = s.restaurant_name
    AND r.online_order = s.online_order
    AND r.rating = CAST(s.rating AS DECIMAL(2,1))
    AND r.votes = CAST(s.votes AS UNSIGNED)
    AND r.location = s.location
    AND r.restaurant_type = s.restaurant_type
    AND r.cuisines = s.cuisines
    AND r.approx_cost_for_two = CAST(s.approx_cost_for_two AS DECIMAL(10,2));

-- Sample unmatched staging records, used during validation.
SELECT
    s.restaurant_name,
    s.online_order,
    s.rating,
    s.votes,
    s.location,
    s.restaurant_type,
    s.cuisines,
    s.approx_cost_for_two
FROM restaurants_staging s
LEFT JOIN restaurants r
    ON r.restaurant_name = s.restaurant_name
    AND r.online_order = s.online_order
    AND r.rating = CAST(s.rating AS DECIMAL(2,1))
    AND r.votes = CAST(s.votes AS UNSIGNED)
    AND r.location = s.location
    AND r.restaurant_type = s.restaurant_type
    AND r.cuisines = s.cuisines
    AND r.approx_cost_for_two = CAST(s.approx_cost_for_two AS DECIMAL(10,2))
WHERE r.restaurant_id IS NULL
LIMIT 20;

-- ============================================================
-- 5. CLEAN RESTAURANT TABLE
-- ============================================================

CREATE TABLE restaurants_clean (
    restaurant_id INT NOT NULL AUTO_INCREMENT,
    restaurant_name VARCHAR(255),
    online_order VARCHAR(10),
    rating DECIMAL(2,1),
    votes INT,
    location VARCHAR(100),
    restaurant_type VARCHAR(100),
    cuisines VARCHAR(500),
    approx_cost_for_two DECIMAL(10,2),
    PRIMARY KEY (restaurant_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

SHOW COLUMNS FROM `zomato_analytics`.`restaurants_clean`;

SELECT COUNT(*) AS rows_in_new_table
FROM restaurants_clean;

SELECT COUNT(*)
FROM restaurants_clean;

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(restaurant_name) AS missing_names
FROM restaurants_clean;

-- The table was refreshed during the project.
-- TRUNCATE TABLE restaurants_clean;

-- ============================================================
-- 6. RESTAURANT DATA QUALITY / PROFILE ANALYSIS
-- ============================================================

SELECT COUNT(*) AS total_restaurants
FROM restaurants_clean;

SELECT COUNT(DISTINCT location) AS total_locations
FROM restaurants_clean;

SELECT ROUND(AVG(rating), 2) AS avg_rating
FROM restaurants_clean;

-- Historical exploratory attempt; retained here as documentation.
-- This failed because restaurants_clean uses approx_cost_for_two.
-- SELECT ROUND(AVG(average_cost), 2) AS avg_cost_for_two FROM restaurants_clean;

SELECT ROUND(AVG(approx_cost_for_two), 2) AS avg_cost_for_two
FROM restaurants_clean;

SELECT
    online_order,
    COUNT(*) AS restaurant_count,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM restaurants_clean),
        2
    ) AS percentage
FROM restaurants_clean
GROUP BY online_order;

SELECT
    location,
    COUNT(*) AS restaurant_count
FROM restaurants_clean
GROUP BY location
ORDER BY restaurant_count DESC;

SELECT
    location,
    COUNT(*) AS total_restaurants,
    SUM(CASE WHEN online_order = 'Yes' THEN 1 ELSE 0 END) AS online_order_restaurants,
    ROUND(
        SUM(CASE WHEN online_order = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS online_order_percentage
FROM restaurants_clean
GROUP BY location
ORDER BY online_order_percentage DESC;

SELECT
    restaurant_type,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(approx_cost_for_two), 2) AS avg_cost,
    ROUND(
        SUM(CASE WHEN online_order = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS online_order_percentage
FROM restaurants_clean
GROUP BY restaurant_type
ORDER BY restaurant_count DESC;

SELECT
    restaurant_type,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(approx_cost_for_two), 2) AS avg_cost,
    ROUND(
        SUM(CASE WHEN online_order = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS online_order_percentage
FROM restaurants_clean
GROUP BY restaurant_type
HAVING COUNT(*) >= 500
ORDER BY online_order_percentage DESC;

SELECT
    CASE
        WHEN approx_cost_for_two < 300 THEN 'Under 300'
        WHEN approx_cost_for_two < 600 THEN '300-599'
        WHEN approx_cost_for_two < 1000 THEN '600-999'
        WHEN approx_cost_for_two < 1500 THEN '1000-1499'
        ELSE '1500+'
    END AS price_segment,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(
        SUM(CASE WHEN online_order = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS online_order_percentage
FROM restaurants_clean
GROUP BY price_segment
ORDER BY
    CASE price_segment
        WHEN 'Under 300' THEN 1
        WHEN '300-599' THEN 2
        WHEN '600-999' THEN 3
        WHEN '1000-1499' THEN 4
        ELSE 5
    END;

SELECT
    CASE
        WHEN rating < 3 THEN 'Below 3'
        WHEN rating < 3.5 THEN '3.0-3.49'
        WHEN rating < 4 THEN '3.5-3.99'
        WHEN rating < 4.5 THEN '4.0-4.49'
        ELSE '4.5+'
    END AS rating_segment,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(votes), 0) AS avg_votes,
    ROUND(AVG(approx_cost_for_two), 2) AS avg_cost
FROM restaurants_clean
GROUP BY rating_segment
ORDER BY
    CASE rating_segment
        WHEN 'Below 3' THEN 1
        WHEN '3.0-3.49' THEN 2
        WHEN '3.5-3.99' THEN 3
        WHEN '4.0-4.49' THEN 4
        ELSE 5
    END;

-- ============================================================
-- 7. RESTAURANT LOOKUP / BENCHMARKING QUERIES
-- ============================================================

SELECT
    restaurant_id,
    restaurant_name,
    location,
    rating,
    votes,
    approx_cost_for_two
FROM restaurants
WHERE restaurant_name LIKE '%Cafe Down The Alley%';

SELECT
    TABLE_NAME,
    TABLE_COLLATION
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'zomato_analytics'
  AND TABLE_NAME = 'restaurants';

SELECT
    COLUMN_NAME,
    CHARACTER_SET_NAME,
    COLLATION_NAME
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'zomato_analytics'
  AND TABLE_NAME = 'restaurants'
  AND CHARACTER_SET_NAME IS NOT NULL;

-- ============================================================
-- 8. CUSTOMER TABLE
-- ============================================================

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    signup_date DATE NOT NULL,
    location VARCHAR(100),
    acquisition_channel VARCHAR(50)
);

DESCRIBE customers;
SHOW COLUMNS FROM `zomato_analytics`.`customers`;

SELECT COUNT(*)
FROM customers;

-- ============================================================
-- 9. SESSIONS TABLE
-- ============================================================

CREATE TABLE sessions (
    session_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    session_date DATE NOT NULL,
    restaurant_viewed TINYINT,
    added_to_cart TINYINT,
    checkout_started TINYINT,
    converted TINYINT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

SHOW COLUMNS FROM `zomato_analytics`.`sessions`;
DESCRIBE sessions;

SELECT COUNT(*)
FROM sessions;

SELECT COUNT(*) AS session_count
FROM sessions;

-- ============================================================
-- 10. ORDERS TABLE
-- ============================================================

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    session_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_value DECIMAL(10,2),
    delivery_time INT,
    rating DECIMAL(2,1),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (session_id) REFERENCES sessions(session_id)
);

SHOW COLUMNS FROM `zomato_analytics`.`orders`;

SELECT COUNT(*)
FROM orders;

-- ============================================================
-- 11. DATASET SIZE CHECKS
-- ============================================================

SELECT COUNT(*)
FROM restaurants;

SELECT COUNT(*)
FROM restaurants_clean;

SELECT COUNT(*)
FROM customers;

SELECT COUNT(*)
FROM sessions;

SELECT COUNT(*)
FROM orders;

-- ============================================================
-- 12. SESSION FUNNEL ANALYSIS
-- ============================================================

SELECT
    COUNT(*) AS total_sessions,
    SUM(restaurant_viewed) AS restaurant_views,
    SUM(added_to_cart) AS carts,
    SUM(checkout_started) AS checkouts,
    SUM(converted) AS orders
FROM sessions;

SELECT
    COUNT(*) AS total_sessions,
    SUM(restaurant_viewed) AS restaurant_views,
    SUM(added_to_cart) AS carts,
    SUM(checkout_started) AS checkouts,
    SUM(converted) AS orders,
    ROUND(SUM(restaurant_viewed) / COUNT(*) * 100, 2) AS session_to_view_pct,
    ROUND(SUM(added_to_cart) / SUM(restaurant_viewed) * 100, 2) AS view_to_cart_pct,
    ROUND(SUM(checkout_started) / SUM(added_to_cart) * 100, 2) AS cart_to_checkout_pct,
    ROUND(SUM(converted) / SUM(checkout_started) * 100, 2) AS checkout_to_order_pct,
    ROUND(SUM(converted) / COUNT(*) * 100, 2) AS overall_conversion_pct
FROM sessions;

-- ============================================================
-- 13. ONLINE ORDER / CART BEHAVIOUR
-- ============================================================

SELECT
    r.online_order,
    COUNT(*) AS sessions,
    SUM(s.added_to_cart) AS carts,
    ROUND(
        SUM(s.added_to_cart) / COUNT(*) * 100,
        2
    ) AS cart_conversion_pct
FROM sessions s
JOIN restaurants r
    ON s.restaurant_id = r.restaurant_id
GROUP BY r.online_order;

-- ============================================================
-- 14. ACQUISITION CHANNEL PERFORMANCE
-- ============================================================

SELECT
    c.acquisition_channel,
    COUNT(*) AS sessions,
    SUM(s.converted) AS orders,
    ROUND(
        SUM(s.converted) / COUNT(*) * 100,
        2
    ) AS conversion_rate_pct
FROM sessions s
JOIN customers c
    ON s.customer_id = c.customer_id
GROUP BY c.acquisition_channel
ORDER BY conversion_rate_pct DESC;

-- ============================================================
-- 15. CUSTOMER ORDER BEHAVIOUR
-- ============================================================

SELECT
    COUNT(DISTINCT customer_id) AS customers_with_orders,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) / COUNT(DISTINCT customer_id),
        2
    ) AS orders_per_customer
FROM orders;

SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS customers,
    ROUND(AVG(avg_order_value), 2) AS avg_order_value,
    ROUND(AVG(avg_delivery_time), 2) AS avg_delivery_time,
    ROUND(AVG(avg_rating), 2) AS avg_rating
FROM (
    SELECT
        customer_id,
        COUNT(*) AS order_count,
        AVG(order_value) AS avg_order_value,
        AVG(delivery_time) AS avg_delivery_time,
        AVG(rating) AS avg_rating
    FROM orders
    GROUP BY customer_id
) customer_summary
GROUP BY customer_type;

SELECT
    c.acquisition_channel,
    COUNT(DISTINCT o.customer_id) AS customers,
    COUNT(DISTINCT CASE
        WHEN customer_order_count.order_count > 1
        THEN o.customer_id
    END) AS repeat_customers,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN customer_order_count.order_count > 1
            THEN o.customer_id
        END)
        / COUNT(DISTINCT o.customer_id) * 100,
        2
    ) AS repeat_rate_pct
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN (
    SELECT
        customer_id,
        COUNT(*) AS order_count
    FROM orders
    GROUP BY customer_id
) customer_order_count
    ON o.customer_id = customer_order_count.customer_id
GROUP BY c.acquisition_channel
ORDER BY repeat_rate_pct DESC;

SELECT
    CASE
        WHEN s.checkout_started = 1 THEN 'Checkout Started'
        ELSE 'No Checkout'
    END AS funnel_behavior,
    COUNT(DISTINCT s.customer_id) AS customers,
    COUNT(DISTINCT CASE
        WHEN customer_order_count.order_count > 1
        THEN s.customer_id
    END) AS repeat_customers,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN customer_order_count.order_count > 1
            THEN s.customer_id
        END)
        / COUNT(DISTINCT s.customer_id) * 100,
        2
    ) AS repeat_rate_pct
FROM sessions s
JOIN (
    SELECT
        customer_id,
        COUNT(*) AS order_count
    FROM orders
    GROUP BY customer_id
) customer_order_count
    ON s.customer_id = customer_order_count.customer_id
GROUP BY funnel_behavior;

-- ============================================================
-- 16. FINAL RESTAURANT MARKETPLACE ANALYSIS
-- ============================================================

SELECT
    COUNT(*) AS total_restaurants,
    COUNT(DISTINCT location) AS total_locations,
    COUNT(DISTINCT cuisines) AS total_cuisines,
    COUNT(DISTINCT restaurant_type) AS total_restaurant_types,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(approx_cost_for_two), 2) AS avg_cost_for_two,
    ROUND(
        SUM(CASE WHEN online_order = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*) * 100,
        2
    ) AS online_order_adoption_pct
FROM restaurants;

SELECT
    COUNT(*) AS total_restaurants,
    COUNT(DISTINCT location) AS total_locations,
    COUNT(DISTINCT cuisines) AS total_cuisines,
    COUNT(DISTINCT restaurant_type) AS total_restaurant_types,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(approx_cost_for_two), 2) AS avg_cost_for_two,
    ROUND(
        SUM(CASE WHEN online_order = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*) * 100,
        2
    ) AS online_order_adoption_pct
FROM restaurants_clean;

SELECT
    location,
    COUNT(*) AS restaurant_count,
    SUM(CASE WHEN online_order = 'Yes' THEN 1 ELSE 0 END) AS online_order_restaurants,
    ROUND(
        SUM(CASE WHEN online_order = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*) * 100,
        2
    ) AS online_order_adoption_pct
FROM restaurants_clean
GROUP BY location
HAVING COUNT(*) >= 100
ORDER BY online_order_adoption_pct DESC;

SELECT
    restaurant_type,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(approx_cost_for_two), 2) AS avg_cost_for_two,
    ROUND(AVG(rating), 2) AS avg_rating,
    SUM(CASE WHEN online_order = 'Yes' THEN 1 ELSE 0 END) AS online_order_restaurants,
    ROUND(
        SUM(CASE WHEN online_order = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*) * 100,
        2
    ) AS online_order_adoption_pct
FROM restaurants_clean
GROUP BY restaurant_type
HAVING COUNT(*) >= 100
ORDER BY restaurant_count DESC;

SELECT
    CASE
        WHEN approx_cost_for_two < 300 THEN 'Under 300'
        WHEN approx_cost_for_two < 600 THEN '300-599'
        WHEN approx_cost_for_two < 1000 THEN '600-999'
        WHEN approx_cost_for_two < 1500 THEN '1000-1499'
        ELSE '1500+'
    END AS cost_bucket,
    COUNT(*) AS restaurant_count,
    ROUND(
        COUNT(*) / (SELECT COUNT(*) FROM restaurants_clean) * 100,
        2
    ) AS marketplace_share_pct,
    ROUND(AVG(rating), 2) AS avg_rating
FROM restaurants_clean
GROUP BY cost_bucket
ORDER BY
    CASE cost_bucket
        WHEN 'Under 300' THEN 1
        WHEN '300-599' THEN 2
        WHEN '600-999' THEN 3
        WHEN '1000-1499' THEN 4
        WHEN '1500+' THEN 5
    END;

SELECT
    location,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(approx_cost_for_two), 2) AS avg_cost_for_two,
    ROUND(AVG(rating), 2) AS avg_rating
FROM restaurants_clean
GROUP BY location
HAVING COUNT(*) >= 100
ORDER BY avg_cost_for_two DESC
LIMIT 15;

SELECT
    restaurant_name,
    location,
    votes,
    rating,
    approx_cost_for_two
FROM restaurants_clean
WHERE votes IS NOT NULL
ORDER BY votes DESC
LIMIT 15;

SELECT
    restaurant_name,
    location,
    MAX(votes) AS votes,
    MAX(rating) AS rating,
    MAX(approx_cost_for_two) AS approx_cost_for_two
FROM restaurants_clean
WHERE votes IS NOT NULL
GROUP BY restaurant_name, location
ORDER BY votes DESC
LIMIT 15;

SELECT
    CASE
        WHEN votes < 100 THEN 'Under 100'
        WHEN votes < 500 THEN '100-499'
        WHEN votes < 1000 THEN '500-999'
        WHEN votes < 5000 THEN '1,000-4,999'
        ELSE '5,000+'
    END AS popularity_bucket,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(votes), 0) AS avg_votes
FROM (
    SELECT
        restaurant_name,
        location,
        MAX(votes) AS votes,
        MAX(rating) AS rating
    FROM restaurants_clean
    WHERE votes IS NOT NULL
    GROUP BY restaurant_name, location
) r
GROUP BY popularity_bucket
ORDER BY
    CASE popularity_bucket
        WHEN 'Under 100' THEN 1
        WHEN '100-499' THEN 2
        WHEN '500-999' THEN 3
        WHEN '1,000-4,999' THEN 4
        WHEN '5,000+' THEN 5
    END;

-- ============================================================
-- 17. OPTIONAL CLEANUP COMMANDS USED DURING DEVELOPMENT
-- ============================================================
-- These are destructive. Run only when intentionally rebuilding.
-- TRUNCATE TABLE restaurants;
-- TRUNCATE TABLE `zomato_analytics`.`restaurants_clean`;
-- DROP TABLE `zomato_analytics`.`restaurants_staging`;
-- DROP TABLE `zomato_analytics`.`restaurants`;

-- ============================================================
-- END OF PROJECT PHOENIX SQL ANALYSIS
-- ============================================================
