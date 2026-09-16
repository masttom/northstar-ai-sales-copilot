# AI Sales Copilot

## Business Requirements Document (BRD) --- Version 1.0

**Organization:** Northstar Commercial Solutions\
**Document Status:** Draft Baseline\
**Version:** 1.0\
**Date:** 16 September 2026

---

## 1. Executive Summary

Northstar Commercial Solutions is a fictional established national
Indonesian B2B distributor and authorized multi-brand solutions provider
serving hotels and resorts, restaurant groups, café and bakery chains,
and catering or institutional food-service customers.

Northstar's sales representatives sell commercial equipment and related
services across multiple product categories. The information required to
make a reliable customer-facing decision already exists within the
organization, but it is distributed across customer records, opportunity
data, order history, product information, inventory records, technical
documents, commercial policies, customer-specific agreements, and
internal sales guidance.

As a result, sales representatives often need to manually assemble
information from multiple sources or depend on internal specialists
before they can confidently recommend a product, evaluate compatibility,
determine commercial flexibility, assess operational feasibility, or
prepare for a customer negotiation.

The AI Sales Copilot is intended to reduce this information-assembly
burden. It will support sales representatives by retrieving relevant
business data and company knowledge, combining evidence from appropriate
sources, and producing grounded decision support.

The Copilot is intentionally **semi-agentic and read-only**. It may
decide what information it needs and which available sources to consult,
but it does not approve discounts, modify business systems, send
quotations, communicate with customers, or execute consequential
business actions.

Its core operating principle is:

> **READ → RETRIEVE → REASON → RECOMMEND**

The human sales representative remains responsible for the final
decision and action.

---

## 2. Business Context

### 2.1 Company Profile

Northstar Commercial Solutions is modeled as a mid-sized national
Indonesian B2B commercial-equipment distributor with sufficiently
complex sales and operational processes to require cross-functional
information access.

The company operates nationwide and maintains approximately:

- 300 active SKUs
- 600 active B2B customer accounts
- 25--35 salespeople
- 120--180 employees across sales, product, commercial, operations,
  service, and supporting functions

Northstar does not manufacture equipment. It acts as an authorized
multi-brand distributor and solutions provider for several fictional
equipment brands.

### 2.2 Primary Customer Segments

Northstar serves:

- Hotels & Resorts
- Restaurant Groups
- Café & Bakery Chains
- Catering / Institutional Food Service

### 2.3 Product Categories

Northstar's commercial portfolio includes:

- Commercial Refrigeration
- Ice & Beverage Equipment
- Water Treatment
- Commercial Cooking Equipment
- Warewashing

The company also sells accessories, consumables, installation services,
extended warranty/service products, and preventive-maintenance services
where applicable.

### 2.4 Sales Organization

The sales organization includes:

- Head of Sales
- Regional Sales Managers
- Sales Managers
- Senior Account Executives
- Account Executives
- Product Specialists
- Sales Operations
- Commercial / Finance
- Service & Installation

The primary user of the Sales Copilot is an Account Executive or Senior
Account Executive managing complex B2B opportunities.

---

## 3. Business Problem

### 3.1 Problem Statement

The right information exists, but sales representatives must manually assemble it across documents, systems, and internal teams before they can make a reliable customer-facing decision.

A sales decision may require information from several independent
sources. For example, a representative may need to determine:

- which products satisfy a customer's requirements;
- what equipment the customer already owns;
- whether existing equipment is compatible with a proposed product;
- which commercial policy applies;
- whether a customer-specific agreement changes the general rule;
- whether the salesperson has authority to offer a requested
  concession;
- whether the proposed equipment is currently available;
- whether an operational dependency is still unknown;
- which risks or unresolved questions should be addressed before the
  next customer conversation.

No single source contains all of this information.

### 3.2 Current-State Pain Points

The current sales process creates several recurring problems:

**Fragmented product knowledge.**\
Product specifications, installation requirements, compatibility
information, and technical updates may exist across catalogs,
specification sheets, installation guides, compatibility matrices, and
technical bulletins.

**Dependency on internal specialists.**\
Sales representatives may ask Product Specialists, Commercial teams,
Managers, or Service Operations for information that already exists
within company systems or documents.

**Commercial-rule fragmentation.**\
A requested discount may depend on salesperson authority, customer tier,
deal size, product eligibility, active agreements, exclusions, and
current policies.

**Customer context is separated from product knowledge.**\
Purchase history and account information must be cross-referenced with
current technical knowledge before a reliable recommendation can be
made.

