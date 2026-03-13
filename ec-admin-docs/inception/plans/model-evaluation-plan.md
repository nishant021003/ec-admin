# Model Evaluation Plan – ec_admin

> Note: The current ec_admin application is mostly transactional (CRUD, pricing, orders) and does **not** yet include heavy ML models. This file describes how we would evaluate models once they are introduced (e.g. product recommendations, demand forecasting).

## 1. Candidate Models

- Future examples:
  - Product recommendation model for admin-assist (suggest related products or categories for product combo, cross-sell).
  - Demand forecasting model for stock suggestions (using order history and low-stock alerts).
  - Category or product affinity models to improve product-combo rules.

## 2. Evaluation Datasets

- **Training data**: Historical orders from `orders` and `order_line_items`, product metadata from `products` and `product_categories`, customer segments from `customers`.
- **Validation data**: Held-out time ranges and/or customers.
- **Test data**: Most recent period, never used in training or validation.

## 3. Metrics

- For recommendations:
  - Precision@K, Recall@K, MAP.
- For forecasting:
  - MAE, RMSE, MAPE; separate metrics by product or category group.

## 4. Business-Facing Criteria

- Recommendations must not surface inactive or out-of-stock products (align with `Product` status and `stock_quantity`).
- Forecasts must be stable (no extreme swings) and interpretable by operations.
- Must respect current domain rules (e.g. product combos, coupon eligibility).

## 5. Evaluation Process

- Offline evaluation on historical data before enabling any model in production.
- A/B or shadow testing where model suggestions do not yet change behaviour but are logged.
- Document each evaluation run in `ec-admin-docs/construction/build-and-test/model-validation-report.md`.
