-- 1. PRODUCTS
-- What categories of tech products does Magist have?
-- Check list of all product categories
SELECT product_category_name_english
FROM product_category_name_translation;

-- Created list of categories considered as "tech_categories": 
-- ("electronics", "computers", "computers_accessories", "audio", "pc_gamer", "consoles_games", "cine_photo")

SELECT product_category_name_english AS tech_categories
FROM product_category_name_translation
WHERE product_category_name_english 
	IN (
    "electronics", 
    "computers", 
    "computers_accessories", 
    "audio", 
    "pc_gamer", 
    "consoles_games", 
    "cine_photo");
    
-- 1. How many products of these tech categories have been sold (within the time window of the database snapshot)? 
SELECT 
	product_category_name_english AS product_category,
    COUNT(order_items.order_id) AS sales
FROM orders
JOIN order_items 
	ON orders.order_id = order_items.order_id
JOIN products
	ON order_items.product_id = products.product_id
JOIN product_category_name_translation as transl
	ON products.product_category_name = transl.product_category_name
WHERE product_category_name_english 
	IN (
    "electronics", 
    "computers", 
    "computers_accessories", 
    "audio", 
    "pc_gamer", 
    "consoles_games", 
    "cine_photo")
GROUP BY product_category_name_english
ORDER BY sales DESC;

-- 2. What percentage does that represent from the overall number of products sold?

SELECT 
    COUNT(order_items.order_id) AS tech_products_sold,
    total_products_sold,
    ROUND(((COUNT(*)) / total_products_sold) *100, 2) AS percentage_of_total
FROM 
	(
    SELECT
		COUNT(order_id) AS total_products_sold
	FROM order_items
    ) AS total_products_sold,
    orders
JOIN order_items 
	ON orders.order_id = order_items.order_id
JOIN products
	ON order_items.product_id = products.product_id
JOIN product_category_name_translation AS transl
	ON products.product_category_name = transl.product_category_name
WHERE product_category_name_english 
	IN (
    "electronics", 
    "computers", 
    "computers_accessories", 
    "audio", 
    "pc_gamer", 
    "consoles_games", 
    "cine_photo");

-- What’s the average price of the products being sold?
SELECT 
	ROUND(AVG(order_items.price), 2) as average_price_tech,
    average_price_all
FROM 
	(SELECT ROUND(AVG(order_items.price), 2) as average_price_all
    FROM order_items) AS average_price_all,
	orders
JOIN order_items 
	ON orders.order_id = order_items.order_id
JOIN products
	ON order_items.product_id = products.product_id
JOIN product_category_name_translation as transl
	ON products.product_category_name = transl.product_category_name
WHERE product_category_name_english 
	IN (
    "electronics", 
    "computers", 
    "computers_accessories", 
    "audio", 
    "pc_gamer", 
    "consoles_games", 
    "cine_photo");

-- Are expensive tech products popular? *
-- Get descriptive stats regarding the prices of items in the catalog.
SELECT 
	AVG(price) AS mean,
    STD(price) AS std,
    MIN(price) AS min, 
    MAX(price) AS max
FROM 
	(
    SELECT 
		DISTINCT(product_id),
        price
	FROM order_items) AS distinct_products;

-- Categorize prices in three categories and show corresponding sales together with average review scores.
SELECT 
    CASE
        WHEN price BETWEEN 100 AND 200 THEN 'moderate'
        WHEN price > 200 THEN 'expensive'
        ELSE 'cheap'
    END AS price_category,
    COUNT(order_items.order_id) AS nr_sold,
    AVG(order_reviews.review_score) AS average_review_score
FROM
    orders
JOIN order_items 
	ON orders.order_id = order_items.order_id
JOIN order_reviews 
	ON order_items.order_id = order_reviews.order_id
JOIN products 
	ON order_items.product_id = products.product_id
JOIN product_category_name_translation AS transl 
	ON products.product_category_name = transl.product_category_name
WHERE
    product_category_name_english IN (
		"electronics", 
		"computers", 
		"computers_accessories", 
		"audio", 
		"pc_gamer", 
		"consoles_games", 
		"cine_photo")
GROUP BY price_category
ORDER BY nr_sold DESC;

-- 2. SELLERS
-- How many months of data are included in the magist database?
SELECT 
    TIMESTAMPDIFF(month, MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)) as number_months 
FROM 
	orders;    

-- How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers?
SELECT 
	total_sellers,
    COUNT(DISTINCT s.seller_id) AS tech_sellers,
    ROUND((COUNT(DISTINCT s.seller_id) / total_sellers) * 100, 2) AS "tech_sellers %"