**Operational information changes over time.**\
Current stock, reserved quantities, incoming inventory, and expected
arrival dates are structured operational facts that cannot safely be
inferred from static documents.

**Historical information can be misleading.**\
Expired agreements, superseded policies, legacy products, and older
technical documents may remain useful for historical context but must
not automatically be treated as current authority.

**Incomplete information can create false confidence.**\
Some customer questions cannot be answered reliably until missing
technical or operational information is obtained.

---

## 4. Business Objectives

The AI Sales Copilot should:

1.  Reduce the effort required for sales representatives to locate and
    assemble relevant internal information.
2.  Reduce unnecessary dependency on internal specialists for questions
    already answerable from authoritative company information.
3.  Improve consistency in product, compatibility, commercial, and
    operational decision support.
4.  Help sales representatives distinguish confirmed information from
    inference, missing information, and conflicting information.
5.  Provide traceable evidence for important recommendations and
    commercial conclusions.
6.  Support faster preparation for customer conversations without
    removing human judgment or approval.
7.  Demonstrate a practical enterprise use of AI that combines
    structured business data with document-based company knowledge.

---

## 5. Primary User

### 5.1 Sales Representative

The primary user is an Account Executive or Senior Account Executive
responsible for managing B2B opportunities from discovery through
negotiation.

A representative may need to:

- understand customer requirements;
- identify suitable products;
- compare alternatives;
- review installed or previously purchased equipment;
- evaluate compatibility;
- understand commercial flexibility;
- check stock or incoming inventory;
- identify unresolved delivery or installation dependencies;
- prepare for negotiation;
- determine when escalation is required.

### 5.2 Representative Persona

A representative example used throughout the project is **Daniel**, a
Senior Account Executive.

Daniel may independently handle routine sales decisions within his
delegated authority but must escalate technical exceptions, special
commercial concessions, and operational uncertainties to the appropriate
internal function.

The Copilot is intended to reduce unnecessary escalation, not eliminate
legitimate escalation.

---

## 6. Current-State Sales Journey

A typical complex opportunity follows:

**Customer Inquiry / Opportunity**\
→ **Discovery**\
→ **Requirements Captured**\
→ **Solution Design**\
→ **Commercial Proposal**\
→ **Negotiation**\
→ **Approval When Required**\
→ **Quotation / Order**\
→ **Fulfillment / Installation**

The project focuses on decision support during the sales process before
consequential commercial or operational actions are executed.

---

## 7. Target-State Experience

The Sales Copilot should allow a representative to work within an
explicit sales context consisting of:

- Sales User
- Customer Account
- Active Opportunity / Deal

The representative can then ask natural-language questions about the
active deal.

The Copilot determines what information is required, retrieves relevant
structured business facts and/or authoritative company knowledge,
evaluates the evidence in the context of the deal, and returns a
grounded response.

The response should clearly distinguish:

- what is confirmed;
- what is supported or inferred;
- what remains unknown;
- where authoritative information conflicts;
- what approval or escalation is required;
- which sources support the conclusion.

The Copilot does not become a new system of record.

---

## 8. Core Business Use Cases

The MVP is organized around five decision moments in the sales journey:

> **FIT → CONTEXT → COMMERCIAL → FEASIBILITY → READINESS**

### UC-01 --- Product Recommendation / FIT

**Business question:**\
_What should I propose?_

The representative provides customer requirements such as capacity,
electrical requirements, environment, available space, warranty
expectations, quantity, or other relevant constraints.

The Copilot should:

- identify relevant product candidates;
- retrieve applicable product knowledge;
- compare candidates against customer requirements;
- identify trade-offs;
- recommend an appropriate fit and reasonable alternatives;
- identify missing information that prevents a reliable
  recommendation;
- avoid presenting an unsupported product as a confirmed fit.

The objective is decision support, not automated product configuration.

### UC-02 --- Customer-Aware Intelligence / CONTEXT

**Business question:**\
_What applies to this customer?_

The Copilot combines customer-specific structured information with
current product or technical knowledge.

Example:

> Can Meridian reuse its existing AquaPure WF-300 filtration units with
> the proposed Polarix IC-420?

The answer requires both customer purchase history and current
compatibility knowledge.

The Copilot should not assume that equipment previously purchased by a
customer remains compatible with a current product.

### UC-03 --- Commercial Decision Support / COMMERCIAL

**Business question:**\
_What can I offer?_

The Copilot evaluates relevant context such as:

