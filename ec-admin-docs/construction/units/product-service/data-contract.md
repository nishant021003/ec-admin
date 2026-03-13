# Data Contract – product-service (ec_admin)

## 1. Purpose

Defines the product and category data shape that other stacks (React, Next.js, .NET, etc.) can rely on.

## 2. Product Representation

### 2.1 Fields

- `id`: integer
- `product_code`: string (unique, required)
- `name`: string
- `maker_name`: string
- `size`: string
- `description`: string
- `long_description`: text
- `price_without_tax`: decimal(10, 2)
- `tax_percentage`: decimal(5, 2)
- `price_with_tax`: decimal(10, 2)
- `is_limited_quantity`: boolean
- `available_stock`: integer
- `acceptance_deadline_date`: date
- `delivery_date_required`: boolean
- `is_out_of_stock`: boolean
- `is_active`: boolean
- `status`: string or enum (to be documented when finalised)
- `category_ids`: array of integers (IDs of associated categories)
- `created_at`, `updated_at`: timestamps

### 2.2 Image Sub-Resource

Each product can have `product_images`:

- `id`: integer
- `image_url`: string (HTTP(S) URL preferred; may be relative for legacy data)
- `image_type`: enum (`main`, `gallery`, `icon`)
- `sort_order`: integer
- `content_type`: string (e.g. `image/jpeg`)
- `original_filename`: string
- `created_at`: timestamp

**Primary image rule**:

- `image_type == "main"` with lowest `sort_order` is primary.
- If none, the first image in `sort_order, id` order is treated as primary.

## 3. Category Representation

- `id`: integer
- `name`: string
- `slug`: string
- `code`: string (unique, required)
- `is_active`: boolean
- `parent_id`: integer (nullable)
- `position`: integer (optional ordering hint)
- `created_at`, `updated_at`: timestamps

## 4. Compatibility Rules

- New optional fields may be added; existing fields are not removed without deprecation notice.
- Enumerations (`image_type`, product `status`) must be documented and changed in a backward‑compatible way.
- Consumers must tolerate:
  - Missing optional fields.
  - Nulls for optional numeric/date fields.
  - Relative `image_url` values (they should prepend an agreed base URL).
