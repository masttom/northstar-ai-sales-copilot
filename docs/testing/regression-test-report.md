# Northstar AI Sales Copilot — Regression Test Report

**Project:** Northstar AI Sales Copilot  
**Release:** MVP v1 — Portfolio Prototype  
**Test Date:** 27 October 2026  
**Primary Model:** GPT-4o  
**Interface:** n8n Hosted Chat  
**Architecture:** n8n AI Agent, PostgreSQL, Pinecone, modular Business Tools

## 1. Test Objective

Evaluate the prototype's ability to retrieve relevant business information, invoke appropriate tools, perform evidence-grounded analysis, and provide actionable sales recommendations without making unsupported operational or commercial commitments.

## 2. Test Results

| Test ID | Scenario                                        | Result                         |
| ------- | ----------------------------------------------- | ------------------------------ |
| FT-01B  | Commercial negotiation and financial simulation | PASS with observations         |
| FT-02   | Product discovery and compatibility pre-check   | CONDITIONAL PASS               |
| FT-03   | Inventory availability and order feasibility    | PASS — availability assessment |

### FT-01B — Commercial Negotiation

**Scenario:** Evaluate a requested 15% discount for opportunity OPP-2026-076, DapurKita Restaurant Group.

**Verified outcomes:**

- Retrieved opportunity, account, agreement, and approval-policy evidence.
- Identified Rp620 juta in eligible normal core equipment.
- Distinguished the 9% standard discount ceiling from the 15% commercial-exception request.
- Used BT-09 to simulate 8%, 9%, and 15% discount options.
- Produced financial calculations consistent with the calculation tool.

**Observation:** Approval authority must not be interpreted as evidence of an actual approval. The initial Hosted Chat response encountered a Cloudflare 502 error, although the Agent execution completed.

### FT-02 — Product Discovery and Compatibility

**Scenario:** Recommend espresso and water-treatment solutions for a new coffee shop targeting 150–200 cups per day.

**Verified outcomes:**

- Retrieved product documentation through Pinecone.
- Recommended BrewCore BC-920 and AquaPure WF-500.
- Matched key technical specifications to retrieved product documents.
- Identified site, electrical, water, and installation requirements.

**Limitation:** The retrieved compatibility-matrix excerpt did not include the specific BC-920/WF-500 compatibility decision. Pairwise compatibility therefore remained unverified.

### FT-03 — Inventory and Order Feasibility

**Scenario:** Assess availability of three BrewCore BC-920 units for a customer opening in three weeks.

**Verified outcomes:**

- Resolved the product reference.
- Retrieved inventory data through BT-07.
- Correctly reported four units on hand, one reserved, and three available at warehouse WH-BPN.
- Correctly identified no recorded incoming inventory.
- Avoided promising a confirmed delivery date or inventory allocation.

**Limitation:** The inventory record was last updated on 21 September 2026. Delivery within three weeks was not independently confirmed.

## 3. Known Limitations

- Product compatibility decisions depend on retrieving complete authoritative evidence.
- Inventory data represents database snapshots and may require operational reconfirmation.
- Commercial exceptions and approvals remain subject to authorized human decisions.
- End-to-end testing of a complete multi-stage sales conversation is deferred.
- Production reliability, concurrency, security, and operational performance have not been validated.

## 4. MVP Assessment

**Status: Working Portfolio Prototype**

The prototype demonstrates evidence-grounded commercial analysis, retrieval-augmented product recommendations, and structured inventory assessment through modular business tools.

It is suitable for portfolio demonstration with the documented limitations. It is not represented as a production-ready sales system.

**Design principle:** AI recommends. Human decides.
