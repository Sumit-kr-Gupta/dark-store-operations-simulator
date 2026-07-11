/*==========================================================
PROJECT  : Dark Store Operations Simulator
AUTHOR   : Sumit Kumar Gupta
DATABASE : DARK_STORE_OPS

OBJECTIVE: Analyze dark store (quick-commerce) fulfillment performance,SLA compliance, stockouts,
cancellations, store profitability, and inventory health to support operational and executive decisions.

CONTENTS:
  SECTION 0  - Database Setup
  SECTION 1  - Data Validation & Data Quality
  SECTION 2  - Executive Business Snapshot
  SECTION 3  - Order & Revenue Intelligence
  SECTION 4  - Store Performance Intelligence
  SECTION 5  - Inventory & Stockout Intelligence
  SECTION 6  - Revenue Loss & Risk Intelligence
  SECTION 7  - Peak Hour & Staffing Intelligence
  SECTION 8  - Cost & Profitability Intelligence
  SECTION 9  - Advanced Analytics & AI Model Inputs
  SECTION 10 - DEMAND SCENARIO & CAPACITY PLANNING
  SECTION 11 - Diagnostics & Executive Recommendations
  SECTION 12 - Business Views

SCHEMA ASSUMPTIONS:
  ORDERS(order_id, store_id, city, category, revenue_inr, order_timestamp,
         is_peak_hour, sla_breached, stockout_flag, cancelled_flag,
         customer_rating, total_fulfillment_time_min)
  INVENTORY(store_id, category, current_stock, max_capacity, below_reorder)

NOTE ON COST/MARGIN QUERIES (SECTION 8): neither table has a direct cost
column, so Cost-to-Serve and Contribution Margin use a transparent
COST_PROXY built from operational cost drivers already in the data (SLA
breach penalty, stockout rework, cancellation waste, fulfillment-time
labor). Swap the constants for finance-confirmed unit costs when available.
==========================================================*/
/*==========================================================
SECTION 0 — DATABASE SETUP
Business Goal:
  Initialize the database and confirm the source tables exist before
  running any analysis.
Business Questions:
  1. Does the database and schema exist?
  2. Are the orders and inventory tables populated?
==========================================================*/
CREATE DATABASE IF NOT EXISTS DARK_STORE_OPS;
USE DARK_STORE_OPS;
SHOW TABLES;
SELECT COUNT(*) AS row_count FROM orders;
SELECT COUNT(*) AS row_count FROM inventory;

/*==========================================================
SECTION 1 — DATA VALIDATION & DATA QUALITY
Business Goal:
  Confirm the underlying order and inventory data is clean and
  trustworthy before it is used to drive revenue, staffing, or
  executive reporting.
Business Questions:
  1. Are there duplicate order records?
  2. Are there orders referencing a store/category combination that has
     no matching inventory record?
  3. Does any inventory record show stock exceeding its own capacity
     (data entry error)?
  4. Are there orders with missing or non-positive revenue?
==========================================================*/
/* Duplicate Order Records */
SELECT order_id,
COUNT(*) AS record_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

/* Orders Without a Matching Inventory Record */
SELECT DISTINCT o.store_id,o.category
FROM orders o
LEFT JOIN inventory i
    ON o.store_id = i.store_id
   AND o.category = i.category
WHERE i.store_id IS NULL;

/* Inventory Records Where Stock Exceeds Max Capacity */
SELECT store_id,category,current_stock,max_capacity
FROM inventory
WHERE current_stock > max_capacity;

/* Orders With Missing or Non-Positive Revenue */
SELECT order_id, revenue_inr
FROM orders
WHERE revenue_inr IS NULL
   OR revenue_inr <= 0;

/*==========================================================
SECTION 2 — EXECUTIVE BUSINESS SNAPSHOT
Business Goal:
  Provide a single, high-level view of network health that executives
  can scan in under a minute.
Business Questions:
  1. How many orders and how much revenue has the network generated?
  2. What is the average order value?
  3. What do SLA, stockout, cancellation, and rating look like together?
==========================================================*/

/* Total Orders */
SELECT
    COUNT(*) AS total_orders
FROM orders;

/* Total Revenue */
SELECT
    SUM(revenue_inr) AS total_revenue
FROM orders;

/* Average Order Value */
SELECT
    AVG(revenue_inr) AS avg_order_value
FROM orders;