- salesperson role;
- customer tier;
- active customer agreement;
- eligible deal value;
- requested concession;
- applicable commercial policy;
- product commercial status;
- exclusions and stackability rules.

The Copilot must distinguish:

> **commercially eligible** from **within the salesperson's authority**.

It may state that approval is required, but it does not grant or request
approval.

### UC-04 --- Operational Feasibility / FEASIBILITY

**Business question:**\
_Can we actually deliver?_

The Copilot evaluates available structured operational information
relevant to the proposed solution, including:

- current inventory;
- reserved inventory;
- incoming inventory;
- expected arrival dates;
- known product dependencies.

If an important operational source is unavailable, the Copilot must not
convert the missing information into a guarantee.

For the MVP, installation scheduling is intentionally not connected.

A valid response may therefore confirm equipment availability while
stating that the full deployment timeline cannot yet be confirmed.

### UC-05 --- Deal Readiness & Negotiation Preparation / READINESS

**Business question:**\
_What should I know before I talk to the customer?_

The Copilot synthesizes the current deal context into preparation
support, including:

- current deal position;
- product/value position;
- commercial position;
- relevant negotiation leverage;
- known risks;
- commitments the representative should not make;
- missing information;
- suggested questions or next points to clarify.

The Copilot prepares the salesperson for negotiation; it does not
negotiate with the customer.

---

## 9. Functional Requirements

### 9.1 Context and Identity

**FR-01** --- The system shall operate with an explicit sales-user
context.

**FR-02** --- The system shall support an explicit active
customer-account context.

**FR-03** --- The system shall support an explicit active
opportunity/deal context.

**FR-04** --- The system shall use conversation context for
conversational continuity without treating conversational assertions as
authoritative business records.

### 9.2 Structured Business Information

**FR-05** --- The system shall retrieve current customer/account
information from the applicable structured business source.

**FR-06** --- The system shall retrieve current opportunity/deal
information.

**FR-07** --- The system shall retrieve authoritative completed
purchase/order history when customer ownership or prior purchases are
relevant.

**FR-08** --- The system shall retrieve structured product identity and
lifecycle information.

**FR-09** --- The system shall retrieve current inventory and
incoming-inventory information when operational feasibility is relevant.

**FR-10** --- The system shall identify whether an active
customer-specific commercial entitlement or agreement exists.

### 9.3 Company Knowledge

**FR-11** --- The system shall retrieve relevant knowledge from company
and manufacturer documents.

**FR-12** --- The system shall support knowledge covering technical
specifications, installation requirements, compatibility, commercial
policy, warranty, customer-specific agreements, and sales guidance.

**FR-13** --- The system shall preserve document metadata required to
evaluate authority, applicability, revision, status, and effective
period.

**FR-14** --- The system shall distinguish current documents from
superseded, expired, or historical documents.

**FR-15** --- The system shall retain relevant legacy knowledge where it
remains authoritative for legacy or discontinued products.

### 9.4 Reasoning and Decision Support

**FR-16** --- The system shall determine whether a question requires
structured business data, document knowledge, or both.

**FR-17** --- The system shall combine evidence from multiple relevant
sources when a reliable conclusion cannot be reached from a single
source.

**FR-18** --- The system shall evaluate whether a rule or document is
applicable to the current customer, product, deal, user, and effective
period.

**FR-19** --- The system shall prefer the most specific applicable
authoritative rule over a more general rule where an explicit override
applies.

**FR-20** --- The system shall not assume that a customer-specific
agreement overrides general restrictions outside the agreement's stated
scope.

**FR-21** --- The system shall distinguish factual or policy-backed
conclusions from advisory sales guidance.

**FR-22** --- The system shall identify when a conclusion requires
approval or escalation.

### 9.5 Evidence, Uncertainty, and Conflict

**FR-23** --- The system shall expose relevant source provenance with
material answers.

**FR-24** --- The system shall support the following general information
states:

- CONFIRMED
- SUPPORTED / INFERRED
- UNKNOWN
- CONFLICT

**FR-25** --- For commercial decisions, the system shall support:

- WITHIN AUTHORITY
- APPROVAL REQUIRED
- NOT ELIGIBLE
- INSUFFICIENT INFORMATION
- CONFLICT

**FR-26** --- The system shall state what material information is
missing when available evidence is insufficient.

**FR-27** --- The system shall surface unresolved conflicts between
authoritative sources rather than silently selecting a conclusion.

