# Functional Requirements – ec_admin

## 1. Authentication & Authorization

- Admin users (User model) must log in with secure credentials (`has_secure_password`, bcrypt).
- Role-based access using Rolify:
  - Only authorised roles can access the admin namespace.
  - Sensitive actions (delete product, modify orders) require elevated roles.

## 2. Product Management

- Create / Read / Update / Delete products.
  - Products can be deactivated via `status`; deletion is blocked when referenced by `order_line_items`.
- Fields:
  - Identification: `id`, `slug`.
  - Content: `name`, `description`.
  - Pricing: `price` (integer cents).
  - Stock and status: `stock_quantity`, `status`.
- Behaviour:
  - Automatic slug generation when not provided.
  - Search by name and description.
  - Pagination on index pages (Kaminari).
  - Scopes for low stock, status, category, and price range.

## 3. Category Management

- Create / Read / Update / Delete categories.
- Fields:
  - `name`, `slug`, `parent_id`, `position`.
- Behaviour:
  - Hierarchical parent/child relations.
  - Search over name and slug (as implemented in controllers).
  - Automatic slug generation; duplicates receive numeric suffix.

## 4. Product Image Management

- Attach multiple images per product via **Active Storage** (`has_many_attached :images`).
- Functional flows:
  - Upload images when creating or editing a product.
  - Attach or detach images from product edit/show pages.
- Images are stored as blobs with `content_type` and `filename`; URLs are generated for external access.
- Graceful handling when blobs are missing or storage is unavailable.

## 5. Order & Order Line Item Management

- View and manage orders:
  - `status`, `customer_id`, `user_id`, `total_amount`, `coupon_discount`, `gift_card_discount`, `final_amount`.
  - `coupon_id`, `gift_card_id`.
  - Shipping address fields (inline: line1, line2, city, state, postal_code, country).
  - Status lifecycle: `pending`, `processing`, `shipped`, `delivered`, `cancelled`.
- Order line items:
  - `quantity`, `unit_price_cents`, `product_id`, `order_id`, `is_free_gift`.
  - Product association for name/lookup; `unit_price_cents` preserves price at order time.
  - **Free gift items**: `is_free_gift = true`, `unit_price_cents = 0`; do not contribute to subtotal. Can be added via "Add as free gift" on product page or during cart/checkout.

## 6. Free Product (Free Gift) & Product Combo Module

- Order line items can be marked as **free gifts** (`is_free_gift = true`).
- **Product combos** (Buy X get Y free): Admin creates combos with multiple trigger products and multiple free products.
- Behaviour:
  - Add product as free gift from product show page ("Add as free gift" button).
  - **Combo triggers**: `product_combo_triggers` (product_id, quantity); all must be in cart to qualify.
  - **Combo free products**: `product_combo_free_products`; when triggers are met, user can add free items.
  - Cart shows combo offers with per-free-product "Add as free gift" buttons.
  - Checkout creates line items with `unit_price_cents: 0`, `is_free_gift: true` for free items.
  - Order show displays free gift badge on applicable line items.
  - Stock is deducted for free gift items.

## 7. Coupons & Gift Cards

- **Coupons**:
  - Code, `discount_type` (percentage, fixed), `discount_value`, `status`, validity window (`start_date`, `expiry_date`).
  - Usage limits: `usage_limit`, `per_user_limit`, `min_cart_value`, `max_discount` (for percentage).
  - Product-scoped coupons via `coupon_products`.
  - Track `coupon_usages` per order/user.
- **Gift cards**:
  - Code, balance, initial_balance, status, expiry_date.
  - `gift_card_transactions` for debits/credits per order.

## 8. Admin UX Requirements

- Use Bootstrap 5 layouts with:
  - Card-based product/category indexes.
  - Clear visual indicators for status, stock level.
- Input validation and helpful error messages, especially for numeric and date fields.

## 9. APIs / Data Access for Other Stacks

- Data contracts documented under `construction/units/*/data-contract.md` for:
  - Product (including images and categories).
  - Category, Order, Customer, Coupon, Gift Card, Product Combo.
- Ensure contracts align with the implemented schema and remain stable for consumers.