/* Executive KPI Dashboard */
SELECT
    COUNT(*)                            AS total_orders,
    ROUND(SUM(revenue_inr), 0)          AS total_revenue,
    ROUND(AVG(revenue_inr), 2)          AS avg_order_value,
    ROUND(AVG(sla_breached) * 100, 1)   AS sla_pct,
    ROUND(AVG(stockout_flag) * 100, 1)  AS stockout_pct,
    ROUND(AVG(cancelled_flag) * 100, 1) AS cancel_pct,
    ROUND(AVG(customer_rating), 2)      AS avg_rating
FROM orders;


/*==========================================================
SECTION 3 — ORDER & REVENUE INTELLIGENCE
Business Goal:
  Understand where orders and revenue come from geographically and by
  category, and how revenue trends over time.
Business Questions:
  1. Which cities generate the most orders and revenue?
  2. Which categories generate the most orders and revenue?
  3. How does revenue trend month over month?
==========================================================*/

/* Orders and Revenue by City */
SELECT
    city,
    COUNT(*)                    AS orders,
    ROUND(SUM(revenue_inr), 0)  AS revenue
FROM orders
GROUP BY city
ORDER BY orders DESC;

/* Orders and Revenue by Category */
SELECT
    category,
    COUNT(*)                    AS orders,
    ROUND(SUM(revenue_inr), 0)  AS revenue
FROM orders
GROUP BY category
ORDER BY orders DESC;

/* Monthly Revenue Trend */
SELECT
    MONTH(order_timestamp)     AS month_num,
    ROUND(SUM(revenue_inr), 0) AS revenue
FROM orders
GROUP BY MONTH(order_timestamp)
ORDER BY month_num;


/*==========================================================
SECTION 4 — STORE PERFORMANCE INTELLIGENCE
Business Goal:
  Rank stores on volume, revenue, SLA, stockouts, cancellations, and
  rating so operational attention can be prioritized correctly.
Business Questions:
  1. Which stores perform best and worst overall?
  2. What is the average order value at each store?
  3. What does a full, side-by-side store scorecard look like?
==========================================================*/

/* Store Performance Ranking */
SELECT
    store_id,
    COUNT(*)                            AS orders,
    ROUND(SUM(revenue_inr), 0)          AS revenue,
    ROUND(AVG(sla_breached) * 100, 1)   AS sla_pct,
    ROUND(AVG(stockout_flag) * 100, 1)  AS stockout_pct,
    ROUND(AVG(cancelled_flag) * 100, 1) AS cancel_pct,
    ROUND(AVG(customer_rating), 2)      AS rating
FROM orders
GROUP BY store_id
ORDER BY sla_pct DESC;

/* Worst Performing Stores */
SELECT store_id,
ROUND(AVG(sla_breached) * 100, 1)   AS breach_pct,
ROUND(AVG(stockout_flag) * 100, 1)  AS stockout_pct,
ROUND(AVG(cancelled_flag) * 100, 1) AS cancel_pct
FROM orders
GROUP BY store_id
ORDER BY breach_pct DESC;

/* Average Order Value by Store */
SELECT store_id,
ROUND(AVG(revenue_inr), 2) AS avg_order_value
FROM orders
GROUP BY store_id
ORDER BY avg_order_value DESC;

/* Full Store Scorecard */
SELECT store_id,
COUNT(*)AS total_orders,
ROUND(SUM(revenue_inr), 0)AS total_revenue,
ROUND(AVG(sla_breached) * 100, 1)AS sla_breach_pct,
ROUND(AVG(stockout_flag) * 100, 1)AS stockout_pct,
ROUND(AVG(cancelled_flag) * 100, 1)AS cancel_pct,
ROUND(AVG(customer_rating), 2)AS avg_rating
FROM orders
GROUP BY store_id
ORDER BY total_revenue DESC;


/*==========================================================
SECTION 5 — INVENTORY & STOCKOUT INTELLIGENCE
Business Goal:
  Identify which categories, stores, and store-category combinations
  carry the highest stockout and inventory risk.
Business Questions:
  1. Which categories stock out most often, and how much revenue do
     they carry?
  2. Which stores have the most items below their reorder point?
  3. Which store-category combinations need emergency replenishment?
==========================================================*/

/* Category Risk Analysis */
SELECT category,
ROUND(AVG(stockout_flag) * 100, 1) AS stockout_pct,
ROUND(SUM(revenue_inr), 0)AS revenue
FROM orders
GROUP BY category;

