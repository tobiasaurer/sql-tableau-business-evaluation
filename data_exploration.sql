-- 1. How many orders are there in the dataset?
SELECT COUNT(order_id) 
FROM orders;

-- 2. Are orders actually delivered?
SELECT 
	order_status, 
	COUNT(order_status) as "number of orders"
FROM orders
GROUP BY order_status;

-- 3. What are trends in the userbase?
-- Gets monthly number of orders.
SELECT 
	YEAR(order_purchase_timestamp) AS Year,
    MONTH(order_purchase_timestamp) AS Month,
    COUNT(*) AS "number of orders"
FROM orders
GROUP BY Year, Month
ORDER BY Year, Month;

-- Gets yearly number of orders.
SELECT 
	YEAR(order_purchase_timestamp) AS year,
    COUNT(*) AS "orders"
FROM orders
GROUP BY year
ORDER BY year;

-- 4. How many products are in the products table?
SELECT 
	COUNT(DISTINCT(product_id)) AS "number of products"
FROM products;

-- 5. Which are the categories with most products?
SELECT 
	product_category_name_english as product_category,
    COUNT(DISTINCT(product_id)) AS nr_of_products
FROM 
	products 
JOIN product_category_name_translation as transl 
	ON products.product_category_name = transl.product_category_name
GROUP BY products.product_category_name
ORDER BY nr_of_products DESC;

-- 6. Have all these products been involved in orders?
-- Grabs number of products that were involved in at least one order, and number of total products in catalog.
SELECT 
	COUNT(DISTINCT(products.product_id)) as products_in_orders,
    (
		SELECT 
			COUNT(DISTINCT(product_id)) as unique_products
		FROM order_items
	) AS total_unique_products
FROM products
RIGHT JOIN order_items
	ON order_items.product_id = products.product_id;

-- 7. What's the price for the most expensive and cheapest product?
SELECT 
    MAX(price) as max_price,
    MIN(price) as min_price
FROM order_items;

-- 8. What are the highest and lowest payment values? 
SELECT 
	MAX(payment_value) as most_expensive_order,
    MIN(payment_value) as cheapest_order
FROM order_payments;

