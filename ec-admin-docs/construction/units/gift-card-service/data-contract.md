# Gift Card Service — Data Contract

## Entity: GiftCard

| Field | Type | Required | Default | Constraints |
|-------|------|----------|---------|-------------|
| id | bigint | Yes | auto | PK |
| code | string | Yes | — | Unique, uppercase, no spaces |
| initial_balance | integer | Yes | 0 | >= 0 cents |
| balance | integer | Yes | 0 | >= 0 cents |
| status | string | Yes | active | active, redeemed, expired |
| expiry_date | datetime | No | — | — |
| created_at | datetime | Yes | — | — |
| updated_at | datetime | Yes | — | — |

## Redeemable When

- status == active
- balance > 0
- Not expired (expiry_date nil or Date.current <= expiry_date)
