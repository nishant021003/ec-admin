# Functional Design – order-service (ec_admin)

## 1. Scope

The order-service boundary covers:

- Creation and lifecycle of orders.
- Monetary calculations for orders and order items.
- Application of promotions and coupons.
- Handling of free gifts.

## 2. Order Lifecycle

### 2.1 States (conceptual)

- `pending` – order created but not yet paid.
- `paid` – payment confirmed.
- `processing` – preparing for shipment.
- `shipped` – handed to carrier.
- `completed` – delivered and accepted.
- `cancelled` – cancelled by customer or admin.

Exact enum values and transitions should be implemented and documented in the `Order` model once finalised.

### 2.2 Transitions (admin-focused)

- Admin can:
  - Mark an order as paid (after verifying payment).
  - Move an order from paid → processing → shipped → completed.
  - Cancel an order (with rules depending on payment and shipment status).

## 3. Monetary Calculations

- `subtotal_amount`:
  - Sum of `price_without_tax` for all non-gift items.
- `tax_amount`:
  - Sum over items: `price_without_tax * tax_percentage`.
- `discount_amount`:
  - Total discount from promotions and coupons.
- `shipping_amount`:
  - Shipping fee logic (flat or rule-based; to be finalised).
- `grand_total`:
  - `subtotal_amount + tax_amount + shipping_amount - discount_amount`.

Order items store **snapshots** of prices and tax at the time of order, so that:

- Changes to product prices later do not affect historical orders.

## 4. Promotions & Gifts

- Promotions (planned):
  - Defined in `Promotion` and linked to products through `PromotionProduct`.
  - When applicable, they adjust item prices or create additional free gift items.
- **Free gifts** (implemented):
  - Represented as `OrderLineItem` with `is_free_gift = true`, `unit_price_cents = 0`.
  - Add via "Add as free gift" on product page or via **product combos** (Buy X get Y free).
- **Product combos** (implemented):
  - `ProductCombo` with `product_combo_triggers` and `product_combo_free_products` (multiple each).
  - When cart contains all trigger products in required quantities, user can add free products.
  - Cart shows combo offers; checkout applies free items at price 0.

## 5. Coupons

- Coupons applied at order level:
  - Identified by `coupon_id`.
  - Logic for discount (percentage vs fixed) computed at order creation/update.
- `CouponUsage` records track:
  - Which order and customer used the coupon.
  - Enforce maximum usages and per-customer limits.

## 6. Interfaces with Other Services

- product-service:
  - Provides product metadata (name, tax) when taking snapshots.
  - Decoupling via snapshot fields to avoid tight runtime dependency.
- Future customer-service / accounting integrations:
  - Use the order and usage records for reconciliation and reporting.
