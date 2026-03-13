# Customer Service — Functional Design

## Admin API Endpoints

| Method | Path | Action |
|--------|------|--------|
| GET | /admin/customers | index |
| GET | /admin/customers/:id | show |
| GET | /admin/customers/new | new |
| POST | /admin/customers | create |
| GET | /admin/customers/:id/edit | edit |
| PATCH | /admin/customers/:id | update |
| DELETE | /admin/customers/:id | destroy |

## Index

- Paginated (Kaminari, 10 per page)
- Search by name or email
