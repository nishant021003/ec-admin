# Coupon Service — Functional Design

## Admin API Endpoints

| Method | Path | Action |
|--------|------|--------|
| GET | /admin/coupons | index |
| GET | /admin/coupons/:id | show |
| GET | /admin/coupons/new | new |
| POST | /admin/coupons | create |
| GET | /admin/coupons/:id/edit | edit |
| PATCH | /admin/coupons/:id | update |
| DELETE | /admin/coupons/:id | destroy |

## Discount Calculation

- Percentage: (order_total * discount_value / 100) rounded; capped by max_discount if set
- Fixed: min(discount_value, order_total)
