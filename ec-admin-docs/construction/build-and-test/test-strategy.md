# Test Strategy – ec_admin

## RSpec Coverage Summary

RSpec specs cover:

- **Model specs**: User, Product, Category, Customer, Order, OrderLineItem, Coupon, GiftCard, ProductCombo
- **Service specs**: `ProductImportService` (CSV import, validation errors)
- **Controller specs**: ApplicationController (authenticate_customer!)
- **Request specs**: Admin sessions (incl. unauthenticated redirect), customer sessions (SessionsController), dashboard, products (CRUD, export, import, bulk_action), categories, orders (list, show, update, export), customers, users, coupons, gift cards, product combos, cart, checkout; Locales (switch)

Run tests: `bundle exec rspec` (or `bundle exec rspec --format documentation` for verbose output).

**Line coverage:** Run `COVERAGE=true bundle exec rspec`, then open `coverage/index.html`. Target: ≥ 95%.

## 1. Goals

- Achieve **≥ 95% coverage** on core business logic (models + services).
- Prevent regressions in:
  - Pricing/tax calculations.
  - Order totals, discounts, and gift handling.
  - Product/category status and visibility.
- Ensure that N+1 issues and major performance regressions are caught early.

## 2. Test Types

- **Model specs (RSpec)**
  - Validations and associations.
  - Callbacks (slug/code generation, primary image selection).
  - Scopes (e.g. search, active).

- **Service specs**
  - `ProductImportService` (CSV import, error handling).

- **Request/feature specs**
  - Admin flows for products, categories, and orders:
    - Create/update product (with validation errors); export CSV; import CSV; bulk update/delete.
    - Delete product with and without foreign key constraints (order line items).
    - View order/details; export orders CSV; update order status.
    - Cart and checkout (including free gifts, coupons, gift cards).

- **Task specs**
  - Seeds/backfill rake tasks where practical:
    - Ensure they are idempotent.
    - Validate expected fields after running.

## 3. Tooling

- **RSpec** as the primary framework.
- **SimpleCov** enabled by default:
  - Coverage report in `coverage/index.html`.
  - Optional thresholds via `minimum_coverage` when the team is ready.
- **RuboCop** (Rails + RSpec) for style and simple correctness checks.
- **Brakeman** and security linters as part of CI (where available).

## 4. Test Data Management

- Prefer **FactoryBot** factories over raw `create!` calls.
- Use concise Japanese dummy data aligned with seeds/backfill.
- Keep specs deterministic:
  - Avoid network calls (e.g. to external image hosts).
  - Stub randomness and time when needed.

## 5. Regression & Performance

- Add regression tests whenever a bug is found (especially around pricing or order totals).
- For performance-sensitive endpoints (e.g. product index):
  - Write specs that assert query counts do not exceed an agreed threshold (e.g. using `bullet` or custom expectations).
