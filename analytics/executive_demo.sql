/* Recruiter demo: run these queries in order after .\deploy.ps1. */
USE DataWarehouse;
GO

-- 1. Executive scorecard: concise proof that the model serves business questions.
SELECT COUNT(DISTINCT order_number) AS orders, COUNT(DISTINCT customer_key) AS customers,
    CAST(SUM(sales_amount) AS DECIMAL(18,2)) AS revenue,
    CAST(SUM(sales_amount) / NULLIF(COUNT(DISTINCT order_number), 0) AS DECIMAL(18,2)) AS average_order_value
FROM gold.fact_sales;
GO

-- 2. Monthly revenue trend: supports sales planning and seasonality analysis.
SELECT DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1) AS month_start,
    CAST(SUM(sales_amount) AS DECIMAL(18,2)) AS revenue, COUNT(DISTINCT order_number) AS orders
FROM gold.fact_sales
GROUP BY DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
ORDER BY month_start;
GO

-- 3. Product performance: identify high-revenue categories and products.
SELECT TOP (10) p.category, p.subcategory, p.product_name,
    CAST(SUM(f.sales_amount) AS DECIMAL(18,2)) AS revenue, SUM(f.quantity) AS units_sold
FROM gold.fact_sales f JOIN gold.dim_products p ON p.product_key = f.product_key
GROUP BY p.category, p.subcategory, p.product_name ORDER BY revenue DESC;
GO

-- 4. Customer segmentation: supports retention and account-prioritization conversations.
WITH customer_sales AS (SELECT customer_key, SUM(sales_amount) AS lifetime_value FROM gold.fact_sales GROUP BY customer_key)
SELECT CASE WHEN lifetime_value >= 5000 THEN 'High value' WHEN lifetime_value >= 1000 THEN 'Mid value' ELSE 'Developing' END AS customer_segment,
    COUNT(*) AS customers, CAST(SUM(lifetime_value) AS DECIMAL(18,2)) AS revenue
FROM customer_sales
GROUP BY CASE WHEN lifetime_value >= 5000 THEN 'High value' WHEN lifetime_value >= 1000 THEN 'Mid value' ELSE 'Developing' END
ORDER BY revenue DESC;
GO
