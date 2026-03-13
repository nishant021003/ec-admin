# Gift Card Service — Functional Design

## Admin API Endpoints

| Method | Path | Action |
|--------|------|--------|
| GET | /admin/gift_cards | index |
| GET | /admin/gift_cards/:id | show |
| GET | /admin/gift_cards/new | new |
| POST | /admin/gift_cards | create |
| GET | /admin/gift_cards/:id/edit | edit |
| PATCH | /admin/gift_cards/:id | update |
| DELETE | /admin/gift_cards/:id | destroy |

## Apply Amount

- apply_amount(amount_cents): min(amount_cents, balance) if redeemable
- deduct!: Decrements balance, creates gift_card_transaction (debit)
