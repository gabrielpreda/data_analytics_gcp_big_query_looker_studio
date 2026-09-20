--- Top customers
SELECT
    customer_id,
    customer_name,
    total_orders,
    total_revenue
FROM `cymbal_pets.customer_analytics_vw`
ORDER BY total_revenue DESC
LIMIT 10;

-- Top products (by revenue)
SELECT
    product_name,
    brand,
    category,
    units_sold,
    total_revenue
FROM `cymbal_pets.product_analytics_vw`
ORDER BY total_revenue DESC
LIMIT 10;

-- Revenue by state
SELECT
    address_state,
    SUM(total_revenue) AS revenue
FROM `cymbal_pets.customer_analytics_vw`
GROUP BY address_state
ORDER BY revenue DESC;