#  Dark Store Operations Simulator

**Designed an end-to-end operations analytics framework using Excel, SQL, and Python to evaluate fulfillment efficiency, inventory health, stockout risk, and store performance across an 8-store quick-commerce network — surfacing ₹14.7L+ in revenue at risk from stockout-driven order cancellations.**

---

##  Business Problem

Quick-commerce dark stores operate on razor-thin SLA windows — typically 10–30 minutes — where every minute of delay directly translates to customer churn, order cancellations, and lost revenue. At scale, operational inefficiencies compound: peak-hour surges overwhelm pick stations, stockouts cascade into cancellations, and underperforming stores drag down network-wide NPS.

This project is inspired by operational analytics challenges commonly seen in quick-commerce businesses such as Blinkit, Zepto, and Swiggy Instamart to identify where fulfillment processes break down and quantify the resulting operational and financial impact.
**CEO Perspective:** 62.8% SLA breach rate means nearly 2 in 3 orders are late. At 25,000 orders and ₹966 AOV, that is a structural customer experience problem — indicating a structural operational challenge rather than an isolated staffing issue.

**Operations Head Perspective:** Pick time averages 7.5 minutes out of a 30-minute SLA. This is one of the most important operational intervention points across the network because it is directly controllable at the store level.
**Supply Chain Perspective:** 11 of 56 store-category combinations are below reorder point. Personal Care and Staples show the most critical stock exposure across 4 stores each.

**Store Manager Perspective:** DS_Mumbai_Andheri has the highest SLA breach rate (63.4%) and the highest average fulfillment time (32.9 min) — both above network average — making it a priority candidate for operational intervention.

**Customer Perspective:** Customers experiencing SLA breaches reported materially lower ratings than customers receiving on-time deliveries. This 1.3-point rating gap may negatively impact customer retention and repeat purchase behavior. This 1.3-point rating gap may negatively impact customer retention and repeat purchase behavior.
---

##  Project Objectives

1. Quantify fulfillment performance across 8 dark stores and 5 cities
2. Identify SLA breach drivers — peak hour, category, and store level
3. Calculate revenue at risk from stockouts and cancellations
4. Rank stores by composite operational risk score
5. Profile inventory health across all 56 store-category combinations
6. Analyze customer experience impact of SLA failures
7. Benchmark fulfillment time by stage (pick, pack, dispatch, delivery)
8. Simulate demand growth impact on current infrastructure capacity
9. Provide store-specific, category-specific, actionable recommendations
10. Build an executive-ready KPI dashboard for leadership decision-making

---

##  Dataset Overview

| Dataset | Rows | Description | Use Case |
|---|---|---|---|
| orders | 25,000 | Transaction-level order data across 8 stores, 7 categories, 5 cities | SLA analysis, revenue analysis, peak-hour study, store ranking |
| inventory | 56 | One row per store-category combination with stock levels and reorder status | Inventory risk ranking, stockout root cause, replenishment planning |

**Orders dataset** contains 19 columns spanning store ID, city, product category, order timestamp, day of week, hour, peak-hour flag, pick/pack/dispatch/delivery times in minutes, total fulfillment time, SLA breached flag, stockout flag, cancellation flag, revenue in INR, item count, and customer rating.

**Inventory dataset** contains current stock, maximum capacity, reorder point, daily turnover rate, and a binary below-reorder flag for each store-category pair — enabling stock risk prioritization without requiring real-time data feeds.

## Data Source 
This project uses a simulated quick-commerce operations dataset designed for analytics and portfolio development purposes. The dataset models order fulfillment, inventory management, customer experience, and operational performance across a multi-city dark-store network.
---

## 📖 Data Dictionary

