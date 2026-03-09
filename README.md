# EC Admin

Rails 8 admin application for e-commerce management.

## Prerequisites

- **Ruby** 3.4.x
- **Rails** 8.0.x
- **PostgreSQL** (running locally)
- **Bundler** (latest)

## Setup

1. Install dependencies:

   ```bash
   cd ec_admin
   bundle install
   ```

2. Configure database (edit `config/database.yml` if needed - default user: `postgres`, password: `postgres`)

3. Create and migrate database:

   ```bash
   bin/rails db:create
   bin/rails db:migrate
   bin/rails db:seed
   ```

4. Start the server:

   ```bash
   bin/rails server
   ```

5. Visit:
   - **Admin login**: http://localhost:3000/admin/login
   - **Credentials**: admin@example.com / Password123!

## Quick-start checklist

1. `bundle install`
2. `bin/rails db:create db:migrate db:seed`
3. `bin/rails server`
4. Log in at http://localhost:3000/admin/login
5. Explore Dashboard, Products, Categories, Orders, Customers

## Running tests

```bash
bundle exec rspec
```

## Project structure

- **Models**: User (rolify), Customer, Product, Category, ProductCategory, Order, OrderLineItem
- **Admin**: Products, Categories, Orders, Customers, Admin Users CRUD
- **Auth**: Session-based with `has_secure_password`
- **Pagination**: Kaminari (10 per page)
- **Theme**: Bootstrap 5 via CDN

## Features

- **Product search & filtering**: Search by name/description, filter by status, category, price range
- **Product images**: Active Storage for multiple images per product
- **Inventory/stock**: Stock quantity, low-stock alerts (≤5), highlighted in product list
- **Order workflow**: Status progression (pending → processing → shipped → delivered → cancelled), line items, shipping address
- **Dashboard charts**: Order count over last 7 days (Chart.js), recent orders, low-stock alert
- **Export CSV**: Products and orders export
- **Import CSV**: Bulk product import (see `db/sample_products.csv` for format)
- **Bulk actions**: Bulk update status, bulk delete products
- **Admin user management**: Add/edit/delete admin users with Rolify roles
- **Audit trail**: PaperTrail on Product, Order, User for change history
