# Product Service — Functional Design

## Admin API Endpoints

| Method | Path | Action |
|--------|------|--------|
| GET | /admin/products | index |
| GET | /admin/products/:id | show |
| GET | /admin/products/new | new |
| POST | /admin/products | create |
| GET | /admin/products/:id/edit | edit |
| PATCH | /admin/products/:id | update |
| DELETE | /admin/products/:id | destroy |
| GET | /admin/products/export | export (CSV) |
| POST | /admin/products/import | import (CSV) |
| POST | /admin/products/bulk_action | bulk_action (update status, delete) |

## Index Filtering

- **q**: Search by name or description (ILIKE)
- **status**: Filter by status (active, draft, archived)
- **category_id**: Filter by category
- **min_price**, **max_price**: Price range filter

## Bulk Actions

- Update status for selected products
- Delete selected products

## CSV Import Format

Columns: name, slug, description, price, status, stock_quantity, categories (semicolon-separated)

## Rules

1. Product slug must be unique across all products.
2. Price is stored in cents (integer).
3. Stock quantity cannot be negative.
4. Product with order_line_items cannot be deleted (restrict_with_exception).
5. Images use Active Storage; multiple images per product supported.