/* Inventory Risk Ranking */
SELECT store_id,
COUNT(*) AS critical_categories
FROM inventory
WHERE below_reorder = 1
GROUP BY store_id
ORDER BY critical_categories DESC;

/* Store-Category Diagnostic View (Orders Joined With Inventory) */
SELECT o.store_id,o.category,
ROUND(AVG(o.stockout_flag) * 100, 1) AS stockout_pct,
i.current_stock,i.max_capacity,i.below_reorder
FROM orders o
JOIN inventory i
ON o.store_id = i.store_id
AND o.category = i.category
GROUP BY o.store_id,o.category,i.current_stock,i.max_capacity,i.below_reorder
ORDER BY stockout_pct DESC;

/* Store-Category Combinations Requiring Emergency Replenishment */
SELECT o.store_id,o.category,i.current_stock,i.max_capacity,
ROUND(i.current_stock * 100 / NULLIF(i.max_capacity, 0), 1) AS stock_fill_pct,i.below_reorder,
COUNT(o.order_id)AS orders,
ROUND(AVG(o.stockout_flag) * 100, 1)AS stockout_pct,
ROUND(SUM(o.revenue_inr), 0)AS revenue_exposed
FROM orders o
JOIN inventory i
    ON o.store_id = i.store_id
   AND o.category = i.category
WHERE i.below_reorder = 1
GROUP BY o.store_id,o.category,i.current_stock,i.max_capacity,i.below_reorder
ORDER BY stockout_pct DESC;


/*==========================================================
SECTION 6 — REVENUE LOSS & RISK INTELLIGENCE
Business Goal:
  Quantify and trace exactly how much revenue is lost or exposed to
  risk, and where it is concentrated, so every rupee is auditable.
Business Questions:
  1. How much revenue is lost to stockouts and cancellations combined?
  2. What exact combination of causes (stockout only, cancelled only,
     or both) drove each rupee of loss?
  3. How much revenue is already lost versus merely at risk (SLA
     breached but the order still survived)?
  4. Which stores and categories account for the most lost revenue?
==========================================================*/

/* Revenue Lost to Stockouts or Cancellations*/
SELECT ROUND(SUM(revenue_inr), 0) AS revenue_lost,
ROUND(SUM(revenue_inr) * 100 / (SELECT SUM(revenue_inr) FROM orders), 2) AS revenue_loss_pct
FROM orders
WHERE stockout_flag = 1
OR cancelled_flag = 1;

/* Revenue Loss Breakdown by Exact Cause */
SELECT 'Stockout Only' AS loss_reason,
COUNT(*)AS orders_affected,
ROUND(SUM(revenue_inr), 0) AS revenue_lost
FROM orders
WHERE stockout_flag = 1
  AND cancelled_flag = 0

UNION ALL

SELECT
    'Cancelled Only' AS loss_reason,
    COUNT(*)          AS orders_affected,
    ROUND(SUM(revenue_inr), 0) AS revenue_lost
FROM orders
WHERE stockout_flag = 0
  AND cancelled_flag = 1

UNION ALL

SELECT
    'Stockout AND Cancelled' AS loss_reason,
    COUNT(*)                  AS orders_affected,
    ROUND(SUM(revenue_inr), 0) AS revenue_lost
FROM orders
WHERE stockout_flag = 1
  AND cancelled_flag = 1

UNION ALL

SELECT
    'TOTAL REVENUE LOST (stockout OR cancelled)' AS loss_reason,
    COUNT(*)                                      AS orders_affected,
    ROUND(SUM(revenue_inr), 0)                    AS revenue_lost
FROM orders
WHERE stockout_flag = 1
   OR cancelled_flag = 1;

/* Revenue Lost (Realized) vs. Revenue at Risk (SLA Breached, Order Survived) */
SELECT
    'Revenue Lost (Realized)' AS metric,
    COUNT(*)                  AS orders,
    ROUND(SUM(revenue_inr), 0) AS revenue_inr,
    ROUND(SUM(revenue_inr) * 100 / (SELECT SUM(revenue_inr) FROM orders), 2) AS pct_of_total_revenue
FROM orders
WHERE stockout_flag = 1
   OR cancelled_flag = 1

UNION ALL

SELECT
    'Revenue At Risk (SLA breached, order survived)' AS metric,
    COUNT(*)                                          AS orders,
    ROUND(SUM(revenue_inr), 0)                        AS revenue_inr,
    ROUND(SUM(revenue_inr) * 100 / (SELECT SUM(revenue_inr) FROM orders), 2) AS pct_of_total_revenue
