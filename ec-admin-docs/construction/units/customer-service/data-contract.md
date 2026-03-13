# Customer Service — Data Contract

## Entity: Customer

| Field | Type | Required | Default | Constraints |
|-------|------|----------|---------|-------------|
| id | bigint | Yes | auto | PK |
| name | string | Yes | — | — |
| email | string | Yes | — | Unique, case-insensitive |
| password_digest | string | Yes | — | has_secure_password |
| created_at | datetime | Yes | — | — |
| updated_at | datetime | Yes | — | — |

## Associations

- Customer has_many orders (dependent: nullify)

## Validations

- name: presence
- email: presence, uniqueness (case-insensitive)

## Rules

- Email normalized: downcase, strip before validation
