# Coupon Service — Data Contract

## Entity: Coupon

| Field | Type | Required | Default | Constraints |
|-------|------|----------|---------|-------------|
| id | bigint | Yes | auto | PK |
| code | string | Yes | — | Unique, case-insensitive, auto-uppercase |
| discount_type | string | Yes | percentage | percentage or fixed |
| discount_value | integer | Yes | 0 | >= 0 |
| min_cart_value | integer | Yes | 0 | >= 0 cents |
| max_discount | integer | No | — | For percentage only |
| usage_limit | integer | No | — | > 0 if set |
| per_user_limit | integer | No | — | > 0 if set |
| start_date | date | No | — | — |
| expiry_date | date | No | — | — |
| status | string | Yes | active | active or inactive |
| created_at | datetime | Yes | — | — |
| updated_at | datetime | Yes | — | — |

## Valid For Rules

- status must be active
- start_date: current date >= start_date
- expiry_date: current date <= expiry_date
- min_cart_value: order total >= min_cart_value
- usage_limit: total usages < usage_limit
- per_user_limit: user usages < per_user_limit
- coupon_products: if any, cart must contain at least one of those products