FROM orders
WHERE sla_breached = 1
  AND stockout_flag = 0
  AND cancelled_flag = 0;

/* Revenue Loss by Store */
SELECT
    store_id,
    COUNT(*)                    AS orders_lost,
    ROUND(SUM(revenue_inr), 0)  AS revenue_lost,
    ROUND(SUM(revenue_inr) * 100 / (SELECT SUM(revenue_inr) FROM orders WHERE stockout_flag = 1 OR cancelled_flag = 1), 2) AS pct_of_total_loss
FROM orders
WHERE stockout_flag = 1
   OR cancelled_flag = 1
GROUP BY store_id
ORDER BY revenue_lost DESC;

/* Revenue Loss by Category */
SELECT
    category,
    COUNT(*)                            AS orders_lost,
    ROUND(SUM(revenue_inr), 0)          AS revenue_lost,
    ROUND(AVG(stockout_flag) * 100, 1)  AS stockout_pct,
    ROUND(SUM(revenue_inr) * 100 / (SELECT SUM(revenue_inr) FROM orders WHERE stockout_flag = 1 OR cancelled_flag = 1), 2) AS pct_of_total_loss
FROM orders
WHERE stockout_flag = 1
   OR cancelled_flag = 1
GROUP BY category
ORDER BY revenue_lost DESC;


/*==========================================================
SECTION 7 — PEAK HOUR & STAFFING INTELLIGENCE
Business Goal:
  Quantify how much peak-hour demand stresses fulfillment, and
  identify exactly which stores need additional staffing first.
Business Questions:
  1. How do peak-hour orders compare to off-peak on time, SLA, and
     stockouts?
  2. Which stores fail SLA most during peak versus off-peak hours?
  3. Which stores should receive additional pickers first?
==========================================================*/

/* Peak Hour vs Off-Peak Stress Analysis */
SELECT
    CASE
        WHEN is_peak_hour = 1 THEN 'Peak Hour'
        ELSE 'Off Peak'
    END                                          AS period,
    COUNT(*)                                     AS orders,
    ROUND(AVG(total_fulfillment_time_min), 2)    AS avg_time,
    ROUND(AVG(sla_breached) * 100, 1)            AS breach_pct,
    ROUND(AVG(stockout_flag) * 100, 1)           AS stockout_pct
FROM orders
GROUP BY period;

/* SLA Breach Rate by Store, Peak vs Off-Peak */
SELECT
    store_id,
    CASE
        WHEN is_peak_hour = 1 THEN 'Peak Hour'
        ELSE 'Off Peak'
    END                                        AS period,
    COUNT(*)                                   AS orders,
    ROUND(AVG(sla_breached) * 100, 1)          AS sla_breach_pct,
    ROUND(AVG(total_fulfillment_time_min), 2)  AS avg_fulfillment_time_min
FROM orders
GROUP BY
    store_id,
    period
ORDER BY
    store_id,
    period DESC;

/* Picker Staffing Priority Score (Peak-Hour SLA Breach, Stockout Rate, Volume) */
SELECT
    store_id,
    COUNT(*)                                   AS peak_orders,
    ROUND(AVG(sla_breached) * 100, 1)          AS peak_sla_breach_pct,
    ROUND(AVG(stockout_flag) * 100, 1)         AS peak_stockout_pct,
    ROUND(AVG(total_fulfillment_time_min), 2)  AS peak_avg_fulfillment_min,
    ROUND(
        (AVG(sla_breached) * 100 * 0.5)
      + (AVG(stockout_flag) * 100 * 0.3)
      + (COUNT(*) * 0.2)
    , 2) AS picker_priority_score
FROM orders
WHERE is_peak_hour = 1
GROUP BY store_id
ORDER BY picker_priority_score DESC;


/*==========================================================
SECTION 8 — COST & PROFITABILITY INTELLIGENCE
Business Goal:
  Estimate cost-to-serve and contribution margin per store using a
  transparent operational cost proxy, until finance-confirmed unit
  costs are available.
Business Questions:
  1. Which stores are most expensive to serve, in absolute and
     per-order terms?
  2. Which stores generate the highest contribution margin after
     accounting for operational cost drivers?
==========================================================*/

