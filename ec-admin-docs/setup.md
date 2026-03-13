# EC Admin – Project Setup & Usage Guide

This document describes everything needed to **create, configure, and run** the EC Admin Rails project from a fresh environment, including commands, rules, and behavior implemented so far.

---

## 1. Prerequisites

- **Ruby**: 3.4.x (must match `.ruby-version` if present)
- **Rails**: 8.0.x
- **Bundler**: latest
- **PostgreSQL**: running locally with a user that can create databases
- **Node/Yarn**: *not required* (Rails 8 + importmap are used)
- **Redis / background workers**: not required for basic setup

Ensure you can run:

```bash
ruby -v
rails -v
psql --version
bundle -v
```

---

## 2. Clone and Install Dependencies

From an empty folder:

```bash
git clone <REPO_URL> ec_admin
cd ec_admin

bundle install
```

This installs all gems defined in `Gemfile`, including:

- `rails` 8
- `pg` (PostgreSQL)
- `bcrypt` (password hashing)
- `rolify` (role management)
- `kaminari` (pagination)
- `paper_trail` (audit trail)
- `image_processing` (product images)
- `csv` (standard library for CSV import/export)
- Development / test tools: `rspec-rails`, `factory_bot_rails`, `brakeman`, `rubocop-rails-omakase`, `capybara`, `simplecov`, `overcommit`, etc.

---

## 2.1 Required Gems & Tools

This project assumes the following gems and tools are present:

- **Core application gems**
  - `rails` – Rails 8.x (full-stack)
  - `pg` – PostgreSQL adapter
  - `bcrypt` – secure password hashing for `has_secure_password`
  - `rolify` – role management for admins
  - `kaminari` – pagination for index pages (products, categories, orders, etc.)
  - `paper_trail` – versioning/audit trail for Product, Order, User
  - `image_processing` – Active Storage image variants
  - `csv` – CSV parsing (bundled gem in Ruby 3.4)
- **Testing & factories**
  - `rspec-rails` – RSpec for models, requests, services
  - `factory_bot_rails` – factories for test data
  - `capybara` – feature/system tests
  - `simplecov` – code coverage (≥ 95% target)
- **Code quality, security, and practices**
  - `rubocop-rails-omakase` – RuboCop for Ruby/Rails
  - `rubocop-rspec` – RSpec cops
  - `brakeman` – static security analysis
  - `rails_best_practices` – Rails best-practices checks
  - `overcommit` – Git hooks for lint/test on commit

All new code must be compatible with these tools, must not introduce RuboCop/Brakeman/Rails Best Practices offenses, and should keep coverage high (≥ 95% for business logic).

---

## 3. Database Setup

Create, migrate, and seed the database:

```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

What `db:seed` does:

- Creates **admin users** (admin@example.com, sarah@example.com, john@example.com, test@example.com) with password `Password123!` and the `admin` role.
- Creates **categories** (Electronics, Smartphones, Books, Shoes, Sports & Outdoors, etc.).
- Creates **demo products** with multiple categories (e.g. Apple iPhone 16 Pro, Nike Air Zoom, Sony WH-1000XM5, etc.).
- Creates **customers** and **orders**.
- Creates **coupons** and **gift cards**.
- Creates **product combos** (Buy X get Y free).

---

## 4. Running the Application

Start the Rails server:

```bash
bin/rails server
```

Visit:

- `http://localhost:3000/admin/login` – admin sign-in
- `http://localhost:3000/` – redirects to admin dashboard after login

Admin credentials (from seeds):

- Email: `admin@example.com`
- Password: `Password123!`

---

## 5. Authentication & Roles

**Models**

- `User`
  - Uses `has_secure_password` (backed by `password_digest`).
  - Validates `email` (presence, unique, case-insensitive) and `name`.
  - Includes `rolify` for role management (e.g. `admin`).
- `Customer`
  - Uses `has_secure_password`.
  - Validates `email` and `name`.

**Controllers**

- `ApplicationController`
  - Provides `current_user`, `current_customer`.
  - Guards: `authenticate_admin!`, `authenticate_customer!`.
- `Admin::BaseController`
  - Inherits from `ApplicationController`.
  - Applies `before_action :authenticate_admin!` to all admin controllers.
- `Admin::SessionsController`
  - `new` – admin sign-in form.
  - `create` – authenticates by email/password; sets `session[:user_id]`, redirects to `admin_root_path`.
  - `destroy` – clears `session[:user_id]`, redirects to `admin_login_path`.
- `SessionsController`
  - Similar flow for **customers** using `session[:customer_id]`.

---

## 6. Routes

```ruby
namespace :admin do
  root "dashboard#index"

  get    "login",  to: "sessions#new"
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resources :orders, only: %i[index show update] do
    get :export, on: :collection
  end
  resources :customers
  resources :categories
  resources :users, except: %i[show]
  resources :coupons
  resources :gift_cards
  resources :product_combos
  resources :products do
    get :export, on: :collection
    post :import, on: :collection
    post :bulk_action, on: :collection
  end

  get "cart", to: "cart#index"
  match "cart/add/:product_id", to: "cart#add", via: %i[get post]
  patch "cart/update/:product_id", to: "cart#update"
  delete "cart/remove/:product_id", to: "cart#remove"

  get  "checkout", to: "checkout#index"
  post "checkout", to: "checkout#create"
end

get "locale/:locale", to: "locales#switch"

root "admin/dashboard#index"
```

---

## 7. Products, Categories, and Relationships

**Models**