**FR-28** --- The system shall not substitute general model knowledge or
general industry practice for unavailable Northstar-specific business
truth.

### 9.6 Human Control

**FR-29** --- The system shall operate as read-only decision support for
the MVP.

**FR-30** --- The system shall not modify CRM, ERP, product, inventory,
agreement, or other business records.

**FR-31** --- The system shall not approve discounts or other commercial
exceptions.

**FR-32** --- The system shall not send quotations, emails, customer
messages, or other external communications.

**FR-33** --- The system shall leave final customer-facing decisions and
consequential actions to the human representative.

---

## 10. Commercial Business Rules

### 10.1 Account Tier

Account tier determines commercial treatment and program eligibility. It
does not automatically grant a fixed discount.

Supported tiers are:

- Standard
- Preferred
- Strategic

### 10.2 Baseline Sales Authority

Baseline discretionary authority is:

Sales Role Baseline Discretionary Authority

---

Account Executive Up to 5%
Senior Account Executive Up to 8%
Sales Manager Up to 12%
Regional Sales Manager Up to 15%
Above 15% Commercial Director approval

Customer-specific agreements may explicitly modify delegated authority
within their stated scope.

### 10.3 Equipment Volume Discount Program 2026

Program eligibility is based on **eligible equipment subtotal**, not
total quotation value.

Eligible Equipment Subtotal Program Eligibility

---

Below Rp250 juta Standard terms
Rp250--499 juta Up to 7%
Rp500--749 juta Up to 9%
Rp750 juta and above Up to 10%

Program eligibility does not automatically increase a salesperson's
delegated approval authority.

### 10.4 Eligible Equipment

Eligible equipment subtotal generally includes qualifying core
equipment.

It excludes, where applicable:

- installation;
- ExtendedCare;
- preventive maintenance;
- consumables;
- shipping;
- tax;
- promotional products;
- other explicitly excluded items.

### 10.5 Product Commercial Status

Supported commercial statuses include:

- NORMAL
- PROMOTIONAL
- PRICE_PROTECTED
- CLEARANCE

Commercial benefits do not automatically stack. Product-specific
restrictions remain applicable unless an authoritative, applicable rule
explicitly overrides them.

### 10.6 Rule Precedence

The governing principle is:

> **The most specific applicable authoritative rule takes precedence.**

Specificity alone is not sufficient. The rule must also apply to the
relevant customer, product, deal, user, condition, and effective period.

### 10.7 Historical Commercial Information

Historical discounts, expired agreements, and previous exceptions do not
automatically create current entitlement.

---

## 11. Warranty and Service Rules

Manufacturer warranty and Northstar service products are separate
concepts.

A product may include manufacturer warranty while an optional Northstar
ExtendedCare product provides additional coverage.

Eligibility for ExtendedCare may depend on conditions such as:

- eligible equipment;
- authorized installation;
- registration requirements;
- applicable customer agreement or package terms.

The Copilot must not describe optional ExtendedCare coverage as if it
were included manufacturer warranty.

---

## 12. Sources of Business Truth

Northstar information is conceptually distributed across the following
business systems.

Business Domain Authoritative Source

---

Account identity, tier, owner, opportunity CRM
Completed purchase/order history ERP / Order History
Inventory and incoming stock ERP
Product identity and lifecycle Product Master
Technical knowledge Manufacturer / Company Knowledge Documents
Commercial policy Northstar Commercial Documents
Customer-specific contractual terms Applicable Customer Agreement
Sales guidance Sales Playbooks / Advisory Documents

The Sales Copilot is not a source of truth.

---

## 13. Knowledge Authority Classes

Knowledge is grouped into four authority classes.

### A --- Manufacturer Technical

Examples:

- Specification Sheets
- Installation Guides
- Compatibility Matrices
- Product Bulletins
- Technical / Service Notices

### B --- Northstar Commercial

Examples:

- Equipment Volume Discount Policy
- Sales Approval Matrix
- Warranty / ExtendedCare Policy
- Promotional Product Policy
- Account Tier Policy

### C --- Customer-Specific

Examples:

- Strategic Account Agreement
- Preferred Account Agreement
- Pricing Addendum

### D --- Sales Advisory

Examples:

- Sales Playbook
- Qualification Guidance
- Negotiation Guidance
- Solution-Selling Guidance

Advisory guidance may inform recommendations but must not be presented
as authoritative policy.

---

## 14. Information-State Model

The system must communicate the strength of available information.

### CONFIRMED

Directly supported by applicable authoritative information.