/* Cost-to-Serve Proxy by Store */
SELECT
    store_id,
    COUNT(*)                     AS orders,
    ROUND(SUM(revenue_inr), 0)   AS revenue,
    ROUND(
        SUM(sla_breached)      * 50
      + SUM(stockout_flag)     * 30
      + SUM(cancelled_flag)    * 75
      + SUM(total_fulfillment_time_min) * 2
    , 0) AS cost_to_serve_proxy_inr,
    ROUND(
        (
            SUM(sla_breached)      * 50
          + SUM(stockout_flag)     * 30
          + SUM(cancelled_flag)    * 75
          + SUM(total_fulfillment_time_min) * 2
        ) / COUNT(*)
    , 2) AS cost_to_serve_proxy_per_order
FROM orders
GROUP BY store_id
ORDER BY cost_to_serve_proxy_inr DESC;

/* Contribution Margin Proxy by Store (Revenue - Cost-to-Serve Proxy) */
SELECT
    store_id,
    ROUND(SUM(revenue_inr), 0) AS revenue,
    ROUND(
        SUM(sla_breached)      * 50
      + SUM(stockout_flag)     * 30
      + SUM(cancelled_flag)    * 75
      + SUM(total_fulfillment_time_min) * 2
    , 0) AS cost_to_serve_proxy_inr,
    ROUND(
        SUM(revenue_inr)
      - (
            SUM(sla_breached)      * 50
          + SUM(stockout_flag)     * 30
          + SUM(cancelled_flag)    * 75
          + SUM(total_fulfillment_time_min) * 2
        )
    , 0) AS contribution_margin_proxy_inr,
    ROUND(
        (
            SUM(revenue_inr)
          - (
                SUM(sla_breached)      * 50
              + SUM(stockout_flag)     * 30
              + SUM(cancelled_flag)    * 75
              + SUM(total_fulfillment_time_min) * 2
            )
        ) * 100 / NULLIF(SUM(revenue_inr), 0)
    , 1) AS contribution_margin_pct
FROM orders
GROUP BY store_id
ORDER BY contribution_margin_proxy_inr DESC;


/*==========================================================
SECTION 9 — ADVANCED ANALYTICS & AI MODEL INPUTS
Business Goal:
  Prepare feature-engineered, model-ready datasets for downstream
  statistical or machine-learning work (risk scoring, demand
  forecasting, capacity simulation).
Business Questions:
  1. Which stores are statistically high-risk based on SLA breach
     rate relative to the network average?
  2. What does daily order volume and revenue look like per store,
     ready for a forecasting model?
  3. How does peak-hour demand compare to current inventory capacity
     per store-category?
==========================================================*/

/* Store Risk Dataset (Engineered Features + High-Risk Label) */
WITH store_features AS (
    SELECT
        store_id,
        COUNT(*)                                  AS total_orders,
        ROUND(SUM(revenue_inr), 0)                AS total_revenue,
        ROUND(AVG(revenue_inr), 2)                AS avg_order_value,
        ROUND(AVG(sla_breached) * 100, 2)         AS sla_breach_pct,
        ROUND(AVG(stockout_flag) * 100, 2)        AS stockout_pct,
        ROUND(AVG(cancelled_flag) * 100, 2)       AS cancel_pct,
        ROUND(AVG(customer_rating), 2)            AS avg_rating,
        ROUND(AVG(total_fulfillment_time_min), 2) AS avg_fulfillment_time_min,
        ROUND(AVG(is_peak_hour) * 100, 2)         AS peak_hour_order_share_pct
    FROM orders
    GROUP BY store_id
)
SELECT
    store_id,
    total_orders,
    total_revenue,
    avg_order_value,
    sla_breach_pct,
    stockout_pct,
    cancel_pct,
    avg_rating,
    avg_fulfillment_time_min,
    peak_hour_order_share_pct,
    CASE
        WHEN sla_breach_pct >= (
            SELECT AVG(sla_breach_pct) + STDDEV(sla_breach_pct)
            FROM store_features
        ) THEN 1
        ELSE 0
    END AS high_risk_store
FROM store_features
ORDER BY sla_breach_pct DESC;

/* Daily Demand Forecast Dataset (per Store) */
SELECT
    store_id,
    DATE(order_timestamp)                AS order_date,
    COUNT(*)                             AS daily_orders,
    ROUND(SUM(revenue_inr), 0)           AS daily_revenue,
    ROUND(AVG(is_peak_hour) * 100, 1)    AS peak_hour_share_pct,
    ROUND(AVG(stockout_flag) * 100, 1)   AS stockout_pct,
    ROUND(AVG(sla_breached) * 100, 1)    AS sla_breach_pct
