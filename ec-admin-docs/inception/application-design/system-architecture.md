# System Architecture – ec_admin

## 1. High-Level View

- **Presentation**: Rails 8 HTML views (Turbo, Bootstrap 5), admin-only.
- **Application layer**:
  - Controllers under `app/controllers/admin/*`.
  - Service objects in `app/services` for business logic (e.g. `ProductImportService`).
- **Domain & Data**:
  - ActiveRecord models for products, categories, orders, order_line_items, customers, coupons, gift_cards, users, etc.
  - PostgreSQL as the primary data store.
- **Integration**:
  - External consumption via Active Storage URLs for product images.
  - Future REST/GraphQL APIs for other stacks.

## 2. Key Components

- **Product service boundary**
  - Models: `Product`, `Category`, `ProductCategory` (join).
  - Responsibilities: product catalogue, pricing (cents), stock, slug, category hierarchy.
  - Images: Active Storage (`has_many_attached :images`).
- **Order service boundary**
  - Models: `Order`, `OrderLineItem` (supports `is_free_gift`), `Coupon`, `CouponUsage`, `GiftCard`, `GiftCardTransaction`, `ProductCombo`, `ProductComboTrigger`, `ProductComboFreeProduct`.
  - Responsibilities: order lifecycle, applied discounts, coupons, gift cards, product combos (Buy X get Y free).

## 3. Data Flow

- Admin user:
  1. Authenticates via Rails sessions (`admin/sessions`).
  2. Performs CRUD via admin controllers (products, categories, orders, customers, coupons, gift_cards, product_combos, users).
  3. Cart and checkout: session-based cart (`CartSupport`), checkout creates orders and line items.
- Seeds / tasks:
  - `db/seeds.rb` populates admin users, categories, products, customers, orders, coupons, gift cards, product combos.

## 4. Cross-Cutting Concerns

- **Security**
  - Role-based access (Rolify admin role), strong parameters, model validations.
- **Logging**
  - Rails default logging.
- **Code quality**
  - RSpec + SimpleCov, RuboCop, Brakeman compatibility (per test-strategy).

## 5. Deployment

- PostgreSQL as primary store; credentials via `DATABASE_USERNAME`, `DATABASE_PASSWORD`, `EC_ADMIN_DATABASE_PASSWORD` (production) in environment.
- Rails app uses `config/database.yml` with ENV overrides for credentials.
