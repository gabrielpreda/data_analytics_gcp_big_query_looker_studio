-- Row counts
SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM `cymbal_pets.customers`

UNION ALL

SELECT 'orders', COUNT(*)
FROM `cymbal_pets.orders`

UNION ALL

SELECT 'order_items', COUNT(*)
FROM `cymbal_pets.order_items`

UNION ALL

SELECT 'products', COUNT(*)
FROM `cymbal_pets.products`;

-- Missing customer data
SELECT
    COUNTIF(customer_id IS NULL) AS missing_customer_id,
    COUNTIF(first_name IS NULL) AS missing_first_name,
    COUNTIF(email IS NULL) AS missing_email
FROM `cymbal_pets.customers`;


-- Orphan order items
SELECT
    COUNT(*) AS orphan_order_items
FROM `cymbal_pets.order_items` oi
LEFT JOIN `cymbal_pets.orders` o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Orphan products
SELECT
    COUNT(*) AS orphan_products
FROM `cymbal_pets.order_items` oi
LEFT JOIN `cymbal_pets.products` p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