FROM orders
GROUP BY
    store_id,
    DATE(order_timestamp)
ORDER BY
    store_id,
    order_date;

/* Capacity Planning Dataset (Peak Demand vs. Inventory Capacity) */
SELECT
    o.store_id,
    o.category,
    COUNT(o.order_id)                              AS peak_orders,
    ROUND(SUM(o.revenue_inr), 0)                   AS peak_revenue,
    ROUND(AVG(o.total_fulfillment_time_min), 2)    AS avg_fulfillment_time_min,
    i.current_stock,
    i.max_capacity,
    ROUND(i.current_stock * 100 / NULLIF(i.max_capacity, 0), 1) AS current_capacity_utilization_pct,
    i.below_reorder
FROM orders o
JOIN inventory i
    ON o.store_id = i.store_id
   AND o.category = i.category
WHERE o.is_peak_hour = 1
GROUP BY
    o.store_id,
    o.category,
    i.current_stock,
    i.max_capacity,
    i.below_reorder
ORDER BY current_capacity_utilization_pct DESC;

/*=========================================================
SECTION 12 - DEMAND SCENARIO & CAPACITY PLANNING
Business Goal:
  Evaluate whether the current dark store network can
  support future business growth by simulating a 20%
  increase in customer demand and identifying stores
  that require additional operational capacity.
Business Questions:
  1. If customer demand increases by 20%, how many
     additional orders and revenue will each store
     generate?
  2. Which stores are most likely to become capacity
     constrained under the projected demand growth?
  3. Which stores should leadership prioritize for
     staffing, inventory, and operational investment
     to support future demand?
=========================================================*/
/*Projected Orders*/
SELECT store_id,
COUNT(*) AS current_orders,
ROUND(COUNT(*) * 1.20) AS projected_orders
FROM orders
GROUP BY store_id
ORDER BY projected_orders DESC;

/*Projected Revenue*/
SELECT
    store_id,
    ROUND(SUM(revenue_inr),2) AS current_revenue,
    ROUND(SUM(revenue_inr) * 1.20,2) AS projected_revenue
FROM orders
GROUP BY store_id
ORDER BY projected_revenue DESC;

/*Peak-Hour Pressure*/
SELECT store_id,
    COUNT(CASE WHEN is_peak_hour=1 THEN 1 END) AS current_peak_orders,
    ROUND(COUNT(CASE WHEN is_peak_hour=1 THEN 1 END)*1.20) AS projected_peak_orders
FROM orders
GROUP BY store_id
ORDER BY projected_peak_orders DESC;

/*Capacity Utilization*/
SELECT store_id,
COUNT(*) AS current_orders,
ROUND(COUNT(*)*1.20) AS projected_orders,
ROUND(COUNT(*)*1.20-COUNT(*)) AS additional_orders
FROM orders
GROUP BY store_id;
/*
Business Insight:
If order demand increases by 20% without additional staffing or inventory,stores with the highest projected order
volume are most likely to experience:
- Higher SLA breaches
- Longer picking times
- Increased stockoutss
Recommendation:
Prioritize staffing and inventory investment in the top projected-demand stores.
*/
/*==========================================================
SECTION 11 — DIAGNOSTICS & EXECUTIVE RECOMMENDATIONS
Business Goal:
  Turn raw operational metrics into diagnosed root causes and plain-
  language recommended actions that leadership can act on directly.
Business Questions:
  1. Does an SLA breach measurably hurt the customer rating?
  2. What is the likely root cause of poor performance in each
     store-category combination?
  3. What should each store's next recommended action be?
  4. Is the network's weekly trend improving or worsening?
==========================================================*/
/* Customer Rating Impact of SLA Breaches */
SELECT
    sla_breached,
    ROUND(AVG(customer_rating), 2) AS rating
FROM orders
GROUP BY sla_breached;

