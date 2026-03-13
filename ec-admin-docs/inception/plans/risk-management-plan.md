# Risk Management Plan – ec_admin

## 1. Purpose

This document tracks key risks for the ec_admin back office (Rails 8, Japanese EC), plus mitigations and owners.

## 2. Risk Register (initial)

| ID | Risk | Area | Impact | Likelihood | Mitigation | Owner |
|----|------|------|--------|------------|-----------|-------|
| R1 | DB schema changes break other stacks (React/Next/.NET) | Integration | High | Medium | Maintain versioned data contracts, communicate changes before deploy, provide backward-compatible views/APIs where possible. | Tech Lead |
| R2 | External image URLs become invalid or slow | UX/Data | Medium | Medium | Centralise URLs in seeds/tasks; support switching to internal CDN later; log broken image URLs and provide fallbacks. | Tech Lead |
| R3 | Seed/rake tasks accidentally run on production with destructive options | Ops | High | Low | Keep seeds/rake idempotent and non-destructive; require explicit flags for any destructive operation; document commands in README/SETUP. | DevOps |
| R4 | Performance degradation on large product/order volumes | Performance | High | Medium | Use proper indexes, eager loading, pagination (Kaminari), and realistic performance tests documented under `construction/build-and-test/`. | Performance Engineer |
| R5 | Authentication/authorization misconfigurations exposing admin-only features | Security | Critical | Low | Enforce role checks in controllers; test access rules; document roles in security-design.md. | Security Lead |

## 3. Monitoring & Review

- Review this table at each major release.
- Add new risks as they appear; mark mitigated / accepted.