| Variable | Definition | Business Importance |
|---|---|---|
| order_id | Unique order identifier | Primary key for transaction tracking and audit |
| store_id | Dark store location code (e.g. DS_Mumbai_Andheri) | Store-level performance segmentation |
| city | City where order was placed | City-level resource and inventory planning |
| category | Product category (Dairy, Snacks, Frozen, Beverages, Fruits & Veg, Personal Care, Staples) | Category-level stockout and SLA analysis |
| order_timestamp | Date and time of order placement | Time-series trend analysis, peak hour identification |
| day_of_week | Day name (Monday–Sunday) | Day-of-week demand planning |
| order_hour | Hour of order (0–23) | Hourly staffing and capacity planning |
| is_peak_hour | Binary flag: 1 = peak hour, 0 = off-peak | Peak vs. off-peak performance comparison |
| pick_time_min | Time to pick items from shelf (minutes) | Largest fulfillment bottleneck — avg 7.5 min |
| pack_time_min | Time to pack the order (minutes) | Secondary process efficiency metric |
| dispatch_time_min | Time between packing and handing to rider (minutes) | Handoff efficiency metric |
| delivery_time_min | Time from dispatch to customer door (minutes) | Last-mile performance indicator |
| total_fulfillment_time_min | Sum of all four stages (minutes) | Primary SLA compliance metric — avg 32.85 min |
| sla_breached | Binary: 1 = delivered beyond SLA threshold | Core operational KPI — 62.8% breach rate |
| stockout_flag | Binary: 1 = item was out of stock during order | Inventory failure indicator — 15.2% rate |
| cancelled_flag | Binary: 1 = order was cancelled | Revenue destruction metric — 6.1% rate |
| revenue_inr | Order revenue in Indian Rupees | Financial impact quantification |
| items_count | Number of items in the order | Basket size for complexity analysis |
| customer_rating | Post-delivery rating (1–5) | Customer experience outcome metric |
| current_stock | Units currently in inventory at store | Real-time stock health |
| max_capacity | Maximum storage capacity for category at store | Utilization rate calculation |
| reorder_point | Minimum stock level before reorder trigger | Replenishment planning threshold |
| turnover_rate | Daily sales velocity for category at store | Inventory efficiency and depletion rate |
| below_reorder | Binary: 1 = current stock below reorder point | Immediate replenishment flag |

---

##  Tech Stack

