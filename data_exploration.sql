-- 1. How many orders are there in the dataset?
SELECT COUNT(*) 
FROM orders;

-- 2. Are orders actually delivered?
SELECT 
	order_status, 
	COUNT(order_status) as "number of orders"
FROM orders
GROUP BY order_status;

-- 3. What are trends in the userbase?
SELECT 
	YEAR(order_purchase_timestamp) AS Year,
    MONTH(order_purchase_timestamp) AS Month,
    COUNT(*) AS "Number of Orders"
FROM orders
GROUP BY Year, Month
ORDER BY Year, Month;

SELECT 
	YEAR(order_purchase_timestamp) AS year,
    COUNT(*) AS "orders"
FROM orders
GROUP BY year;

-- 4. How many products are in the products table?
SELECT 
	COUNT(DISTINCT(product_id)) AS "Number of Products"
FROM products;

-- 5. Which are the categories with most products?
SELECT 
	product_category_name_english as prod_category,
    COUNT(*) AS nr_of_products
FROM 
	products as p
		JOIN 
	product_category_name_translation as transl ON p.product_category_name = transl.product_category_name
GROUP BY p.product_category_name
ORDER BY nr_of_products DESC;

-- 6. Have all these products been involved in orders?
SELECT 
	COUNT(DISTINCT(product_id)) as nr_unique_products
FROM order_items;

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

