-- Create a product analytics view
CREATE OR REPLACE VIEW `cymbal_pets.product_analytics_vw` AS
SELECT
    p.product_id,
    p.product_name,
    p.brand,
    p.category,
    p.subcategory,
    p.animal_type,

    -- Product attributes
    p.price AS catalog_price,
    p.inventory_level,
    p.average_rating,

    -- Sales metrics
    COUNT(DISTINCT oi.order_id) AS total_orders,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.price) AS total_revenue,

    ROUND(
        SAFE_DIVIDE(
            SUM(oi.quantity * oi.price),
            NULLIF(SUM(oi.quantity), 0)
        ),
        2
    ) AS avg_selling_price

FROM `cymbal_pets.products` p
LEFT JOIN `cymbal_pets.order_items` oi
    ON p.product_id = oi.product_id

GROUP BY
    p.product_id,
    p.product_name,
    p.brand,
    p.category,
    p.subcategory,
    p.animal_type,
    p.price,
    p.inventory_level,
    p.average_rating;