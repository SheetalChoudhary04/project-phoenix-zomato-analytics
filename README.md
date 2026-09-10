# Project Phoenix --- Zomato Product Analytics

**Product Analytics for a Food-Delivery Marketplace**

SQL • MySQL • Python • Power BI

## 📌 Project Overview

Project Phoenix is a product analytics case study focused on
understanding customer acquisition, conversion, ordering behaviour,
retention and restaurant-marketplace characteristics for a food-delivery
platform.

The project combines a **real, publicly sourced Zomato Bangalore
restaurant dataset** with an **explicitly simulated
customer/session/order layer** created for product-analytics practice.

> **Important:** The simulated customer, session and order data is not
> proprietary Zomato data. Findings from this layer represent patterns
> in the simulated dataset and should not be interpreted as actual
> Zomato customer behaviour.

## 🎯 Business Problem

> **How can a food-delivery platform increase second-order conversion
> among first-time customers to improve customer retention and
> revenue?**

## 📊 Project Scale

  Metric                             Value
  ----------------------------- ----------
  Customers                         10,000
  Sessions                        \~30,000
  Orders                             5,903
  Clean restaurants                 41,263
  Restaurant locations                  92
  Cuisine tags                       2,367
  Restaurant types                      87
  Average order value              ₹858.61
  Session-to-order conversion       19.68%

## 🗂️ Data

### Real data

Restaurant-level fields include restaurant name, location, cuisine,
approximate cost for two, rating, votes, online-order availability and
restaurant type.

The original dataset contained **51,717 rows**. After cleaning and
selecting the analytical fields, **41,263 rows** were loaded for
analysis with no missing values in the retained fields.

### Simulated behavioural data

Python was used to generate customers, sessions and orders. The
simulated layer was designed with stage-wise funnel drop-offs and
internally consistent relationships for product-analytics practice.

## 🏗️ Data & Analysis Workflow

``` text
Data Sources
     ↓
Data Cleaning & Preparation
     ↓
MySQL Database
     ↓
SQL Analysis
     ↓
Power BI Dashboard
```

## 🔍 Analysis Performed

### 1. Acquisition Analysis

Compared acquisition channels on order volume, revenue, session-to-order
conversion and repeat-order behaviour.

### 2. Customer Funnel

**30,000 sessions → 26,944 restaurant views → 12,065 cart additions →
7,885 checkouts → 5,903 orders**

Overall session-to-order conversion was **19.68%**.

The largest funnel bottleneck was the **restaurant-view → add-to-cart**
stage, where only **44.8%** of restaurant viewers added an item to cart.

### 3. Retention Analysis

-   **72.44%** of ordering customers were one-time customers.
-   **27.56%** placed repeat orders.
-   Repeat customers generated **45.12% of revenue**.

This made first-to-second-order conversion the strongest product
opportunity identified in the analysis.

### 4. Restaurant Marketplace Analysis

The restaurant dataset was analysed across location, restaurant type,
cuisine, price, rating, votes and online-order availability.

**65.68% of restaurants offered online ordering**, while **34.32% did
not**.

## 💡 Key Insights

-   The biggest funnel opportunity occurs between **restaurant viewing
    and cart addition**.
-   A relatively small share of repeat customers contributes a
    disproportionately large share of revenue: **27.56% of ordering
    customers → 45.12% of revenue**.
-   Conversion rates across acquisition channels are relatively close,
    suggesting that funnel improvement may have greater leverage than
    acquisition volume alone.
-   Online-order adoption is widespread but uneven across the restaurant
    marketplace.
-   Higher vote volumes are associated with higher average ratings
    across popularity buckets, but individual restaurant popularity does
    not guarantee a higher rating.

## 🚀 Product Recommendations

1.  **Improve first-to-second-order conversion**
    -   Post-first-order re-engagement
    -   Targeted second-order incentives
    -   Personalized restaurant/cuisine recommendations
2.  **Reduce restaurant-view → cart friction**
    -   Improve restaurant information and menu clarity
    -   Make ratings/reviews, delivery ETA and pricing more transparent
    -   Improve personalized restaurant discovery
3.  **Evaluate acquisition channels using multiple metrics**
    -   Compare order volume, conversion and repeat behaviour rather
        than orders alone.
4.  **Improve restaurant discovery**
    -   Combine rating and review volume rather than relying on a single
        quality signal.

## 📊 Power BI Dashboards

### Dashboard 1 --- Customer & Order Performance

Includes KPI cards, acquisition-channel analysis, conversion funnel,
order/revenue trends, conversion rate by channel and order distribution
by rating.

### Dashboard 2 --- Restaurant Marketplace Analysis

Includes restaurant distribution by location, restaurant rating vs
votes, restaurant cost vs rating and online-order availability.

## 🛠️ Tools Used

  Tool                     Purpose
  ------------------------ --------------------------------------------------------------
  Python (Pandas, NumPy)   Data cleaning and simulation
  MySQL                    Relational database and SQL analysis
  SQL                      KPI, funnel, acquisition, retention and marketplace analysis
  Power BI                 Dashboarding, DAX and visualization
  GitHub                   Project documentation and version control

## ⚠️ Limitations

-   Customer, session and order data is simulated and cannot establish
    real Zomato customer behaviour.
-   The analysis is descriptive/associative rather than causal.
-   Dashboard figures are rounded for display; underlying calculations
    were used for exact values.
-   Restaurant cuisine counts are tag-level, so a restaurant may appear
    under multiple cuisine categories.

## 🔮 Future Work

With real event-level marketplace data, the project could be extended to
cohort retention, A/B testing of second-order interventions,
churn/reorder propensity modelling, cancellation and delivery analysis,
and more granular customer-journey analysis.

## 📁 Repository Structure

``` text
project-phoenix/
│
├── README.md
├── PowerBI/
│   └── Zomato_Product_Analytics.pbix
├── Report/
│   └── Zomato_Product_Analytics_Report.pdf
├── Dashboard/
│   ├── dashboard_customer_order.png
│   └── dashboard_restaurant_marketplace.png
├── SQL/
│   └── analysis_queries.sql
└── Data/
    └── README.md
```

**Note:** Raw datasets are not included unless redistribution rights
allow it.

## 👤 Author

**Sheetal**\
B.Tech Chemical Engineering, IIT Gandhinagar\
Product Analytics Portfolio Project

