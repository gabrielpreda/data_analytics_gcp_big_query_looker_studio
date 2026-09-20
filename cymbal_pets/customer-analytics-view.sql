-- Create a customer analytics view
CREATE OR REPLACE VIEW `cymbal_pets.customer_analytics_vw` AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    c.gender,
    c.address_city,
    c.address_state,
    c.loyalty_member,

    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS total_items,
    SUM(oi.quantity * oi.price) AS total_revenue,

    ROUND(
        SAFE_DIVIDE(SUM(oi.quantity * oi.price), COUNT(DISTINCT o.order_id)),
        2
    ) AS avg_order_value,

    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date

FROM `cymbal_pets.customers` c
LEFT JOIN `cymbal_pets.orders` o
    ON c.customer_id = o.customer_id
LEFT JOIN `cymbal_pets.order_items` oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_id,
    customer_name,
    c.email,
    c.gender,
    c.address_city,
    c.address_state,
    c.loyalty_member;