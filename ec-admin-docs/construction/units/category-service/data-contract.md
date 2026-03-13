# Category Service — Data Contract

## Entity: Category

| Field | Type | Required | Default | Constraints |
|-------|------|----------|---------|-------------|
| id | bigint | Yes | auto | PK |
| name | string | Yes | — | — |
| slug | string | Yes | — | Unique, case-insensitive |
| parent_id | bigint | No | — | FK categories (self) |
| position | integer | Yes | 0 | — |
| created_at | datetime | Yes | — | — |
| updated_at | datetime | Yes | — | — |

## Associations

- Category has_many product_categories
- Category has_many products through product_categories
- Category belongs_to parent (Category, optional)
- Category has_many children (Category, foreign_key: parent_id)

## Validations

- name: presence
- slug: presence, uniqueness (case-insensitive)

## Slug Generation Rules

- Auto-generated from name using parameterize
- If duplicate, append -2, -3, etc.
- Runs before_validation when name present and (slug blank or name changed)
