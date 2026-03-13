# Monitoring & Alerting – ec_admin

## 1. Objectives

- Detect failures and performance issues in the ec_admin backend before they impact business operations.
- Provide enough observability to debug data and workflow problems.

## 2. What to Monitor

### 2.1 Application Health

- HTTP 5xx rate and error logs.
- Slow requests:
  - Product index/show.
  - Order index/show.
- Background tasks (e.g. seeds, future scheduled jobs).

### 2.2 Database

- Connection errors.
- Slow queries and lock contention, especially around:
  - Large product/order lists.
  - Bulk update or import operations.

### 2.3 Business KPIs (basic)

- Products by status (e.g. draft vs active).
- Order status distribution and update success rate.
- Coupon usage volumes (for sanity checks).

## 3. Alerts

- High error rate (5xx) over a short window.
- Response time above threshold (e.g. P95 > 500ms for admin pages; threshold to be tuned).
- DB connection pool exhaustion or frequent timeouts.

## 4. Implementation Notes

- Use hosting provider’s built-in monitoring (e.g. Railway or equivalent) plus:
  - Rails logs shipped to a central log store (if available).
  - Simple uptime checks (HTTP health endpoint or root page).
- Document concrete dashboards and alert rules here once the monitoring stack is chosen.

## 5. Runbooks

For each key alert, document:

- **Symptom**: What the alert means.
- **Checks**: Logs, DB, recent deploys, seed/backfill runs.
- **Mitigation**: Rollback, scaling, task cancellation, or temporary feature flags.
- **Follow-up**: Permanent fix and new tests.