![Excel](https://img.shields.io/badge/Excel-217346?style=for-the-badge&logo=microsoft-excel&logoColor=white)
![SQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)

**Excel** — Business KPI dashboard, store scorecard, city and category pivot analysis, inventory risk matrix. Purpose: structured operational reporting for non-technical stakeholders. Business value: enables store managers and operations leads to monitor KPIs without SQL or code access.

**SQL (MySQL)** — 20+ operational queries covering revenue loss from stockouts, peak-hour SLA analysis, store risk ranking, inventory diagnostic joins, and executive KPI rollups. Purpose: scalable, repeatable analysis on structured transactional data. Business value: enables data teams to refresh analysis on any new data load without manual Excel work.

**Python (Pandas, NumPy, Matplotlib, Seaborn)** — EDA, fulfillment stage time breakdown, composite risk scoring, scenario demand analysis, executive recommendation engine. Purpose: advanced pattern recognition and business logic that requires programmatic flexibility. Business value: risk scoring, scenario simulation, and automated insight generation at scale.

**GitHub** — Version control, portfolio presentation, and recruiter-accessible documentation. Business value: demonstrates professional code management and project reproducibility.

---

##  Excel Analysis

### Sheet: KPI
**Purpose:** Network-wide summary KPIs for executive review.
**Business Question:** What is the current operational health of the dark store network?
**Methodology:** Direct formula aggregation from raw Orders data using SUM, COUNT, AVERAGE, and percentage formulas.
**KPIs:**
- Total Orders: 25,000
- Total Revenue: ₹2.42 Cr (₹2,41,62,205)
- Average Order Value: ₹966.49
- SLA Breach %: 62.8%
- Stockout %: 15.2%
- Cancellation %: 6.1%
- Average Customer Rating: 3.89 / 5.0

### Sheet: Store Performance
**Purpose:** Revenue, order volume, customer rating, and fulfillment time by store — in two pivot views.
**Business Question:** Which stores generate the most revenue and which have the worst fulfillment performance?
**Methodology:** Pivot table with SUM, COUNT, and AVERAGE across store_id dimension. Secondary pivot adds category-level stockout and SLA breakdown.
**Key Insight:** Revenue is distributed relatively evenly across all 8 stores (₹29.3L–₹30.7L range), suggesting operational performance differences are not primarily driven by volume concentration.

### Sheet: Store_Scorecard
**Purpose:** Full operational risk matrix for each store — the single-view decision tool for Operations Head.
**Business Question:** How does each store perform across all five operational KPIs simultaneously?
**Methodology:** Pivot table + supplementary pivot showing peak-hour vs. off-peak SLA breach comparison (peak: 95.2% breach rate vs. off-peak: 42.4%).

| Store | Orders | Revenue | SLA Breach % | Stockout % | Cancel % | Avg Rating |
|---|---|---|---|---|---|---|
| DS_Bangalore_Koramangala | 3,129 | ₹30.29L | 62.9% | 14.4% | 5.5% | 3.90 |
| DS_Bangalore_Whitefield | 3,049 | ₹29.32L | 62.2% | 15.4% | 6.3% | 3.89 |
| DS_Delhi_CP | 3,124 | ₹30.03L | 62.9% | 15.3% | 5.7% | 3.88 |
| DS_Delhi_Lajpat | 3,136 | ₹30.17L | 62.7% | 15.4% | 6.0% | 3.89 |
| DS_Hyderabad_Hitech | 3,107 | ₹30.11L | 62.4% | 14.4% | 5.7% | 3.89 |
| DS_Mumbai_Andheri | 3,112 | ₹30.72L | 63.4% | 15.5% | 6.3% | 3.88 |
| DS_Mumbai_BKC | 3,100 | ₹29.99L | 63.0% | 15.2% | 6.5% | 3.88 |
| DS_Pune_Kothrud | 3,243 | ₹30.97L | 63.1% | 15.8% | 6.6% | 3.88 |

**Insight:** DS_Pune_Kothrud has the worst cancellation rate (6.6%) and highest stockout rate (15.8%). DS_Mumbai_Andheri has the highest SLA breach rate (63.4%). DS_Hyderabad_Hitech is the relative best performer on both SLA (62.4%) and stockout (14.4%).

### Sheet: City Analysis
**Purpose:** City-level revenue, order volume, and customer rating summary.
**Business Question:** Which cities drive the most revenue and where should we prioritize inventory?

| City | Orders | Revenue | Avg Rating |
|---|---|---|---|
| Mumbai | 6,212 | ₹60.72L | 3.88 |
| Delhi | 6,260 | ₹60.21L | 3.89 |
| Bangalore | 6,178 | ₹59.61L | 3.89 |
| Pune | 3,243 | ₹30.97L | 3.88 |
| Hyderabad | 3,107 | ₹30.11L | 3.89 |

**Key Insight:** Mumbai and Delhi together account for ₹1.21 Cr (50.1%) of total network revenue — highest priority cities for inventory and staffing investment.

### Sheet: Category Analysis
**Purpose:** Stockout rate and SLA breach rate by product category.
**Business Question:** Which categories are most operationally vulnerable?

| Category | Orders | Revenue | Stockout % | SLA Breach % |
|---|---|---|---|---|
| Personal Care | 3,587 | ₹34.88L | 15.7% | 63.5% |
| Fruits & Veg | 3,545 | ₹34.49L | 15.4% | 62.2% |
| Frozen | 3,581 | ₹34.41L | 15.4% | 63.6% |
| Beverages | 3,495 | ₹33.71L | 14.5% | 63.7% |
| Snacks | 3,542 | ₹34.59L | 15.1% | 61.7% |
| Dairy | 3,577 | ₹34.24L | 15.1% | 62.7% |
| Staples | 3,673 | ₹35.30L | 15.1% | 62.4% |

**Key Insight:** Personal Care has the highest stockout rate (15.7%) with 4 stores flagged below reorder point. Frozen has the second-highest SLA breach rate (63.6%). Beverages has the worst combined SLA and stockout combination.

### Sheet: Inventory Analysis
**Purpose:** Store-category stock health, turnover rates, and critical replenishment flags.
**Business Question:** Which store-category combinations are at immediate stockout risk?

**11 store-category combinations are currently below reorder point:**

| Store | Critical Categories | Avg Turnover Rate |
|---|---|---|
| DS_Pune_Kothrud | 2 (Personal Care, Staples) | 7.83 |
| DS_Mumbai_Andheri | 2 (Fruits & Veg, Beverages) | 6.77 |
| DS_Bangalore_Koramangala | 2 (Personal Care, Staples) | 7.57 |
| DS_Delhi_Lajpat | 2 (Snacks, Personal Care) | 7.19 |
| DS_Bangalore_Whitefield | 1 (Beverages) | 7.36 |
| DS_Mumbai_BKC | 1 (Personal Care) | 6.89 |
| DS_Hyderabad_Hitech | 1 (Snacks) | 9.14 |
| DS_Delhi_CP | 0 | 7.19 |

**Most exposed category by stock count across network:**
- Personal Care: 4,879 total units across network, 4 stores below reorder
- Beverages: 6,834 units but 2 stores critical

---

##  SQL Analysis

All 20+ queries are available in `/sql/dark_store_queries.sql`.

### Top Interview-Ready Queries

**1. Revenue Lost Due to Stockouts**
```sql
SELECT 
  ROUND(SUM(revenue_inr), 0) AS revenue_lost,
  ROUND(SUM(revenue_inr)*100/(SELECT SUM(revenue_inr) FROM orders), 2) AS revenue_loss_pct
FROM orders
WHERE stockout_flag = 1 AND cancelled_flag = 1;
```
*Business Value:* Quantifies exact INR impact of inventory failure. Connects supply chain KPIs directly to P&L. This metric directly connects operational failures to financial impact.

**2. Peak Hour Stress Analysis (CASE WHEN)**
```sql
SELECT 
  CASE WHEN is_peak_hour = 1 THEN 'Peak Hour' ELSE 'Off Peak' END AS period,
  COUNT(*) AS orders,
  ROUND(AVG(total_fulfillment_time_min), 2) AS avg_time,
  ROUND(AVG(sla_breached)*100, 1) AS sla_pct,
  ROUND(AVG(stockout_flag)*100, 1) AS stockout_pct
FROM orders 
GROUP BY period;
```
*Business Value:* Isolates peak-hour as the primary SLA failure driver. Justifies targeted staffing investment during specific windows rather than blanket headcount increases.

**3. Diagnostic Analytics (JOIN across two tables)**
```sql
SELECT 
  o.store_id, o.category,
  ROUND(AVG(o.stockout_flag)*100, 1) AS stockout_pct,
  i.current_stock, i.max_capacity, i.below_reorder
FROM orders o
JOIN inventory i ON o.store_id = i.store_id AND o.category = i.category
GROUP BY o.store_id, o.category, i.current_stock, i.max_capacity, i.below_reorder
ORDER BY stockout_pct DESC;
```
*Business Value:* Connects order-level stockout incidents to actual inventory positions. Enables root cause analysis — is stockout driven by low stock or high demand velocity?A key diagnostic query within the project that links operational outcomes with inventory conditions. .

**4. Composite Store Risk Ranking**
```sql
SELECT store_id,
  AVG(sla_breached)*100 AS breach_pct,
  AVG(stockout_flag)*100 AS stockout_pct,
  AVG(cancelled_flag)*100 AS cancel_pct
FROM orders 
GROUP BY store_id
ORDER BY breach_pct DESC;
```
*Business Value:* Multi-dimensional store ranking that Operations Head can use to prioritize site visits and intervention resources.

**5. Executive KPI Dashboard**
```sql
SELECT 
  COUNT(*) AS total_orders,
  SUM(revenue_inr) AS total_revenue,
  AVG(revenue_inr) AS avg_order_value,
  AVG(sla_breached)*100 AS sla_pct,
  AVG(stockout_flag)*100 AS stockout_pct,
  AVG(cancelled_flag)*100 AS cancel_pct,
  AVG(customer_rating) AS avg_rating
FROM orders;
```
*Business Value:* Single-query network health check. Can be scheduled as a daily automated report.

**Why SQL over Excel for this analysis?**
Excel pivot tables require manual refresh, cannot join tables, and break on datasets above ~100K rows. SQL provides: (1) repeatable logic on any data load, (2) multi-table joins that Excel cannot perform, (3) parameterisable queries for dynamic date ranges, and (4) a foundation for BI tool connections.

---

##  Python Analysis

Three notebooks are available in `/notebooks/`.

### Notebook 1: EDA & Business Health
**Libraries used:** pandas, numpy, matplotlib, seaborn

Key analyses:
- Revenue distribution across stores and categories — confirms near-equal distribution, ruling out volume concentration as a risk factor
- Fulfillment time stage breakdown: Pick (7.5 min avg) → Pack (3.0 min) → Dispatch (2.0 min) → Delivery (20.3 min). Delivery dominates total time (62% of fulfillment), but pick time is the only stage within direct store control.
- SLA breach vs. customer rating: Orders breaching SLA average 3.2/5 vs. 4.5/5 for on-time orders. The observed 1.3-point rating gap suggests a meaningful relationship between fulfillment reliability and customer satisfaction.
- Cancellation patterns by category and store

### Notebook 2: Operations Analytics
**Key output: Composite Store Risk Score**

Risk Score = (SLA Breach % × 50) + (Stockout % × 30) + (Cancellation % × 20)

Weight justification:
- SLA breach carries 50% weight because it directly impacts customer rating and retention
- Stockout carries 30% weight because it drives both cancellations and lost revenue
- Cancellation carries 20% weight because it is a downstream outcome, partially captured by the other two metrics

Store risk ranking by composite score:
1. DS_Pune_Kothrud — highest stockout (15.8%) + highest cancel rate (6.6%)
2. DS_Mumbai_Andheri — highest SLA breach (63.4%) + above-average stockout (15.5%)
3. DS_Mumbai_BKC — highest cancellation rate (6.5%) + SLA breach at 63.0%
4. DS_Bangalore_Koramangala — slightly above average on all three metrics
5. DS_Hyderabad_Hitech — relative best performer across all three dimensions

### Notebook 3: Executive Insights & Scenario Analysis
**Scenario: 20% Demand Growth**

At the current average of ~68.5 orders per store per day, a 20% increase projects to ~82 orders per store per day across the network. Given that peak-hour SLA breach already reaches 95.2% at current volume, DS_Mumbai_Andheri and DS_Pune_Kothrud would likely experience additional SLA pressure under higher order volumes without corresponding fulfillment capacity expansion.
1. Immediate: Reorder Personal Care at DS_Pune_Kothrud, DS_Bangalore_Koramangala, DS_Delhi_Lajpat, DS_Mumbai_BKC
2. Immediate: Reorder Beverages at DS_Mumbai_Andheri and DS_Bangalore_Whitefield
3. Short-term: Add dedicated picker during peak hours at DS_Mumbai_Andheri (63.4% SLA breach)
4. Short-term: Investigate Frozen category SLA breach (63.6% — highest in network)
5. Strategic: DS_Pune_Kothrud requires operational audit before any demand growth is absorbed

---

##  Core Operations KPIs

| KPI | Value | Formula | Benchmark | Executive Use Case |
|---|---|---|---|---|
| Total Orders | 25,000 | COUNT(order_id) | Scale baseline | Network capacity planning |
| Total Revenue | ₹2.42 Cr | SUM(revenue_inr) | P&L baseline | Financial performance tracking |
| Average Order Value | ₹966 | SUM(revenue) / COUNT(orders) | Q-commerce: ₹400–₹1,200 | Basket optimization |
| SLA Breach % | 62.8% | SUM(sla_breached) / COUNT(orders) | Target: <20% | Primary operational health metric |
| Stockout % | 15.2% | SUM(stockout_flag) / COUNT(orders) | Target: <5% | Inventory planning KPI |
| Cancellation % | 6.1% | SUM(cancelled_flag) / COUNT(orders) | Target: <3% | Customer experience / revenue leak |
| Avg Customer Rating | 3.89 / 5 | AVG(customer_rating) | Target: >4.2 | NPS proxy |
| Peak Hour SLA Breach | 95.2% | SUM(sla_breached WHERE peak=1) / COUNT | Compared to off-peak 42.4% | Staffing prioritization |
| Fulfillment Time | 32.85 min avg | AVG(total_fulfillment_time_min) | 30-min SLA | SLA compliance driver |
| Inventory Below Reorder | 11 / 56 SKUs | COUNT(below_reorder=1) | Target: 0 | Supply chain alert |

---

##  Store Performance Analysis

**Best Performing Store:** DS_Hyderabad_Hitech
- Lowest SLA breach rate: 62.4%
- Lowest stockout rate: 14.4%
- Highest average turnover rate: 9.14 (fastest inventory velocity)
- Only 1 category below reorder point

**Highest Risk Store:** DS_Pune_Kothrud
- Highest order volume: 3,243 orders (12.97% of network)
- Highest revenue: ₹30.97L — meaning disruptions here have maximum financial impact
- Highest stockout rate: 15.8%
- Highest cancellation rate: 6.6%
- 2 categories below reorder point (Personal Care, Staples)

**Peak Hour Impact:**
- Peak hours generate 95.2% SLA breach rate vs. 42.4% during off-peak
- Average fulfillment time during peak: ~39 min vs. ~29 min off-peak
- This 10-minute gap is entirely driven by pick station bottlenecks

---

##  Inventory Analysis

**Network-wide stock summary:**
- Total SKUs tracked: 56 (8 stores × 7 categories)
- Below reorder point: 11 (19.6% of all SKUs)
- Total inventory units across network: 44,378

**Highest risk categories:**
- Personal Care: 4 stores below reorder; 4,879 total units across network
- Snacks: 2 stores below reorder; 6,796 units but DS_Delhi_Lajpat and DS_Hyderabad_Hitech critical
- Staples: 2 stores below reorder; 5,904 units but DS_Bangalore_Koramangala (116 units) and DS_Pune_Kothrud (290 units) are alarmingly low

**Lowest risk categories:**
- Dairy: 8,199 total units; 0 stores below reorder
- Frozen: 5,595 units; 0 stores below reorder (despite 63.6% SLA breach — suggesting SLA issue is pick time, not availability)

---

##  Tableau Dashboard

Tableau dashboard is currently under development.

Planned dashboards:
- **Network Operations Overview** — real-time KPI tiles for COO review
- **Store Comparison Matrix** — side-by-side scorecard for 8 stores
- **Inventory Risk Heatmap** — 8×7 store-category grid with color-coded reorder flags
- **Peak Hour Performance Chart** — hourly SLA breach rate trend
- **City Revenue Map** — geographic revenue distribution

`[Screenshot: Network KPI Dashboard]`
`[Screenshot: Store Risk Matrix]`
`[Screenshot: Inventory Heatmap]`

---

##  Key Insights

**HIGH IMPACT**

1. **SLA breach crisis:** 62.8% of all 25,000 orders breached SLA. At ₹966 AOV, this means 15,703 customers experienced a late delivery — a potential customer retention risk, not an operational anomaly.

2. **Peak hours collapse fulfillment:** During peak hours, SLA breach rate reaches 95.2% vs. 42.4% off-peak. Peak-hour performance deteriorates significantly during the highest-demand windows, with SLA breach rates increasing to 95.2%.

3. **Pick time is the primary bottleneck:** Average pick time is 7.5 minutes out of a 30-minute SLA. Delivery accounts for 20.3 minutes (62%) of total time but is outside direct store control. Pick time is the only lever available at the store level.

4. **11 store-category SKUs are below reorder:** These represent active stockout risk. DS_Bangalore_Koramangala's Staples stock is 116 units against a max capacity of 686 — critically exposed.

5. **Personal Care is the most vulnerable category:** Highest stockout rate (15.7%), 4 stores below reorder point, and moderate SLA breach (63.5%). A single demand spike could trigger network-wide shortages.

**MEDIUM IMPACT**

6. **SLA breach destroys ratings:** On-time orders average 4.5/5; breached orders average 3.2/5. This 1.3-point gap is directly measurable and predictable — On-time fulfillment appears to be a major driver of customer experience based on observed rating differences.

7. **DS_Mumbai_Andheri leads SLA breaches:** At 63.4%, it is the worst-performing store on SLA. Combined with above-average stockout (15.5%), this store needs immediate operational intervention.

8. **Pune_Kothrud's cancellation rate is the network high at 6.6%:** Cancellations translate directly to lost revenue. At 3,243 orders and 6.6% cancel rate, approximately 214 orders per period are lost after placement.

9. **Delhi and Mumbai together account for ₹1.21 Cr (50.1%) of network revenue:** These two cities should receive first-priority inventory allocation and operational investment.

10. **Frozen category has the second-highest SLA breach rate (63.6%) but zero stores below reorder:** The SLA failure is not an availability issue — it is a pick-time and cold-chain handling issue.

**LOW IMPACT**

11. **Revenue is well-distributed across stores:** Range of ₹29.3L–₹30.97L suggests no single store is carrying disproportionate volume risk.

12. **Average fulfillment time is 32.85 minutes — just 2.85 minutes over a 30-minute SLA target:** The problem is not catastrophic overruns but systematic marginal delays, making small process improvements high-ROI.

13. **Beverages has the worst combined SLA breach (63.7%) and significant stockout risk (2 stores critical):** This category may benefit from pre-positioned secondary stock during peak windows.

14. **DS_Hyderabad_Hitech maintains the highest inventory turnover rate (9.14):** Its fast-moving inventory explains both low stockout rates and relatively better SLA performance — a model for other stores.

15. **Customer rating range is narrow (3.88–3.90 across stores):** The ceiling is low. No store is delivering a meaningfully differentiated experience, which means the entire network has rating improvement headroom.

---

##  Strategic Recommendations

| # | Action | Expected Impact | Owner | Priority | Risk |
|---|---|---|---|---|---|
| 1 | Emergency reorder for 11 below-reorder store-category SKUs (Personal Care at 4 stores, Beverages at 2 stores, Staples at 2 stores) | Eliminates active stockout risk; could reduce stockout rate from 15.2% to ~10% | Supply Chain / Store Managers | 🔴 Critical | Stock-out between order placement and delivery arrival |
| 2 | Add dedicated pick station resource at DS_Mumbai_Andheri and DS_Pune_Kothrud during peak hours (defined as 8–10am, 12–2pm, 7–9pm) | Targeted reduction of pick time from 7.5 min to ~5 min; expected to reduce pick times and improve peak-hour SLA performance. | City Operations Manager | 🔴 Critical | Requires headcount approval; short-term cost increase |
| 3 | Freeze demand growth at DS_Mumbai_Andheri and DS_Pune_Kothrud until operational improvements are confirmed | Prevents SLA collapse under 20% demand growth scenario | Strategy / City Head | 🟠 High | Revenue opportunity cost in short term |
| 4 | Implement category-specific pick-path optimization for Frozen (63.6% SLA breach) — move Frozen SKUs closer to dispatch area | Potential reduction in pick time through improved SKU placement and shorter picker travel distances. Expected outcome is improved fulfillment efficiency for Frozen-category orders, subject to operational validation. | Store Ops / Layout Manager | 🟠 High | Requires physical relayout; one-time disruption |
| 5 | Set automated reorder alerts at 130% of reorder point (not 100%) for Personal Care and Beverages network-wide | Earlier trigger prevents stock depletion before next delivery cycle | Supply Chain | 🟠 High | Marginally higher average inventory carrying cost |
| 6 | Prioritize Mumbai and Delhi for inventory buffer stock build (these cities = 50.1% of network revenue) | Protects revenue concentration; reduces cancellation risk at highest-value nodes | Supply Chain + Finance | 🟡 Medium | Higher warehouse holding cost |
| 7 | Conduct operational audit at DS_Hyderabad_Hitech to understand why it outperforms peers (62.4% SLA, 14.4% stockout) | Document and replicate best practices network-wide | Head of Operations | 🟡 Medium | Requires 1–2 days of analyst time |
| 8 | Establish weekly store-level SLA and stockout review cadence with Operations Heads | Creates accountability structure; enables early detection of deteriorating stores | COO / City Ops | 🟢 Ongoing | None — process only |

---

##  Operations Improvement Roadmap

### Short-Term (0–3 Months)
- Emergency reorder of 11 critical store-category SKUs
- Dedicated peak-hour picker deployment at DS_Mumbai_Andheri and DS_Pune_Kothrud
- Automated reorder alert system set at 130% of reorder point
- Weekly KPI review cadence launched for all 8 store managers

### Medium-Term (3–6 Months)
- Pick-path optimization for Frozen category across all stores
- DS_Hyderabad_Hitech best-practice playbook development and rollout
- Tableau live dashboard connected to operational data for daily monitoring
- City-level inventory buffer policy implemented for Mumbai and Delhi

### Long-Term (6–12 Months)
Potential future enhancement: ML-based demand forecasting to identify elevated stockout risk and demand surges up to 48 hours in advance.
- Dynamic SLA window adjustment by time of day and store capacity
- Network-wide pick-time reduction target of <5 minutes through layout optimization
- Customer rating recovery program targeting >4.2 network average

---

##  Repository Structure

```
dark-store-ops-simulator/
│
├── README.md
│
├── data/
│   ├── orders.csv
│   └── inventory.csv
│
├── excel/
│   └── Dark_Store_Ops_Simulator.xlsx
│
├── sql/
│   └── dark_store_queries.sql
│
├── notebooks/
│   ├── 01_EDA_Business_Health.ipynb
│   ├── 02_Operations_Analytics.ipynb
│   └── 03_Executive_Insights_Scenario.ipynb
│
├── outputs/
│   ├── store_scorecard.png
│   ├── sla_breach_by_store.png
│   ├── fulfillment_stage_breakdown.png
│   ├── inventory_risk_matrix.png
│   └── peak_hour_performance.png
│
└── tableau/
    └── [Dashboard in progress]
```
---
MIT License — free to use, adapt, and reference with attribution.
---

Project by Sumit Kumar Gupta

[LinkedIn](https://www.linkedin.com/in/sumitgupta-analyst/)

[GitHub](https://github.com/Sumit-kr-Gupta)