### SUPPORTED / INFERRED

A conclusion derived from multiple confirmed facts but not explicitly
stated as a single authoritative fact.

### UNKNOWN

The connected sources do not contain sufficient information to answer
reliably.

### CONFLICT

Relevant authoritative sources disagree and the conflict cannot be
resolved through known applicability or precedence rules.

A successful Copilot response may therefore be a refusal to conclude
when the evidence does not support a reliable answer.

---

## 15. In Scope

The MVP includes:

- natural-language sales decision support;
- explicit sales-user, account, and opportunity context;
- product-fit support;
- customer-aware purchase and compatibility reasoning;
- commercial policy and agreement reasoning;
- inventory-aware feasibility support;
- deal-readiness and negotiation preparation;
- retrieval from structured business information;
- retrieval from company and manufacturer documents;
- current vs historical/superseded knowledge handling;
- evidence provenance;
- uncertainty and conflict handling;
- read-only use of business information;
- synthetic enterprise data and fictional documents;
- evaluation against independent expected outcomes.

---

## 16. Out of Scope

The MVP explicitly excludes:

- autonomous customer communication;
- automatic email sending;
- automated quotation generation;
- CRM write operations;
- ERP write operations;
- discount approval execution;
- automated approval requests;
- invoicing and payment processing;
- taxes / VAT calculation;
- currency-conversion complexity;
- import and customs processes;
- supplier procurement;
- logistics routing optimization;
- service-ticket management;
- installation scheduling integration;
- autonomous negotiation;
- customer credit management;
- salesperson commission calculation;
- full CPQ functionality;
- full ERP or CRM simulation.

These exclusions are intentional and prevent the project from becoming
an ERP, CPQ, CRM, or autonomous sales-agent implementation.

---

## 17. Non-Functional Requirements

### NFR-01 --- Groundedness

Material business conclusions must be based on available Northstar
business information rather than unsupported model knowledge.

### NFR-02 --- Traceability

The user must be able to identify the material sources supporting
important conclusions.

### NFR-03 --- Read-Only Safety

The MVP must not perform write operations against simulated business
systems.

### NFR-04 --- Controlled Uncertainty

The system must communicate missing information and unresolved conflicts
instead of fabricating certainty.

### NFR-05 --- Current-Information Awareness

The system must account for document lifecycle, effective periods,
agreement expiration, and product lifecycle where relevant.

### NFR-06 --- Consistency

Equivalent questions with equivalent business context should produce
materially consistent business conclusions.

### NFR-07 --- Separation of Business Truth and Evaluation Truth

Evaluation ground truth must not be accessible to the Copilot during
normal operation.

### NFR-08 --- Maintainability

Business knowledge should be updateable without requiring business rules
to be permanently embedded in prompts.

### NFR-09 --- Auditability

The prototype should retain sufficient execution information to
determine which business sources were consulted for evaluated
interactions.

### NFR-10 --- Human Control

Recommendations must remain advisory. Final commercial and
customer-facing decisions remain with authorized Northstar personnel.

---

## 18. Representative Business Scenarios

The MVP will be validated against a representative synthetic business
environment containing at least the following rich scenarios:

1.  **Meridian Hotels Group --- Three-Property Expansion**\
    Full-stack scenario covering product fit, installed equipment,
    compatibility, commercial authority, inventory, warranty, and
    negotiation readiness.

2.  **UrbanFork Restaurant Group --- Six-Outlet Expansion**\
    Product comparison where multiple products satisfy minimum
    requirements but differ in trade-offs.

3.  **Kopi Harian Nusantara --- Ten-Outlet Equipment Refresh**\
    Legacy-product and accessory compatibility scenario.

4.  **Nusantara Catering Services --- Central Kitchen Capacity
    Upgrade**\
    Minimum-fit versus recommended-fit reasoning.

5.  **Bayfront Resort Lombok --- Emergency Ice Equipment Replacement**\
    Inventory, incoming stock, urgency, and unresolved installation-fit
    scenario.

6.  **DapurKita Restaurant Group --- Kitchen Modernization**\
    Commercial exception and promotional-product restriction scenario.

7.  **Prima Hospitality Group --- Property Refurbishment**\
    Expired-agreement scenario demonstrating that historical precedent
    does not create current entitlement.

8.  **Artisan Bakehouse Indonesia --- Production Kitchen**\
    Missing technical information and technical-bulletin applicability
    scenario where the correct outcome may be insufficient information.

---

## 19. Representative Data Scale

