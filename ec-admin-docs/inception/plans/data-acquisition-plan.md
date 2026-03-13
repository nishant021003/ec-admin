# Data Acquisition Plan – ec_admin

## 1. Data Domains

- **Products**: Japanese product catalogue (names, descriptions, pricing, tax, images).
- **Categories**: Hierarchical category tree with codes and active flags.
- **Orders**: Order headers and order items (prices, gifts, promotions, coupons).
- **Customers & Addresses**: Basic contact details and shipping/billing addresses.

## 2. Sources

- Initial data is seeded via `db/seeds.rb` and `rake products:backfill_new_fields`.
- Future sources (optional):
  - CSV imports from existing systems.
  - API integrations with external catalog or order systems.

## 3. Data Volume & Refresh

- Development: Small synthetic datasets suitable for local testing.
- Staging/Production: To be defined based on real usage; plan for incremental imports.

## 4. Data Quality Rules

- Product codes must be unique and non-null.
- Category codes must be unique and non-null.
- Monetary amounts must be non-negative and consistent (subtotal, tax, grand_total).
- `image_url` must be a valid HTTP(S) URL when present.

## 5. Privacy & Compliance

- Avoid using real customer PII in non-production environments.
- If real PII is required, document masking / anonymisation strategy here.

## 6. Tooling & Scripts

- `db/seeds.rb` – creates admin user, categories, products, and sample orders.
- `rake products:backfill_new_fields` – enriches existing products with Japanese metadata and image URLs.
