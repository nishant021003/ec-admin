# Business Requirements – ec_admin

## 1. Business Context

- ec_admin is the **back-office administration system** for a Japanese e‑commerce business.
- It is used by internal staff (PM/CS/Operations/Accounting) to manage:
  - Products and categories, including pricing.
  - Orders, including free gift items, coupons, and gift cards.
  - Product images that are shared with other technology stacks.

## 2. High-Level Business Goals

1. **Centralise admin workflows**
   - Single place to manage product/catalog data, orders, and promotions.
   - Reduce ad‑hoc manual spreadsheets and inconsistent data.

2. **Support Japanese pricing and taxation** (planned)
   - Correct handling of prices with and without tax, tax percentage, and grand totals.
   - Ensure that financial reports match accounting expectations.

3. **Enable cross‑stack data sharing**
   - Rails admin is the source of truth.
   - React/Next/.NET clients can safely consume the same product and image data.

4. **Compliance and auditability**
   - Ability to trace changes to key business entities (who changed what, when).
   - Support for future audit/reporting requirements.

## 3. Core Business Requirements

### 3.1 Product & Category Management

- Admin users can:
  - Create, view, update, and deactivate products.
  - Create hierarchical categories.
  - Associate products with multiple categories.
  - Attach one or more images to each product via Active Storage.
- Product records expose:
  - Unique `slug` and `id`.
  - Names and descriptions.
  - Pricing (`price` in cents) and stock (`stock_quantity`).
  - Status (e.g. draft, active).

### 3.2 Order, Free Products & Coupon Management

- Admin users can:
  - View and update order headers and line items.
  - Distinguish between normal items and **free gift** items (order line items marked as `is_free_gift`).
  - Add products as free gifts from the product page or cart.
  - Apply coupons and gift cards; see the effect on monetary fields.
  - Track order status through a defined lifecycle (pending, processing, shipped, delivered, cancelled).
- Monetary values at order level (`total_amount`, `coupon_discount`, `gift_card_discount`, `final_amount`) and at line-item level (`unit_price_cents`) are stored. Free gift items have `unit_price_cents = 0` and do not contribute to the order subtotal.

### 3.3 Image Management

- Product images:
  - Are stored via Active Storage and addressable by stable URLs.
  - Can be uploaded via the admin UI and made accessible to other stacks.
- The system should handle missing or inaccessible blobs gracefully.

### 3.4 Reporting & Insight (initial)

- Basic listing and filtering:
  - Product lists by category, stock status, status.
  - Order lists by status and date range.
  - Coupon usage tracking.
- Future extension:
  - Export reports (CSV/API) for accounting or BI tools.

## 4. Stakeholders

- **Business owner / PM** – defines product strategy, approval flows.
- **Operations team** – manages catalog, stock, and daily order operations.
- **Accounting/Finance** – uses monetary fields and reports for reconciliation.
- **Engineering teams (Rails/React/Next/.NET)** – integrate against the same data contracts.

## 5. Out of Scope (Current Phase)

- Customer‑facing storefront UX.
- Real‑time recommendation engines or dynamic pricing (planned as future ML work).
- Complex ERP/WMS integration (beyond basic export/import).