Northstar's fictional company-level operating scale is:

- 300 active SKUs
- approximately 600 active B2B accounts

The prototype does not need to materialize the entire enterprise
population.

The working synthetic dataset is expected to contain approximately:

- 80 product records, including active and legacy products;
- 60 customer accounts;
- 12 sales users;
- 30 opportunities;
- 180--250 meaningful purchase/order lines;
- approximately 18 customer agreements or historical agreement
  records;
- inventory positions across multiple warehouses;
- approximately 30 incoming-stock records;
- approximately 55--70 knowledge documents;
- 8 deeply curated customer/opportunity scenarios.

The dataset should be representative and internally consistent rather
than artificially large.

---

## 20. Business Success Criteria

For the portfolio MVP, success is defined by demonstrated decision
quality rather than production-scale adoption metrics.

The solution should demonstrate that:

1.  A sales representative can ask questions within an active customer
    and opportunity context without manually assembling all relevant
    records and documents.
2.  The system can correctly determine when structured data, document
    knowledge, or both are required.
3.  Product recommendations are tied to documented customer requirements
    and product evidence.
4.  Customer-specific compatibility questions correctly incorporate both
    purchase history and current technical knowledge.
5.  Commercial answers correctly distinguish eligibility from delegated
    authority.
6.  Expired or superseded information does not silently override
    applicable current information.
7.  Inventory answers distinguish current availability from expected
    incoming stock.
8.  Missing operational or technical information results in an explicit
    uncertainty state rather than a false guarantee.
9.  Material conclusions provide traceable supporting sources.
10. Evaluation cases include successful answers, supported inferences,
    unknown outcomes, and unresolved conflicts.
11. The Copilot never executes a consequential sales action as part of
    the MVP.

Detailed quantitative evaluation metrics and test-case scoring will be
defined in the later AI Retrieval & Reasoning / Evaluation design.

---

## 21. Constraints and Assumptions

- All company names, brands, products, customers, agreements,
  policies, and operational records used by the project are fictional
  or synthetic.
- The synthetic environment is designed to model realistic B2B
  distribution behavior without claiming to reproduce a specific real
  company.
- The MVP assumes that relevant business information is accessible to
  the Copilot through controlled read-only interfaces.
- Some information is intentionally unavailable to test uncertainty
  handling.
- Some historical and superseded documents intentionally remain in the
  knowledge corpus to test lifecycle and applicability reasoning.
- Installation scheduling is intentionally unavailable in the MVP.
- The project prioritizes reliable decision support over autonomous
  action.

---

## 22. Key Business Principles

The project is governed by the following principles:

> **Agentic does not mean autonomous.**

The Copilot may decide what information to retrieve, but consequential
business actions remain human-controlled.

> **The Copilot is not a source of truth.**

Business truth remains in authoritative business systems and documents.

> **Specific applicable authority beats general authority.**

A specific rule only overrides a general rule where its scope and
conditions actually apply.

> **Allowed does not mean recommended.**

Commercial eligibility and sales guidance are separate concepts.

> **Unknown is a valid answer.**

The system should prefer explicit uncertainty over unsupported
confidence.

> **Historical does not mean current.**

Expired agreements, superseded policies, and legacy information must be
interpreted in context.

> **Realistic does not mean huge.**

A smaller internally consistent synthetic enterprise is more valuable
than a large but incoherent dataset.

---

## 23. Future Design Documents

This BRD defines the business problem, scope, requirements, and expected
behavior. It intentionally does not define implementation details.

The next design artifacts are:

1.  **Solution Design / High-Level Design (HLD)**
2.  **Data & Knowledge Design**
3.  **AI Retrieval & Reasoning Design**

Technology selection, physical schemas, vector-store decisions, workflow
decomposition, prompts, and implementation details will be defined only
after the appropriate design stage.

---

## 24. BRD v1 Baseline

BRD v1 establishes the following project baseline:

- The product is a semi-agentic, read-only AI Sales Copilot.
- The primary user is a B2B sales representative.
- The core business problem is fragmented information assembly before
  reliable customer-facing decisions.
- The MVP covers FIT, CONTEXT, COMMERCIAL, FEASIBILITY, and READINESS.
- The solution must combine structured business truth with
  authoritative document knowledge.
- Human users retain approval and execution authority.
- Groundedness, provenance, uncertainty handling, and source
  applicability are first-class requirements.
- Autonomous sales actions are outside the MVP.

Changes to these baseline decisions should be intentional and reflected
in subsequent document versions.