FROM 
(SELECT 
	COUNT(DISTINCT seller_id) AS total_sellers
FROM sellers) AS total_sellers,
	sellers AS s
JOIN 
	order_items AS oi ON s.seller_id = oi.seller_id
JOIN
	products AS p ON oi.product_id = p.product_id
JOIN
	product_category_name_translation AS transl ON p.product_category_name = transl.product_category_name
WHERE
    transl.product_category_name_english IN (
		"electronics", 
		"computers", 
		"computers_accessories", 
		"audio", 
		"pc_gamer", 
		"consoles_games", 
		"cine_photo");     

-- What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers?
-- Total revenue when looking at order payment values.
SELECT
	ROUND(SUM(op.payment_value), 2) AS total_revenue
FROM 
	order_payments as op 
JOIN orders as o 
	ON o.order_id = op.order_id
WHERE 
		o.order_status NOT IN (
		"unavailable",
		"canceled");

-- Total revenue when adding prices of sold items values.
SELECT
	ROUND(SUM(oi.price), 2) AS total_revenue
FROM 
	order_items as oi
JOIN
    orders as o ON o.order_id = oi.order_id
WHERE 
		o.order_status NOT IN (
		"unavailable",
		"canceled");

-- Added tech revenue and percentage
SELECT 
	total_revenue,
    ROUND(SUM(oi.price), 2) AS tech_revenue,
    ROUND((ROUND(SUM(oi.price), 2) / total_revenue) * 100, 2) AS "tech_revenue %"
FROM 
	(
    SELECT
		ROUND(SUM(oi.price), 2) AS total_revenue
	FROM 
		order_items as oi
	JOIN orders as o 
		ON o.order_id = oi.order_id
	WHERE 
			o.order_status NOT IN (
			"unavailable",
			"canceled")
	) 
    AS total_revenue,
	order_items AS oi
JOIN orders AS o 
	ON o.order_id = oi.order_id
JOIN products AS p 
	ON p.product_id = oi.product_id
JOIN product_category_name_translation as transl 
	ON transl.product_category_name = p.product_category_name
WHERE
    transl.product_category_name_english IN (
		"electronics", 
		"computers", 
		"computers_accessories", 
		"audio", 
		"pc_gamer", 
		"consoles_games", 
		"cine_photo")     
AND
	o.order_status NOT IN (
    "unavailable",
    "canceled");    
    
-- Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers?

-- Revenue per month:
SELECT 
	YEAR(o.order_purchase_timestamp) AS year, 
    MONTH(o.order_purchase_timestamp) AS month,
    ROUND(SUM(oi.price), 2) AS monthly_revenue
FROM sellers AS s
JOIN order_items AS oi 
	ON s.seller_id = oi.seller_id
JOIN products AS p 
	ON oi.product_id = p.product_id
JOIN product_category_name_translation AS transl 
	ON p.product_category_name = transl.product_category_name
JOIN orders AS o 
	ON oi.order_id = o.order_id
WHERE
    transl.product_category_name_english IN (
		"electronics", 
		"computers", 
		"computers_accessories", 
		"audio", 
		"pc_gamer", 
		"consoles_games", 
		"cine_photo")
GROUP BY year, month
ORDER BY year ASC, month ASC;

-- Average monthly revenue all sellers:
SELECT ROUND(AVG(monthly_revenue), 2) AS average_monthly_revenue
FROM 
	(
	SELECT 
		SUM(oi.price) AS monthly_revenue
	FROM sellers AS s
	JOIN order_items AS oi 
		ON s.seller_id = oi.seller_id
	JOIN products AS p 
		ON oi.product_id = p.product_id
	JOIN product_category_name_translation AS transl 
		ON p.product_category_name = transl.product_category_name
	JOIN orders AS o 
		ON oi.order_id = o.order_id
	GROUP BY YEAR(o.order_purchase_timestamp), MONTH(o.order_purchase_timestamp)
	) as inner_query;

-- Average monthly revenue (only tech sellers):
SELECT ROUND(AVG(monthly_revenue), 2) AS average_monthly_revenue_tech
FROM
	(
	SELECT 
		SUM(oi.price) AS monthly_revenue
	FROM sellers AS s
	JOIN order_items AS oi 
		ON s.seller_id = oi.seller_id
	JOIN products AS p 
		ON oi.product_id = p.product_id
	JOIN product_category_name_translation AS transl 
		ON p.product_category_name = transl.product_category_name
	JOIN orders AS o 
		ON oi.order_id = o.order_id
	WHERE
		transl.product_category_name_english IN (
		"electronics", 
		"computers", 
		"computers_accessories", 
		"audio", 
		"pc_gamer", 
		"consoles_games", 
		"cine_photo")
	GROUP BY YEAR(o.order_purchase_timestamp), MONTH(o.order_purchase_timestamp)
	) AS inner_query;