/* Root Cause Dataset (Store-Category Level) */
SELECT
    o.store_id,
    o.category,
    COUNT(o.order_id)                     AS orders,
    ROUND(AVG(o.stockout_flag) * 100, 1)  AS stockout_pct,
    ROUND(AVG(o.sla_breached) * 100, 1)   AS sla_breach_pct,
    ROUND(AVG(o.cancelled_flag) * 100, 1) AS cancel_pct,
    ROUND(AVG(o.customer_rating), 2)      AS avg_rating,
    i.current_stock,
    i.max_capacity,
    i.below_reorder,
    CASE
        WHEN i.below_reorder = 1 AND AVG(o.stockout_flag) * 100 > 20 THEN 'Root Cause: Inventory Shortage'
        WHEN AVG(o.sla_breached) * 100 > 20 AND i.below_reorder = 0   THEN 'Root Cause: Operational / Staffing'
        WHEN AVG(o.cancelled_flag) * 100 > 15                        THEN 'Root Cause: Customer / Demand Mismatch'
        ELSE 'No Major Issue Detected'
    END AS diagnosed_root_cause
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

/* Executive Recommendation Dataset (per Store) */
SELECT
    store_id,
    COUNT(*)AS total_orders,
    ROUND(SUM(revenue_inr), 0)AS total_revenue,
    ROUND(SUM(CASE WHEN stockout_flag = 1 OR cancelled_flag = 1 THEN revenue_inr ELSE 0 END), 0)AS revenue_lost,
    ROUND(AVG(sla_breached) * 100, 1)AS sla_breach_pct,
    ROUND(AVG(stockout_flag) * 100, 1)AS stockout_pct,
    ROUND(AVG(customer_rating), 2)AS avg_rating,
    CASE
        WHEN AVG(stockout_flag) * 100 > 20 THEN 'Priority 1: Emergency Replenishment Required'
        WHEN AVG(sla_breached) * 100 > 20  THEN 'Priority 2: Add Peak-Hour Staffing'
        WHEN AVG(customer_rating) < 3.5    THEN 'Priority 3: Customer Experience Review'
        ELSE 'Stable — Monitor'
    END AS recommended_action
FROM orders
GROUP BY store_id
ORDER BY revenue_lost DESC;

/* Weekly Executive KPI Snapshot (Trend Check) */
SELECT
    YEAR(order_timestamp)AS year,
    WEEK(order_timestamp)AS week_num,
    COUNT(*)AS total_orders,
    ROUND(SUM(revenue_inr), 0)AS total_revenue,
    ROUND(AVG(revenue_inr), 2)AS avg_order_value,
    ROUND(AVG(sla_breached) * 100, 1) AS sla_breach_pct,
    ROUND(AVG(stockout_flag) * 100, 1)AS stockout_pct,
    ROUND(AVG(cancelled_flag) * 100, 1)AS cancel_pct,
    ROUND(AVG(customer_rating), 2) AS avg_rating
FROM orders
GROUP BY
    YEAR(order_timestamp),
    WEEK(order_timestamp)
ORDER BY
    year,
    week_num;

/*==========================================================
SECTION 12 — BUSINESS VIEWS
Business Goal:
  Package the most important recurring metrics into reusable views so
  BI tools (e.g., Tableau, Power BI) and stakeholders can query clean,
  pre-aggregated data without rewriting logic.
Business Questions:
  1. What does each store's live scorecard look like at a glance?
  2. What does the current-state executive KPI dashboard show?
  3. Which store-category combinations are currently at risk?
==========================================================*/

/* View 1: Store Scorecard (orders, revenue, SLA, stockout, cancel, rating) */
CREATE VIEW STORE_SCORECARD_VIEW AS
SELECT
    store_id,
    COUNT(*)                            AS total_orders,
    ROUND(SUM(revenue_inr), 0)          AS total_revenue,
    ROUND(AVG(sla_breached) * 100, 1)   AS sla_breach_pct,
    ROUND(AVG(stockout_flag) * 100, 1)  AS stockout_pct,
    ROUND(AVG(cancelled_flag) * 100, 1) AS cancel_pct,
    ROUND(AVG(customer_rating), 2)      AS avg_rating
FROM orders
GROUP BY store_id;

/* View 2: Executive KPI View (single-row network snapshot) */
CREATE VIEW EXECUTIVE_KPI_VIEW AS
SELECT
    COUNT(*)                            AS total_orders,
    ROUND(SUM(revenue_inr), 0)          AS total_revenue,
    ROUND(AVG(revenue_inr), 2)          AS avg_order_value,
    ROUND(AVG(sla_breached) * 100, 1)   AS sla_pct,
    ROUND(AVG(stockout_flag) * 100, 1)  AS stockout_pct,
    ROUND(AVG(cancelled_flag) * 100, 1) AS cancel_pct,
    ROUND(AVG(customer_rating), 2)      AS avg_rating
