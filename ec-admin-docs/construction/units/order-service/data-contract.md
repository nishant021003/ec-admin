# Data Contract – order-service (ec_admin)

## 1. Purpose

Defines the order, order item, promotion, and coupon data shapes that other stacks can rely on for reporting, reconciliation, and future integrations.

## 2. Order Representation

### 2.1 Fields

- `id`: integer
- `order_number`: string (unique)
- `customer_id`: integer
- `user_id`: integer (optional, if different from customer)
- Monetary fields (all decimal(10, 2), non-null, default 0):
  - `subtotal_amount`
  - `tax_amount`
  - `shipping_amount`
  - `discount_amount`
  - `grand_total`
- Coupon and status:
  - `coupon_id`: integer (nullable)
  - `payment_status`: string (enum to be documented)
  - `order_status`: string (enum to be documented)
- Delivery and addresses:
  - `delivery_date`: date
  - `delivery_time_slot`: string
  - `shipping_address_id`: integer (nullable)
  - `billing_address_id`: integer (nullable)
- Timestamps:
  - `placed_at`: datetime
  - `created_at`, `updated_at`: timestamps

### 2.2 Relationships

- `customer`: customer record that placed the order.
- `order_items[]`: list of order item records.
- `coupon`: applied coupon (if any).
- `payments[]`: payment records (for future expansion).
- `shipments[]`: shipment records (for future expansion).
- `shipping_address` / `billing_address`: address records.

## 3. Order Item Representation

- `id`: integer
- `order_id`: integer
- `product_id`: integer
- Snapshots:
  - `product_name_snapshot`: string
  - `price_without_tax`: decimal(10, 2)
  - `tax_percentage`: decimal(5, 2)
  - `price_with_tax`: decimal(10, 2)
  - `total_amount`: decimal(10, 2)
- Gifts & promotions:
  - `is_free_gift`: boolean (default false)
  - `promotion_id`: integer (nullable)
- Timestamps:
  - `created_at`, `updated_at`: timestamps

## 4. Promotion Representation

- `id`: integer
- Core fields (to be kept in sync with the Rails model):
  - `name`: string
  - `description`: text
  - `promotion_type`: string/enum (e.g. percentage, fixed_amount, free_gift)
  - `starts_at`, `ends_at`: datetimes
  - `is_active`: boolean
- Relationships:
  - `promotion_products[]`: mapping to products eligible for the promotion.

## 5. Coupon Representation

- `id`: integer
- `code`: string (unique)
- `description`: text
- `discount_type`: string/enum (e.g. percentage, fixed_amount)
- `discount_value`: decimal(10, 2)
- Constraints:
  - `starts_at`, `ends_at`: datetimes
  - `max_uses`: integer (nullable)
  - `max_uses_per_customer`: integer (nullable)
- State:
  - `is_active`: boolean
- Relationships:
  - `coupon_usages[]`: records of usage per order/customer.

## 6. Compatibility Rules

- Monetary fields must be non-negative and consistent:
  - `subtotal_amount + tax_amount + shipping_amount - discount_amount == grand_total` (within rounding).
- Status fields (`payment_status`, `order_status`) must be documented enums; changes are backward‑compatible (new values added, existing not repurposed).
- New optional fields may be added; removal or semantic change requires deprecation and communication.