-- 3. DELIVERY TIME
-- What’s the average time between the order being placed and the product being delivered?
SELECT 
	AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS average_delivery_duration_days
FROM orders;

-- How many orders are delivered on time vs orders delivered with a delay?
SELECT 
	COUNT(order_id) as number_of_orders,
    CASE 
		WHEN DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) < 0 THEN 'delayed'
		WHEN DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) >= 0 THEN 'on_time'
		ELSE 'unknown'
	END AS delivery
FROM orders
WHERE order_status = "delivered"
GROUP BY delivery;

-- Is there any pattern for delayed orders, e.g. big products being delayed more often?
SELECT 
    product_category_name_english,
    CASE 
		WHEN DATEDIFF(o.order_estimated_delivery_date, o.order_delivered_customer_date) < 0 THEN 'delayed'
		WHEN DATEDIFF(o.order_estimated_delivery_date, o.order_delivered_customer_date) >= 0 THEN 'on_time'
		ELSE 'unknown'
	END AS delivery,
    CASE
		WHEN p.product_weight_g > avg_weight OR p.product_length_cm > avg_length OR p.product_height_cm > avg_height OR p.product_width_cm > avg_width THEN 'big'
        ELSE 'small'
	END AS weight,
    COUNT(*) AS 'number_orders'
FROM 
	(SELECT 
		AVG(p.product_weight_g) AS avg_weight,
        AVG(p.product_length_cm) AS avg_length,
        AVG(p.product_height_cm) AS avg_height, 
        AVG(product_width_cm) AS avg_width
	FROM
		products AS p) AS x,
    orders AS o
JOIN order_items AS oi 
	ON o.order_id = oi.order_id  
JOIN products AS p 
	ON oi.product_id = p.product_id
JOIN product_category_name_translation as transl 
	ON transl.product_category_name = p.product_category_name
WHERE order_status = "delivered"
GROUP BY 
	delivery, weight, product_category_name_english
ORDER BY product_category_name_english;

SELECT
	3012 / 4396 AS 'ratio_delayed',
    42734 / 60047 AS 'ratio_ontime';

-- Creates overview of relationship between delivery delays and weight of product.
with main as ( 
    SELECT * FROM orders
    WHERE order_delivered_customer_date AND order_estimated_delivery_date IS NOT NULL
    ),
    d1 as (
    SELECT *, (order_delivered_customer_date - order_estimated_delivery_date)/1000/60/60/24 AS delay FROM main
    )
    
SELECT 
    CASE 
        WHEN delay > 101 THEN "> 100 day Delay"
        WHEN delay > 3 AND delay < 8 THEN "3-7 day delay"
        WHEN delay > 1.5 THEN "1.5 - 3 days delay"
        ELSE "< 1.5 day delay"
    END AS "delay_range", 
    AVG(product_weight_g) AS weight_avg,
    MAX(product_weight_g) AS max_weight,
    MIN(product_weight_g) AS min_weight,
    SUM(product_weight_g) AS sum_weight,
    COUNT(*) AS product_count FROM d1 a
INNER JOIN order_items b
	ON a.order_id = b.order_id
INNER JOIN products c
	ON b.product_id = c.product_id
WHERE delay > 0
GROUP BY delay_range
ORDER BY weight_avg DESC;
    
-- Grabs number of products in catalog grouped by price-category. 
SELECT 
    COUNT(DISTINCT p.product_id) AS 'Number of products in catalog',
    CASE
        WHEN oi.price > 0 AND oi.price <= 50 THEN '0-50'
        WHEN oi.price > 50 AND oi.price <= 100 THEN '50-100'
        WHEN oi.price > 100 AND oi.price <= 150 THEN '100-150'
        WHEN oi.price > 150 AND oi.price <= 200 THEN '150-200'
        WHEN oi.price > 200 AND oi.price <= 1000 THEN '200-1000'
        ELSE '> 1000'
    END AS price_category
FROM
    products AS p
JOIN order_items AS oi 
	ON oi.product_id = p.product_id
GROUP BY price_category
ORDER BY price_category;