FROM orders;

/* View 3: Store-Category Risk View (orders enriched with inventory health) */
CREATE VIEW STORE_CATEGORY_RISK_VIEW AS
SELECT
    o.store_id,
    o.category,
    COUNT(o.order_id)                     AS orders,
    ROUND(AVG(o.stockout_flag) * 100, 1)  AS stockout_pct,
    ROUND(AVG(o.sla_breached) * 100, 1)   AS sla_breach_pct,
    ROUND(AVG(o.cancelled_flag) * 100, 1) AS cancel_pct,
    ROUND(AVG(o.customer_rating), 2)      AS avg_rating,
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
    i.below_reorder;

/* View 4: Revenue Loss View (orders lost to stockout or cancellation) */
CREATE VIEW REVENUE_LOSS_VIEW AS
SELECT
    store_id,
    category,
    order_id,
    revenue_inr,
    stockout_flag,
    cancelled_flag
FROM orders
WHERE stockout_flag = 1
   OR cancelled_flag = 1;

/*Revenue Fully Lost Due to Stockout + Cancellation*/
SELECT
    COUNT(*) AS lost_orders,
    ROUND(SUM(revenue_inr),2) AS revenue_fully_lost,
    ROUND(AVG(revenue_inr),2) AS avg_order_value,
    ROUND(
        SUM(revenue_inr)*100/
        (SELECT SUM(revenue_inr) FROM orders),
        2
    ) AS revenue_loss_pct
FROM orders
WHERE stockout_flag = 1
AND cancelled_flag = 1;

/*Revenue Impact Definitions*/
SELECT 'Fully Lost Revenue(Stockout + Cancelled)' AS definition,
COUNT(*) AS affected_orders,
ROUND(SUM(revenue_inr),2) revenue
FROM orders
WHERE stockout_flag=1
AND cancelled_flag=1
UNION ALL
SELECT'Revenue At Risk(All Stockout Orders)',
COUNT(*),ROUND(SUM(revenue_inr),2)
FROM orders
WHERE stockout_flag=1;

/*Peak-Hour Operations Summary*/
SELECT store_id,
COUNT(*) total_orders,
SUM(is_peak_hour) peak_orders,
ROUND(AVG(pick_time_min),2) avg_pick_time,
ROUND(AVG(sla_breached)*100,2) sla_breach_pct,
ROUND(AVG(cancelled_flag)*100,2) cancellation_pct,
ROUND(SUM(revenue_inr),2) peak_revenue
FROM orders
WHERE is_peak_hour=1
GROUP BY store_id
ORDER BY sla_breach_pct DESC;

/*Investment Priority Ranking*/
SELECT store_id,
COUNT(*) orders,
ROUND(SUM(revenue_inr),2) revenue,
ROUND(AVG(sla_breached)*100,2) sla_pct,
ROUND(AVG(stockout_flag)*100,2) stockout_pct,
ROUND(AVG(cancelled_flag)*100,2) cancel_pct,
ROUND(AVG(sla_breached)*0.5+
AVG(stockout_flag)*0.3+
AVG(cancelled_flag)*0.2,3) risk_score
FROM orders
GROUP BY store_id
ORDER BY risk_score DESC;

/*Executive Decision Dashboard*/
SELECT COUNT(*) total_orders,
ROUND(SUM(revenue_inr),2) total_revenue,
ROUND(AVG(sla_breached)*100,2) sla_breach,
ROUND(AVG(stockout_flag)*100,2) stockout,
ROUND(AVG(cancelled_flag)*100,2) cancellation,
ROUND(AVG(customer_rating),2) customer_rating,
ROUND(SUM(CASE WHEN stockout_flag=1 AND cancelled_flag=1 THEN revenue_inr ELSE 0 END),2)
fully_lost_revenue
FROM orders;

/*Executive Recommendation*/
SELECT store_id,
CASE WHEN
AVG(sla_breached)>0.60
AND AVG(stockout_flag)>0.20
THEN
'Priority 1:Increase staffing and inventory'
WHEN AVG(sla_breached)>0.60
THEN
'Priority 2:Increase picker capacity'
WHEN AVG(stockout_flag)>0.20
THEN
'Priority 3:Increase safety stock'
ELSE 'Monitor'
END
AS recommendation
FROM orders
GROUP BY store_id;

