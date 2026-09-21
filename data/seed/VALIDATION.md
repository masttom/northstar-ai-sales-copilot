# Synthetic Data Foundation v1 — Validation Report

**Status:** FROZEN  
**Date:** 2026-09-21  
**Dataset:** Northstar Commercial Solutions

## Result
**27/27 checks passed.**

## Checks
- PASS — **Product count**: 80 rows
- PASS — **Product lifecycle distribution**: {'ACTIVE': 60, 'PHASE_OUT': 10, 'DISCONTINUED': 10}
- PASS — **Sales user count/roles**: {'SENIOR_ACCOUNT_EXECUTIVE': 3, 'ACCOUNT_EXECUTIVE': 6, 'SALES_MANAGER': 2, 'REGIONAL_SALES_MANAGER': 1}
- PASS — **Account count/tiers**: {'STRATEGIC': 8, 'PREFERRED': 16, 'STANDARD': 36}
- PASS — **Account owner FK**: all account_owner_id values resolve
- PASS — **Opportunity count/stages**: {'NEGOTIATION': 6, 'SOLUTION_DESIGN': 7, 'PROPOSAL': 7, 'DISCOVERY': 5, 'CLOSED_WON': 3, 'CLOSED_LOST': 2}
- PASS — **Opportunity account FK**: all resolve
- PASS — **Opportunity owner FK**: all resolve
- PASS — **Solution opportunity FK**: all resolve
- PASS — **Solution product FK**: all resolve
- PASS — **All opportunities have solution lines**: 30/30
- PASS — **Orders account FK**: all resolve
- PASS — **Order-line order FK**: all resolve
- PASS — **Order-line product FK**: all resolve
- PASS — **Completed orders only**: {'COMPLETED'}
- PASS — **Agreement account FK**: all resolve
- PASS — **Entitlement agreement FK**: all resolve
- PASS — **Active strategic agreements align to Strategic tier**: 8 active strategic agreements -> Strategic accounts
- PASS — **Prima expired agreement trap**: AGR-2025-021 expired; no active replacement
- PASS — **Inventory arithmetic**: available = on_hand - reserved
- PASS — **Inventory product FK**: all resolve
- PASS — **Incoming product FK**: all resolve
- PASS — **Bayfront IC-420 trap**: IC-420 available=0; incoming=4
- PASS — **Bayfront IC-500 alternative**: IC-500 available=3
- PASS — **8 rich opportunity solution semantics**: all expected SKU sets match
- PASS — **Kopi Harian installed-history trap**: BC-700/WF-250/MB-70 legacy base present
- PASS — **Meridian WF-300 history**: 8+ WF-300 purchased

## Freeze Notes
- Product Master remains thin; detailed technical specifications, compatibility, installation constraints, and policy clauses belong to authoritative knowledge documents.
- Evaluation ground truth is not included in runtime seed data.
- Frozen files are identified by SHA-256 hashes in `manifest.json`.
- Any future change to these seed files should create a new dataset version rather than silently modifying v1.