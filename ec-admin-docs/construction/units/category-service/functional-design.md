# Category Service — Functional Design

## Admin API Endpoints

| Method | Path | Action |
|--------|------|--------|
| GET | /admin/categories | index |
| GET | /admin/categories/:id | show |
| GET | /admin/categories/new | new |
| POST | /admin/categories | create |
| GET | /admin/categories/:id/edit | edit |
| PATCH | /admin/categories/:id | update |
| DELETE | /admin/categories/:id | destroy |

## Hierarchy

- Categories support parent-child (self-referential).
- Parent category optional; null means top-level.
- Children displayed when parent selected in form.

## Rules

1. Category slug must be unique across all categories.
2. Deleting a category nullifies parent_id on its children.
3. Product-category link via product_categories join table (many-to-many).
