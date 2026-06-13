CREATE DATABASE DARK_STORE_OPS;
USE DARK_STORE_OPS ;
SHOW TABLES ;
/*Total Orders*/
SELECT COUNT(*) AS total_orders FROM orders;

/*Total Revenue*/
SELECT SUM(revenue_inr) AS total_revenue FROM orders;

/*Average Order Value*/
SELECT AVG(revenue_inr) AS avg_order_value FROM orders;

/*Orders by City*/
SELECT city, COUNT(*) orders FROM orders
GROUP BY city;

/*Orders by Category*/
SELECT category,COUNT(*) orders
FROM orders GROUP BY category;

/*Revenue Lost Due To Stockouts*/
SELECT ROUND(SUM(revenue_inr),0) revenue_lost,
ROUND(SUM(revenue_inr)*100/(SELECT SUM(revenue_inr)FROM orders),2) revenue_loss_pct
FROM orders
WHERE stockout_flag = 1
AND cancelled_flag = 1;

/*Peak Hour Stress Analysis*/
SELECT CASE WHEN is_peak_hour = 1 THEN 'Peak Hour'ELSE 'Off Peak'END AS period,
COUNT(*) orders,
ROUND(AVG(total_fulfillment_time_min),2) avg_time,
ROUND(AVG(sla_breached)*100,1) sla_pct,
ROUND(AVG(stockout_flag)*100,1) stockout_pct
FROM orders GROUP BY period;

/*Store Performance Ranking*/
SELECT store_id,
SUM(revenue_inr) revenue,
AVG(customer_rating) rating
FROM orders GROUP BY store_id
ORDER BY revenue DESC;

/*Category Risk Analysis*/
SELECT category,
AVG(stockout_flag)*100 stockout_pct,
SUM(revenue_inr) revenue
FROM orders GROUP BY category;

/*Customer Experience Impact*/
SELECT sla_breached,
AVG(customer_rating) rating
FROM orders GROUP BY sla_breached;

/*Average Order Value By Store*/
SELECT store_id,
ROUND(AVG(revenue_inr),2) AS avg_order_value
FROM orders
GROUP BY store_id
ORDER BY avg_order_value DESC;

/*Inventory Risk Ranking*/
SELECT store_id,
COUNT(*) critical_categories 
FROM inventory WHERE below_reorder=1
GROUP BY store_id ORDER BY critical_categories DESC;

/*Worst Performing Stores*/
SELECT store_id,
AVG(sla_breached)*100 breach_pct,
AVG(stockout_flag)*100 stockout_pct,
AVG(cancelled_flag)*100 cancel_pct
FROM orders GROUP BY store_id
ORDER BY breach_pct DESC;

/*Monthly Revenue Trend*/
SELECT MONTH(order_timestamp) month_num,
SUM(revenue_inr) revenue
FROM orders GROUP BY MONTH(order_timestamp)
ORDER BY month_num;

/* Executive KPI Dashboard*/
SELECT COUNT(*) total_orders,
SUM(revenue_inr) total_revenue,
AVG(revenue_inr) avg_order_value,
AVG(sla_breached)*100 sla_pct,
AVG(stockout_flag)*100 stockout_pct,
AVG(cancelled_flag)*100 cancel_pct,
AVG(customer_rating) avg_rating
FROM orders;

/*Full Store Scorecard*/
SELECT store_id,
COUNT(*) AS total_orders,
ROUND(SUM(revenue_inr),0) AS total_revenue,
ROUND(AVG(sla_breached)*100,1) AS sla_breach_pct,
ROUND(AVG(stockout_flag)*100,1) AS stockout_pct,
ROUND(AVG(cancelled_flag)*100,1) AS cancel_pct,
ROUND(AVG(customer_rating),2) AS avg_rating
FROM orders
GROUP BY store_id
ORDER BY total_revenue DESC;

/*Diagnostic Analytics*/
SELECT
o.store_id,
o.category,
ROUND(AVG(o.stockout_flag)*100,1) AS stockout_pct,
i.current_stock,
i.max_capacity,
i.below_reorder
FROM orders o
JOIN inventory i
ON o.store_id = i.store_id
AND o.category = i.category
GROUP BY
o.store_id,
o.category,
i.current_stock,
i.max_capacity,
i.below_reorder
ORDER BY stockout_pct DESC;



















