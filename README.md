# Dark Store Operations Simulator

**A full-stack operations analytics project analyzing 25,000 orders across an 8-store, 5-city quick-commerce dark store network — SQL for diagnosis, Python for statistical validation, Excel for stakeholder reporting.**

> SLA breach 62.8% → root-caused to peak-hour demand (not store mismanagement) → costed, ROI-tested recommendations, including one that was rejected for negative ROI.

---

## Table of Contents
1. [Executive Summary](#1-executive-summary)
2. [Business Problem](#2-business-problem)
3. [Business Context](#3-business-context)
4. [Operations Context](#4-operations-context)
5. [Objectives](#5-objectives)
6. [Key Business Questions](#6-key-business-questions)
7. [Dataset Overview](#7-dataset-overview)
8. [Data Architecture](#8-data-architecture)
9. [Technology Stack](#9-technology-stack)
10. [SQL Analysis](#10-sql-analysis)
11. [Python Analysis](#11-python-analysis)
12. [Excel Dashboard](#12-excel-dashboard)
13. [Tableau Dashboard](#13-tableau-dashboard)
14. [Operational KPI Framework](#14-operational-kpi-framework)
15. [Analytical Methodology](#15-analytical-methodology)
16. [Business Insights](#16-business-insights)
17. [Operational Bottlenecks](#17-operational-bottlenecks)
18. [Executive Recommendations](#18-executive-recommendations)
19. [Operational Impact](#19-operational-impact)
20. [Business Value](#20-business-value)
21. [Folder Structure](#21-folder-structure)
22. [Repository Structure Notes](#22-repository-structure-notes)
23. [Key Skills Demonstrated](#23-key-skills-demonstrated)
24. [Challenges & Assumptions](#24-challenges--assumptions)
25. [Future Enhancements](#25-future-enhancements)
26. [Screenshots](#26-screenshots)
27. [How to Run This Project](#27-how-to-run-this-project)
28. [Conclusion](#28-conclusion)
29. [Relevant Roles](#29-relevant-roles)

---

## 1. Executive Summary

This project simulates one year of operations for a quick-commerce dark store network — 8 stores across 5 Indian cities, 25,000 orders, ₹2.42 crore in revenue — and asks the questions a COO or Head of Operations would actually ask: *where is the network losing money, why, and what should we fund first?*

The headline finding is not "some stores underperform." It is that a network-wide, chi-square-tested analysis (p > 0.4 across all 8 stores) shows SLA breach is a **peak-hour demand problem**, not a store-management problem — peak-hour orders breach the 30-minute SLA at 95.2% versus 42.4% off-peak, and `is_peak_hour` carries roughly 150x the standardized effect on SLA breach of any store-level staffing variable (logistic regression, ROC-AUC 0.77). That single reframe changes the recommended fix from "coach the underperforming store managers" to "solve peak-hour capacity network-wide."

The project also does something most portfolio projects avoid: it reports a **negative result**. A costed staffing-investment business case (₹45 lakh/year) returns a return on investment of roughly -100% under conservative, transaction-only revenue accounting, so the recommendation is a two-store pilot, not a network rollout — while a ₹94,240 one-time inventory buffer investment, covering all 11 below-reorder store-category gaps, shows a clean +178.9% ROI with a 4.3-month payback and is recommended for immediate approval. Being willing to say "this lever isn't proven yet" is the difference between an analyst who produces charts and one who protects a P&L.

**Scale:** 25,000 orders · 8 stores · 5 cities · ₹24,162,205 in revenue analyzed
**Core findings:** 62.8% SLA breach rate · 15.2% stockout rate · 6.1% cancellation rate · 61.3% of revenue attached to a degraded (breached/stockout) order experience
**Deliverables:** 900+ line diagnostic SQL codebase (12 sections, 4 production views) · 3 Python notebooks covering EDA, root-cause statistics, and executive scenario modeling · a stakeholder-ready Excel workbook · a Tableau dashboard (in progress)

---

## 2. Business Problem

Quick-commerce economics depend on one operational promise: delivery within a committed SLA window (30 minutes in this network). Every SLA breach, stockout, or cancellation is a customer-trust event with a direct revenue consequence — and at scale, small per-order failure rates compound into a material share of network revenue.

At the point this analysis begins, the network is failing that promise on a majority of orders (62.8% SLA breach), and leadership does not yet know whether this is a *store execution* problem, a *demand/staffing* problem, or an *inventory* problem — three failure modes that call for three completely different capital allocations. Spending on the wrong lever is expensive and slow to reverse.

**The business problem this project solves:** diagnose the true root cause of service failure across the network, quantify its revenue impact precisely enough to defend in front of finance, and produce a prioritized, costed investment plan — including telling leadership which levers are *not* yet worth funding.

---

## 3. Business Context

Dark stores are small, hyper-local fulfillment centers designed for 10–30 minute delivery, unlike traditional retail or e-commerce warehouses optimized for cost-per-unit over multi-day windows. That compresses the entire order lifecycle — picking, packing, dispatch, delivery — into a window where a few minutes of delay is the difference between a met SLA and a lost order.

This compression also concentrates operational risk: a stockout that a traditional e-commerce business absorbs by backordering becomes an immediate cancellation in dark store retail, and a staffing shortfall during a demand spike shows up in customer ratings within the hour, not the week. The network modeled here reflects that reality — 5 Indian metro markets, 8 stores, multiple product categories (Staples, Personal Care, and others), and order-level operational telemetry (fulfillment time, SLA breach, stockout, cancellation, customer rating) for every one of 25,000 orders.

---

## 4. Operations Context

The simulated network runs a standard dark store fulfillment pipeline: **order placed → picked → packed → dispatched → delivered**, with each stage timestamped. Two structural constraints shape performance:

- **Peak-hour demand is not evenly distributed.** Order volume spikes at predictable windows, and staffing/inventory capacity does not automatically scale with it — this is the single largest driver of SLA failure identified in the analysis.
- **Inventory is store-local, not pooled.** Each store carries its own stock against its own reorder point, so a stockout in one store's Personal Care aisle is invisible to, and unsolvable by, inventory sitting in another store's warehouse.

Both constraints are treated as operational levers throughout the analysis (staffing allocation, inventory buffer sizing) rather than as background facts — every recommendation in this project is tied to one of them.

---

## 5. Objectives

1. Establish a trustworthy, validated single source of truth for network performance (data quality checks before any KPI is trusted).
2. Diagnose the true root cause of SLA breaches, stockouts, and cancellations — statistically, not anecdotally.
3. Quantify revenue impact precisely enough to separate revenue *fully lost* from revenue merely *at risk*.
4. Rank stores and store-category combinations by investment priority using an evidence-derived (not assumed) weighting scheme.
5. Stress-test the network against a +20% / −20% demand scenario to evaluate capacity readiness for growth.
6. Produce a costed, ROI-tested set of executive recommendations — approving what has positive ROI, piloting what doesn't yet, and flagging data gaps that block certainty.

---

## 6. Key Business Questions

| # | Question | Answered In |
|---|---|---|
| 1 | Is the data clean and trustworthy enough to drive executive decisions? | SQL Section 1, Notebook 1 §4 |
| 2 | What does network health look like at a glance? | SQL Section 2, Notebook 3 §2 |
| 3 | Which cities, categories, and stores drive revenue — and which drive risk? | SQL Sections 3–4, Notebook 1 §8 |
| 4 | Which store-category combinations are at active stockout risk? | SQL Section 5, Notebook 1 §8.6 |
| 5 | How much revenue is *fully lost* vs. merely *at risk*? | SQL Section 6, Notebook 2 §9 |
| 6 | Is SLA failure a store problem or a peak-hour demand problem? | SQL Section 7, Notebook 2 §6–7 |
| 7 | What does it actually cost to serve each store, and which stores are profitable after operational cost is accounted for? | SQL Section 8 |
| 8 | Which stores are statistically high-risk, and is that risk real or noise? | SQL Section 9, Notebook 2 §6 |
| 9 | Can the network absorb 20% demand growth without new investment? | SQL Section 10, Notebook 3 §7–8 |
| 10 | What should leadership fund first, and what is the return on each option? | SQL Section 11, Notebook 2 §12, Notebook 3 §11 |

---

## 7. Dataset Overview

The core relational dataset simulates one year of dark store operations:

| Table | Grain | Key Fields |
|---|---|---|
| `orders` | 1 row per order (25,000 rows) | `order_id`, `store_id`, `city`, `category`, `revenue_inr`, `order_timestamp`, `is_peak_hour`, `sla_breached`, `stockout_flag`, `cancelled_flag`, `customer_rating`, `total_fulfillment_time_min`, `pick_time_min`, `pack_time_min`, `dispatch_time_min` |
| `inventory` | 1 row per store-category | `store_id`, `category`, `current_stock`, `max_capacity`, `below_reorder` |
| `deliveries` | 1 row per delivery | `order_id`, `distance_km`, delivery-stage timing (used as an independent cross-check on SLA drivers) |

Full field-level definitions, types, and business meaning are documented in [`docs/Data_Dictionary.md`](docs/Data_Dictionary.md).

---

## 8. Data Architecture

```
Raw Operational Data (orders, inventory, deliveries)
            │
            ▼
   SQL Diagnostic Layer  ──►  4 production views
   (validation → KPIs →       (STORE_SCORECARD_VIEW,
    root cause → views)        EXECUTIVE_KPI_VIEW,
            │                  STORE_CATEGORY_RISK_VIEW,
            │                  REVENUE_LOSS_VIEW)
            ▼
   Python Analytical Layer
   NB1 EDA & Data Quality → NB2 Statistical Root-Cause
   & Costed Recommendations → NB3 Predictive Risk Scoring
   & Scenario Simulation
            │
            ▼
   Reporting Layer
   Excel (stakeholder workbook)  +  Tableau (executive dashboard, in progress)
```

Design intent: SQL owns *diagnosis and validated views*, Python owns *statistical proof and scenario modeling*, Excel/Tableau own *stakeholder consumption*. No layer duplicates another's job.

---

## 9. Technology Stack

| Layer | Tools |
|---|---|
| Data Storage & Querying | MySQL |
| Statistical & Predictive Analysis | Python (pandas, NumPy, statsmodels, scikit-learn, SciPy) |
| Visualization (analysis) | Matplotlib, Seaborn |
| Business Reporting | Microsoft Excel (pivot-based scorecards, executive dashboard) |
| Executive Dashboard | Tableau *(in progress)* |
| Version Control | Git / GitHub |

---

## 10. SQL Analysis

`sql/dark_store_ops.sql` (908 lines) is organized as a 12-section diagnostic build, each with a stated business goal and business questions answered before the code:

1. **Database Setup** — table existence and row-count sanity checks
2. **Data Validation & Data Quality** — duplicate orders, orphaned store-category references, inventory records where stock exceeds capacity, missing/non-positive revenue
3. **Executive Business Snapshot** — single-query network KPI dashboard
4. **Order & Revenue Intelligence** — revenue by city, category, and month
5. **Store Performance Intelligence** — full store scorecard (orders, revenue, SLA, stockout, cancel, rating)
6. **Inventory & Stockout Intelligence** — category risk, reorder-point breaches, store-category combinations needing emergency replenishment
7. **Revenue Loss & Risk Intelligence** — revenue lost vs. at-risk, broken down by exact cause (stockout only / cancelled only / both)
8. **Peak-Hour & Staffing Intelligence** — peak vs. off-peak stress comparison, a picker-staffing priority score
9. **Cost & Profitability Intelligence** — a transparent, documented cost-to-serve proxy and contribution margin by store (built from operational cost drivers since neither source table carries a direct cost field — swappable for finance-confirmed unit costs)
10. **Advanced Analytics & AI Model Inputs** — a statistically-flagged high-risk store dataset (mean + 1 standard deviation threshold), a daily demand dataset for forecasting, and a peak-demand-vs-capacity dataset
11. **Demand Scenario & Capacity Planning** — a +20% demand projection by store, translated into projected peak-hour pressure
12. **Diagnostics & Executive Recommendations** — a `CASE`-driven root-cause classifier per store-category, a prioritized per-store recommendation engine, and a weekly trend snapshot for monitoring drift

**Reusable views** (Section 12) package the four most-queried outputs — `STORE_SCORECARD_VIEW`, `EXECUTIVE_KPI_VIEW`, `STORE_CATEGORY_RISK_VIEW`, `REVENUE_LOSS_VIEW` — so BI tools can consume clean, pre-aggregated data without re-deriving logic.

---

## 11. Python Analysis

Three notebooks, each with a distinct job — deliberately not three notebooks doing the same EDA three ways.

**`01_EDA_and_Business_Health.ipynb`** — Data trust and business shape.
Data quality checks (missing values, duplicates, referential integrity, cross-file join feasibility), a Python-vs-SQL KPI cross-check (so the two codebases are proven to agree before either is trusted), distribution analysis, city/category/store performance breakdowns, a fulfillment pipeline stage breakdown, peak vs. off-peak comparison, and a correlation heatmap across KPIs. Closes with a 10-finding data-derived executive summary.

**`02_Operations_Analytics.ipynb`** — Root cause and ROI.
Replaces an assumed 50/30/20 risk-score weighting with evidence-derived weights (~92/5/3) after showing SLA breach dominates customer rating impact by two independent methods; runs a Monte Carlo stress test (2,000 trials) on store rankings to separate robust flags from noise; runs chi-square tests showing store-level differences in SLA/stockout/cancellation are *not* statistically significant (p > 0.4) — reframing the fix from store-specific to network-wide; fits a logistic regression showing peak-hour status has ~150x the standardized effect of any staffing variable on SLA breach (AUC 0.77); cross-validates rule-based and k-means store segmentation (75% agreement); and produces a costed, prioritized recommendation engine that includes a lever with negative ROI at scale.

**`03_Executive_Insights_and_Scenario_Analysis.ipynb`** — Prediction and scenario planning.
Builds a weighted composite store risk score with explicitly documented business-priority weights; runs a non-ML 7-day moving average demand forecast with day-of-week/hour-of-day seasonality; fits a logistic regression to predict stockouts *before* they happen using only pre-order information; runs a +20%/−20% demand stress test with stated methodology; builds a capacity planning model translating projected order volume into additional staff required; and closes with an executive KPI simulator and a full cost/benefit/ROI/payback business case generator.

Methodological choices — cost-proxy construction, SLA definition cross-checks, non-ML forecasting rationale — are stated in-notebook and expanded in [`docs/Analysis_Methodology.md`](docs/Analysis_Methodology.md).

---

## 12. Excel Dashboard

`excel/Dark_Store_Operations_Simulator.xlsx` is the stakeholder-facing companion to the SQL/Python analysis: a raw `Orders` data sheet (25,000 rows), a `KPI` summary sheet, `Store Performance` and `Store_Scorecard` sheets, `City Analysis` and `Category Analysis` breakdowns, an `Inventory Analysis` sheet, and a one-page `Executive Dashboard` sheet designed to be read in under a minute — mirroring the SQL `EXECUTIVE_KPI_VIEW` and `STORE_SCORECARD_VIEW` outputs so a non-technical stakeholder gets the same numbers without opening a query tool.

---

## 13. Tableau Dashboard

**Status: In Progress.**

A Tableau executive dashboard is being built on top of the SQL views (`EXECUTIVE_KPI_VIEW`, `STORE_SCORECARD_VIEW`, `STORE_CATEGORY_RISK_VIEW`) to give leadership a live, filterable version of the Excel Executive Dashboard sheet — store-level drill-down, city/category filters, and a revenue-loss waterfall. Screenshots and a published workbook link will be added here on completion.

---

## 14. Operational KPI Framework

| KPI | Definition | Why It Matters |
|---|---|---|
| SLA Breach Rate | % of orders exceeding the 30-minute fulfillment window | Primary service-quality metric; directly correlated with customer rating (r = -0.51) |
| Stockout Rate | % of orders affected by a stocked-out item | Leading indicator of lost/cancelled revenue |
| Cancellation Rate | % of orders cancelled | Realized revenue loss |
| Revenue Fully Lost | Revenue from orders with *both* a stockout and cancellation | The number that's already gone |
| Revenue At Risk | Revenue from orders with an SLA breach that survived (not cancelled/stocked out) | The number that predicts *future* churn if unaddressed |
| Cost-to-Serve Proxy | Operational cost estimate from SLA penalty + stockout rework + cancellation waste + fulfillment-time labor | Store profitability, pending finance-confirmed unit costs |
| Contribution Margin Proxy | Revenue − Cost-to-Serve Proxy | Store-level profitability ranking |
| Capacity Utilization | Current stock ÷ max capacity | Inventory risk and replenishment prioritization |
| Risk Score | Weighted composite of SLA breach, stockout, and cancellation rate | Store investment prioritization (weights are evidence-derived, not assumed) |

Full definitions and calculation logic: [`docs/Operational_KPI_Definitions.md`](docs/Operational_KPI_Definitions.md).

---

## 15. Analytical Methodology

The analysis deliberately follows a **validate → describe → diagnose → predict → simulate** progression rather than jumping straight to conclusions:

1. **Validate** — no KPI is reported until the underlying data passes duplicate, referential-integrity, and range checks (SQL Section 1 / Notebook 1 §4), and Python-derived KPIs are cross-checked against SQL-derived KPIs for agreement.
2. **Describe** — distribution analysis and city/category/store breakdowns establish *what* is happening before *why* is investigated.
3. **Diagnose** — statistical tests (chi-square for store-level significance, logistic regression for driver attribution, correlation analysis for SLA-rating linkage) separate real effects from noise, replacing assumed risk-score weights with evidence-derived ones.
4. **Predict** — a logistic regression flags high-stockout-risk orders pre-emptively; a non-ML seasonal moving average forecasts demand without overfitting to a small dataset.
5. **Simulate** — a +20%/−20% demand stress test and a capacity planning model translate diagnosis into a forward-looking, costed investment plan.

Full methodology, including every stated assumption: [`docs/Analysis_Methodology.md`](docs/Analysis_Methodology.md).

---

## 16. Business Insights

- **SLA breach (62.8% overall) is a peak-hour capacity problem, not a store-management problem.** Peak-hour breach rate (95.2%) dwarfs off-peak (42.4%), and store-level differences in SLA/stockout/cancellation are not statistically significant (chi-square, p > 0.4 across all 8 stores).
- **Reliability, not order value, drives customer satisfaction.** Customer rating correlates negatively with SLA breach (r = -0.51); delivery distance independently correlates with SLA risk (r = 0.71) in the separate deliveries dataset — two independent data sources point the same direction.
- **Failures compound, they don't add.** Orders with both a stockout and an SLA breach cancel at a materially higher rate than orders with either issue alone.
- **The "revenue lost" number understates urgency.** Only 6.1% of revenue is directly lost to cancellation today, but 61.3% of revenue is attached to a degraded (breached or stocked-out) order — the number that should drive investment urgency.
- **Delivery is the single slowest pipeline stage** (avg. 20.3 minutes), making it the highest-leverage target for process improvement ahead of picking or packing.
- **Inventory root-cause analysis is currently inconclusive by data design, not by a dead end** — `below_reorder` is a single point-in-time snapshot with ~zero measurable relationship to a full year of stockouts; this is flagged as a data-collection gap, not a finding to act on yet.

---

## 17. Operational Bottlenecks

| Bottleneck | Evidence | Consequence |
|---|---|---|
| Peak-hour staffing capacity | 95.2% peak SLA breach vs. 42.4% off-peak; peak-hour status has ~150x the standardized effect on breach vs. any staffing variable (AUC 0.77) | Majority of network SLA failure concentrated in predictable demand windows |
| Delivery stage duration | Highest average time of any pipeline stage (20.3 min) | Largest single lever for cutting total fulfillment time |
| Store-category inventory gaps | 11 store-category combinations below reorder point | Localized stockout risk that pooled inventory can't solve |
| Inventory snapshot timing | Single point-in-time `below_reorder` flag vs. year-long order data | Blocks a statistically defensible inventory root-cause conclusion |
| Personal Care category | Highest revenue loss from stockouts of any category | Concentrated, addressable reorder-point fix |

---

## 18. Executive Recommendations

Every recommendation below is costed and, where the data supports it, ROI-tested — including the one rejected at current scope.

1. **Approve: Inventory buffer top-up, network-wide.** ₹94,240 one-time cost to clear all 11 below-reorder store-category gaps, against ₹1.47M in stockout-driven revenue loss. Modeled ROI: **+178.9%, 4.3-month payback.** The only lever in this dataset with a clean, positive, revenue-justified ROI — recommend immediate approval.
2. **Pilot, don't scale: Peak-hour staffing at the top 2 statistically-flagged high-risk stores** (DS_Mumbai_Andheri, DS_Pune_Kothrud). Network-wide staffing shows a strongly-evidenced root cause but a **negative ROI (~₹45L cost vs. ~₹18K transaction-only benefit)** under conservative accounting. Recommend a 2-store pilot to capture real before/after data rather than a network rollout.
3. **Fix the inventory data-collection gap.** Move `below_reorder` from a single snapshot to daily instrumentation — a low-cost engineering fix that unblocks a currently-inconclusive but high-priority root-cause question.
4. **Prioritize Personal Care reorder points first** — the category with the highest revenue loss concentration from stockouts.
5. **Commission a customer lifetime value / churn model on the 61.3% "at-risk" revenue segment** before making a network-wide staffing decision — the analysis identifies this as the single highest-leverage next step, likely to flip the staffing lever's ROI from negative to positive.
6. **Plan for +20% demand growth now.** At +20% demand, SLA breach would rise to 74.0% and the network would need approximately 77 additional peak-hour workers — a growth-readiness gap to close before, not after, a demand surge.

---

## 19. Operational Impact

If the inventory buffer recommendation alone is funded, the model projects recovery of a meaningful share of the ₹1.47M currently lost to stockouts at a 4.3-month payback — the fastest, lowest-risk win available in the dataset. Fixing the inventory snapshot-timing gap has a second-order impact: it converts an "inconclusive" root cause into a defensible one, unlocking further investment decisions in future analysis cycles. Piloting (rather than fully funding) peak-hour staffing avoids a ~₹45L commitment to a lever that the data does not yet support at full network scale — itself a protective operational outcome.

---

## 20. Business Value

This project demonstrates the operational discipline a business actually needs from an analytics function: distinguishing signal from noise (chi-square testing before attributing blame to specific stores), separating revenue *already lost* from revenue *at risk* (a distinction that changes urgency framing), and being willing to recommend against a well-evidenced lever when the ROI math doesn't support it yet. The value isn't the dashboard — it's the discipline behind which numbers are trusted enough to act on.

---

## 21. Folder Structure

```
dark-store-operations-simulator/
│
├── README.md
├── sql/
│   └── dark_store_ops.sql
├── notebooks/
│   ├── 01_EDA_and_Business_Health.ipynb
│   ├── 02_Operations_Analytics.ipynb
│   └── 03_Executive_Insights_and_Scenario_Analysis.ipynb
├── excel/
│   └── Dark_Store_Operations_Simulator.xlsx
├── tableau/
│   └── (in progress)
├── screenshots/
│   ├── executive_dashboard.png
│   ├── store_scorecard.png
│   └── sql_views.png
├── data/
│   └── (data dictionary reference — raw data not published; see docs/Data_Dictionary.md)
└── docs/
    ├── Executive_Summary.md
    ├── Business_Problem.md
    ├── Operations_Requirements.md
    ├── Data_Dictionary.md
    ├── Analysis_Methodology.md
    ├── Operational_KPI_Definitions.md
    ├── Business_Insights.md
    ├── Executive_Recommendations.md
    ├── Technical_Documentation.md
    └── Presentation_Guide.md
```

---

## 22. Repository Structure Notes

The repository is intentionally organized by **analytical layer** (SQL → Python → Excel/Tableau), not by role or audience. Each layer's README section links to its actual file so a reviewer can go from claim to code in one click. The `/docs` folder holds detail that would otherwise bloat this README — it expands on, and never duplicates, what's written here.

---

## 23. Key Skills Demonstrated

**Business & Operations Analysis:** root-cause diagnosis, KPI framework design, operational bottleneck identification, capacity planning
**Strategy & Decision Support:** costed recommendation-building, ROI/payback modeling, scenario stress-testing, investment prioritization
**Data Analytics:** SQL (window logic, views, multi-table joins, CASE-based classification), Python (pandas, statsmodels, scikit-learn), statistical testing (chi-square, logistic regression, correlation), data quality validation
**Executive Communication:** translating statistical findings into plain-language, decision-ready recommendations; presenting a negative result honestly rather than hiding it

---

## 24. Challenges & Assumptions

- **No direct cost field exists in the source data.** Cost-to-serve and contribution margin use a transparent, documented cost proxy (SLA breach penalty + stockout rework + cancellation waste + fulfillment-time labor) built from operational cost drivers already present in the data. This is explicitly flagged as swappable for finance-confirmed unit costs — not presented as a precise financial figure.
- **`below_reorder` is a single point-in-time inventory snapshot** against a full year of order-level stockout data, which limits how conclusively inventory can be root-caused. This is treated as a data-collection gap to fix, not glossed over as a finding.
- **The stockout prediction model (ROC-AUC 0.57) is a modest, not strong, classifier** — reported honestly as directionally useful for flagging risk, not as a production-grade prediction system.
- **The staffing ROI figure uses conservative, transaction-only benefit accounting** and does not monetize customer retention or lifetime value — which is exactly why a CLV/churn model is recommended as the next analytical priority rather than assuming the ROI is understated.
- **The +20%/−20% demand scenario is a linear scaling model**, not a full discrete-event simulation — appropriate for directional capacity planning, stated explicitly as a simplification.

---

## 25. Future Enhancements

- Complete and publish the Tableau executive dashboard on top of the existing SQL views.
- Instrument daily (not single-snapshot) inventory data to unblock a statistically defensible stockout root-cause model.
- Build the recommended customer lifetime value / churn model on the at-risk revenue segment to re-test the staffing investment ROI.
- Replace the operational cost proxy with finance-confirmed unit costs once available.
- Extend the demand scenario model from linear scaling to a discrete-event simulation for more granular capacity planning.

---

## 26. Screenshots

*(To be added: Executive Dashboard (Excel), Store Scorecard, SQL view outputs, Tableau dashboard on completion.)*

---

## 27. How to Run This Project

**SQL**
```bash
mysql -u <user> -p < sql/dark_store_ops.sql
```
Requires a MySQL instance with `orders` and `inventory` tables loaded per the schema in `docs/Data_Dictionary.md`.

**Python Notebooks**
```bash
pip install pandas numpy matplotlib seaborn scikit-learn statsmodels scipy
jupyter notebook notebooks/01_EDA_and_Business_Health.ipynb
```
Run notebooks in order (01 → 02 → 03) — each builds on datasets and findings from the previous one.

**Excel**
Open `excel/Dark_Store_Operations_Simulator.xlsx` directly; no setup required.

---

## 28. Conclusion

This project treats "analysis" as a discipline with a burden of proof, not a set of charts. Every headline number here is validated before it's trusted, every recommendation is costed, and one recommendation is explicitly *not* funded at full scale because the ROI math doesn't support it yet. That's the operating standard the project is built to demonstrate.

---

## 29. Relevant Roles

This project's structure naturally maps to several functions, without being built to chase any one of them:

- **Business Analysis / BI:** the SQL diagnostic layer, KPI framework, and Excel stakeholder reporting reflect standard BA/BI deliverables end to end.
- **Operations Analytics:** root-cause diagnosis, bottleneck identification, and capacity/staffing modeling are the core of the project.
- **Strategy & Operations / Founder's Office:** the scenario stress-test, costed recommendation engine, and willingness to reject a low-ROI lever mirror how a strategy or founder's-office analyst is expected to protect capital allocation.
- **Consulting:** the validate → diagnose → recommend structure, explicit assumptions, and executive-summary framing follow a standard consulting deliverable pattern.
- **Data Analytics:** the statistical rigor (chi-square testing, logistic regression, predictive modeling) sits underneath every business claim in the project.

---

*Questions, feedback, or interested in a walkthrough? Open an issue or reach out — happy to talk through any part of the methodology.*
