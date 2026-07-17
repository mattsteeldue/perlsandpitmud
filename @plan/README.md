# SandpitMUD Modernization Plan

**Status**: Planning Phase (all decisions deferred)  
**Date**: 2026-07-17

## Contents

This directory contains the detailed modernization plan for SandpitMUD.

- **[00_overview.md](00_overview.md)** — Current state, codebase analysis, architecture
- **[01_option_tls_perl.md](01_option_tls_perl.md)** — Option 1: TLS on Perl (short-term, low-risk)
- **[02_option_python_rewrite.md](02_option_python_rewrite.md)** — Option 2: Full Python migration (long-term, comprehensive)
- **[03_decision_points.md](03_decision_points.md)** — Key decisions awaiting
- **[04_timeline_estimate.md](04_timeline_estimate.md)** — Effort estimates and resource requirements

## Quick Summary

**Goal**: Modernize SandpitMUD by adding encryption (TLS) and evaluating language migration.

**Two options**:
1. **TLS on Perl** (1-2 wks) — Quick security win, keep Perl, migrate Python later
2. **Full Python rewrite** (8-10 wks, 2 people) — Complete modernization, cleaner async model

**Decision point**: Which path? When? With how many people?

---

See also: [PLAN_MODERNIZATION.md](../PLAN_MODERNIZATION.md) (top-level summary)