- `Product`
  - Fields: `name`, `slug`, `description`, `price` (integer cents), `status`, `stock_quantity`, timestamps.
  - Associations: `has_many :product_categories`, `has_many :categories, through: :product_categories`, `has_many_attached :images`.
  - Validations: `name` (presence), `slug` (presence, unique), `price` (≥ 0).
  - Slug: `before_validation :generate_slug` from `name.parameterize`, with uniqueness suffix.
  - Scopes: `search`, `by_status`, `by_category`, `price_between`, `low_stock`.
- `Category`
  - Fields: `name`, `slug`, `parent_id`, `position`, timestamps.
  - Associations: `belongs_to :parent` (optional), `has_many :children`, `has_many :product_categories`, `has_many :products`.
- `ProductCategory`
  - Join model: `belongs_to :product`, `belongs_to :category`.

**Admin UI**

- **Products list** – search, filter by status/category/price, pagination (10 per page), bulk actions (update status, delete).
- **Product form** – name, description, price, status, stock_quantity, categories (multi-select), images (Active Storage).
- **Product export** – CSV; **Product import** – CSV via `ProductImportService`.
- **Categories list** – name, slug, parent, pagination.

---

## 8. Orders, Cart, Checkout

**Models**

- `Order` – `status`, `total_amount`, `coupon_discount`, `gift_card_discount`, `final_amount`, `coupon_id`, `gift_card_id`, shipping address fields.
- `OrderLineItem` – `quantity`, `unit_price_cents`, `is_free_gift` (for free gifts and product combo offers).

**Cart & Checkout**

- Session-based cart via `CartSupport` concern (`admin_cart`, `admin_cart_free_gifts`).
- Cart: add/update/remove items; support for free gifts and product combo offers.
- Checkout: apply coupon or gift card, create order, deduct stock, record coupon usage and gift card transactions.

---

## 9. Coupons & Gift Cards

**Coupon**

- `code`, `discount_type` (percentage/fixed), `discount_value`, `max_discount`, `min_cart_value`, `usage_limit`, `per_user_limit`, `start_date`, `expiry_date`, `status`.
- Product restriction via `coupon_products` (optional).
- Methods: `valid_for?`, `discount_amount`, `record_usage!`.

**Gift Card**

- `code`, `initial_balance`, `balance`, `status`, `expiry_date`.
- Methods: `redeemable?`, `apply_amount`, `deduct!`.
- Transactions recorded in `gift_card_transactions`.

---

## 10. Product Combos (Buy X Get Y Free)

- `ProductCombo` – `is_active`, `valid_from`, `valid_to`.
- `ProductComboTrigger` – trigger products and quantity.
- `ProductComboFreeProduct` – free products and quantity.
- Cart shows qualifying offers; checkout creates line items with `is_free_gift: true` and `unit_price_cents: 0`.

---

## 11. Pagination (Kaminari)

- **Gem**: `kaminari`
- Index pages (products, categories, orders, customers, coupons, gift cards, product combos, users): 10 items per page.
- Views use `paginate @collection`.

---

## 12. Theme / Layout

**Bootstrap 5 via CDN**

Included in `application` layout for styling.

**Navbar**

- Displayed when admin is signed in.
- Links: Dashboard, Products, Categories, Orders, Customers, Coupons, Gift Cards, Product Combos, Users, Cart.
- Highlights current section using `controller_path`.

**Layout content**

- Main content wrapped in `<div class="container mt-3">`.
- Flash messages: `alert-success` (notice), `alert-danger` (alert).
- Locale switcher (EN/JA) via `LocalesController`.

---

## 13. Testing

**RSpec setup**

- Uses `rspec-rails` for models, requests, services, helpers.
- `factory_bot_rails` for factories: `user`, `product`, `category`, `customer`, `order`, `order_line_item`, `coupon`, `gift_card`, `product_combo`.

**Coverage**

- Target: ≥ 95% line coverage (SimpleCov).
- Report: `coverage/index.html`.

**Running tests**

```bash
bundle exec rspec
```

With coverage:

```bash
COVERAGE=true bundle exec rspec
```

Specific files:

```bash
bundle exec rspec spec/models/product_spec.rb
bundle exec rspec spec/requests/admin_products_spec.rb
```

---

## 14. Coding / Architecture Rules (Summary)

- **Rails standards**
  - Production-ready code by default.
  - Latest stable Ruby and Rails.
  - PostgreSQL as the database.
  - No hardcoded secrets; use env vars / credentials.
- **Architecture**
  - Fat models, skinny controllers.
  - Business logic in models or `app/services` (e.g. `ProductImportService`).
  - Strong parameters in controllers.
- **Security / Quality**
  - Compatible with RuboCop, Brakeman, Rails Best Practices, SimpleCov, Overcommit.
  - Validate inputs at the model level.
  - No logging of sensitive data.
- **Performance**
  - Avoid N+1 (use `includes` / `preload`).
  - Pagination for large lists (Kaminari).
- **Testing**
  - RSpec with FactoryBot.
  - Deterministic, isolated tests for business logic.
  - Target ≥ 95% coverage for core logic.

---

## 15. Quick-Start Checklist

1. Clone and install:
   ```bash
   git clone <REPO_URL> ec_admin
   cd ec_admin
   bundle install
   ```

2. Setup database:
   ```bash
   bin/rails db:create db:migrate db:seed
   ```

3. Run server:
   ```bash
   bin/rails server
   ```

4. Log in as admin:
   - `http://localhost:3000/admin/login`
   - Email: `admin@example.com`
   - Password: `Password123!`

5. Explore:
   - Dashboard, Products, Categories, Orders, Customers
   - Coupons, Gift Cards, Product Combos
   - Cart & Checkout
   - Admin users
   - Export/import products, export orders
