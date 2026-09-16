# AI Sales Copilot

## High-Level Design (HLD) --- Version 1.0

**Organization:** Northstar Commercial Solutions\
**Document Status:** Final\
**Version:** 1.0\
**Date:** 16 September 2026

------------------------------------------------------------------------

## 1. Purpose

This document translates the approved Business Requirements Document
(BRD) into a high-level solution architecture for the AI Sales Copilot.

It defines the major components, responsibilities, boundaries,
information flows, integration patterns, control model, and key
architectural decisions. It intentionally does not define database
schemas, prompts, chunking rules, individual n8n nodes, low-level API
contracts, or workflow implementation details.

------------------------------------------------------------------------

## 2. Solution Overview

The AI Sales Copilot is a read-only, semi-agentic decision-support
system for Northstar sales representatives.

Each interaction is anchored to an explicit context:

-   Sales User
-   Customer Account
-   Active Opportunity / Deal

The Copilot interprets the question, determines what information is
required, selectively retrieves structured business data and/or
document-based company knowledge, evaluates the evidence, and returns a
grounded response with relevant provenance.

The operating principle is:

**READ → RETRIEVE → REASON → RECOMMEND**

The Copilot may choose approved information-retrieval capabilities, but
it does not execute consequential business actions.

------------------------------------------------------------------------

## 3. Architecture Principles

### 3.1 Business Systems Remain the Source of Truth

The Copilot does not become a new source of business truth.
Authoritative information remains in the simulated CRM, ERP, Product
Master, and Document Repository domains.

### 3.2 Structured and Unstructured Information Are Separate Concerns

Structured operational facts are retrieved from structured business
sources. Technical knowledge, commercial rules, agreements, and sales
guidance are retrieved through the document-knowledge path.

### 3.3 Bounded Tool Access

The AI does not receive unrestricted database access or arbitrary SQL
execution capability. Structured information is exposed through bounded,
read-only business capabilities.

### 3.4 Human Control

The system provides decision support only. It does not modify records,
approve discounts, request approvals automatically, send quotations or
customer communications, negotiate autonomously, or execute orders.

### 3.5 Evidence Before Confidence

Material conclusions must be supported by available evidence. Incomplete
or conflicting evidence must result in explicit uncertainty rather than
manufactured certainty.

### 3.6 Applicability Matters

Retrieval relevance alone is insufficient. Authority, status, effective
period, customer/product applicability, revision, and supersession must
be considered.

### 3.7 Technology Follows the Requirement

Components are introduced only where they serve a defined business or
technical requirement. The prototype should avoid unnecessary simulation
of complete enterprise applications.

------------------------------------------------------------------------

## 4. System Context

``` text
                         SALES REPRESENTATIVE
                                  |
                                  v
                         COPILOT INTERFACE
                                  |
                                  v
                       AI SALES COPILOT
                         ORCHESTRATION
                                  |
                 +----------------+----------------+
                 |                                 |
                 v                                 v
        BUSINESS DATA ACCESS              KNOWLEDGE RETRIEVAL
                 |                                 |
                 v                                 v
        STRUCTURED DATA STORE              VECTOR KNOWLEDGE INDEX
                 |                                 ^
       +---------+---------+                       |
       |         |         |                       |
      CRM       ERP    PRODUCT MASTER       KNOWLEDGE INGESTION
       \         |         /                       ^
        \        |        /                        |
         SYNTHETIC BUSINESS DATA            DOCUMENT REPOSITORY
```

The CRM, ERP, and Product Master remain logically separate domains even
if the prototype uses one physical relational database.

------------------------------------------------------------------------

## 5. Major Solution Components

### 5.1 Copilot Interface

**Purpose:** Provide the user-facing interaction surface.

**Responsibilities:**

-   establish sales-user context;
-   select customer and opportunity context;
-   accept natural-language questions;
-   display grounded responses;
-   display relevant evidence/source references;
-   preserve conversational continuity where appropriate.

**Selected MVP interface:** n8n Hosted Chat.

The MVP uses n8n Hosted Chat as the conversational interaction surface
so the project can focus on retrieval, reasoning, and business-data
integration without introducing a separate frontend application.

The interface is not responsible for authoritative data storage or
business reasoning. A custom interface may replace the MVP interface in
the future without changing the core Copilot architecture.

### 5.2 AI Orchestration Layer

**Purpose:** Coordinate each Copilot interaction.

**Responsibilities:**

-   receive the question and deal context;
-   interpret the information need;
-   determine required information capabilities;
-   invoke structured-data tools and/or knowledge retrieval;
-   assemble evidence;
-   coordinate grounded reasoning;
-   return the response and information state;
-   capture execution telemetry.

**Selected technology:** n8n.

**Selected orchestration approach:** Hybrid.

The Copilot uses agentic information gathering to determine which
approved information capabilities are needed, while deterministic
guardrails are applied where authoritative or business-critical
decisions require mandatory evidence or controlled evaluation.

The exact n8n workflow decomposition and node-level implementation are
deferred.

### 5.3 Business Data Access Layer

**Purpose:** Provide controlled read-only access to structured business
information.

Conceptual capabilities include:

-   Get Account Context
-   Get Opportunity
-   Get Purchase History
-   Search Products
-   Check Inventory
-   Get Active Commercial Entitlement

Each capability uses constrained inputs and predictable outputs. The AI
is not given unrestricted SQL access.

### 5.4 Structured Business Data Store

**Selected technology:** PostgreSQL.

One physical PostgreSQL instance may represent several logical business
domains:

**CRM** - Accounts - Sales Users - Opportunities - Commercial
Entitlements

**ERP** - Orders - Order Lines - Inventory Positions - Incoming
Inventory

**Product Master** - Products

This is a prototype simplification and does not imply that a real
enterprise would use one application for all domains.

### 5.5 Document Repository

The repository contains the actual synthetic documents representing
Northstar and manufacturer knowledge, including:

-   manufacturer technical documents;
-   Northstar commercial policies;
-   customer-specific agreements;
-   sales advisory documents;
-   intentionally retained historical, expired, or superseded documents.

The source documents remain authoritative; the vector index is a
retrieval representation, not the document system of record.

### 5.6 Knowledge Ingestion Capability

High-level flow:

``` text
Document Added / Updated
        |
        v
Content Extraction
        |
        v
Normalization
        |
        v
Metadata Validation / Enrichment
        |
        v
Chunking
        |
        v
Embedding Generation
        |
        v
Vector Index Upsert
        |
        v
Indexing Result / Telemetry
```

The process must preserve metadata required for document identity,
authority, status, revision, effective period, applicability, and
supersession.

Detailed extraction, chunking, embedding, and re-indexing rules are
deferred.

### 5.7 Vector Knowledge Index

**Purpose:** Support semantic retrieval over processed company
knowledge.

The index must support retrieval using semantic relevance together with
metadata such as document type, authority class, lifecycle status,
product context, customer context, and effective period.

**Selected technology:** Pinecone.

Pinecone is used as the vector knowledge index for processed document
content. PostgreSQL remains the runtime source for structured business
truth; Pinecone does not replace the relational business-data layer.

### 5.8 Knowledge Retrieval Capability

**Purpose:** Return relevant document evidence with provenance.

Conceptual inputs may include:

-   query;
-   information type;
-   account context;
-   product/product-family context;
-   document-type constraints;
-   effective-date context.

Conceptual outputs should include:

-   relevant passages;
-   document ID and title;
-   document type;
-   revision and status;
-   effective period;
-   authority class;
-   relevant applicability metadata.

The capability must not return evidence text without provenance.

### 5.9 Deal and Conversation Context

**Explicit business context** - Sales User - Account - Opportunity

**Conversation context** - previous questions; - follow-up references; -
temporary conversational information.

Conversation context supports continuity but cannot silently overwrite
authoritative business records.

------------------------------------------------------------------------

## 6. Logical Information Architecture

### 6.1 Structured Business Truth

Examples include account tier, opportunity stage, product lifecycle,
completed purchase history, inventory availability, incoming-stock ETA,
and active commercial-entitlement status.

### 6.2 Document Knowledge

Examples include technical specifications, compatibility rules,
installation requirements, warranty rules, commercial policies, approval
matrices, customer agreements, and sales guidance.

### 6.3 Derived Conclusions

Examples include:

-   existing equipment is reusable only with a specified accessory;
-   a requested discount exceeds delegated authority;
-   one product better aligns with customer priorities despite multiple
    valid fits;
-   stock is confirmed while the complete deployment timeline remains
    unknown.

Derived conclusions are produced at runtime and are not stored as
authoritative business facts.

------------------------------------------------------------------------

## 7. High-Level Interaction Patterns

### 7.1 Structured-Only

Example: *What equipment has Meridian purchased from us?*

``` text
Question
  → Resolve Account
  → Get Purchase History
  → ERP / Order Data
  → Grounded Response
```

### 7.2 Knowledge-Only

Example: *What is the standard warranty for Polarix IC-420?*

``` text
Question
  → Resolve Product
  → Knowledge Retrieval
  → Applicable Documents
  → Grounded Response + Source
```

### 7.3 Hybrid

Example: *Can Meridian reuse its existing WF-300 filters with IC-420?*

``` text
Question
   |
   +→ Purchase History → Confirm Meridian owns WF-300
   |
   +→ Knowledge Retrieval → Current compatibility evidence
   |
   → Evidence Assembly
   → Grounded Reasoning
   → Response + Provenance
```

Hybrid structured-data and document reasoning is a core architectural
requirement.

### 7.4 Commercial Decision Support

A commercial question may require sales-user role, account,
opportunity/deal composition, active entitlement, customer agreement,
current approval policy, and product restrictions.

The result may be:

-   WITHIN AUTHORITY
-   APPROVAL REQUIRED
-   NOT ELIGIBLE
-   INSUFFICIENT INFORMATION
-   CONFLICT

No approval action is executed.

### 7.5 Operational Feasibility

The Copilot may retrieve the proposed solution, current inventory,
reserved stock, incoming inventory, ETA, and relevant dependencies.

Because installation scheduling is outside the MVP, the system must not
guarantee a full deployment timeline when installation capacity is
required but unavailable.

------------------------------------------------------------------------

## 8. Knowledge Lifecycle and Applicability

Documents may be:

-   ACTIVE
-   SUPERSEDED
-   EXPIRED
-   HISTORICAL

A newer document does not automatically invalidate every use of an older
document.

Examples:

-   a legacy product may still require an older technical guide;
-   an expired agreement may remain valid historical evidence but not
    current entitlement;
-   a current technical bulletin may override a specific requirement
    only for affected revisions or batches.

The architecture must therefore preserve enough metadata to distinguish
relevance from authority and applicability.

------------------------------------------------------------------------

## 9. Source Precedence

The system must not use a universal hierarchy such as
`Agreement > Policy > Technical Document`.

The governing principle is:

**The most specific applicable authoritative rule takes precedence.**

Applicability may depend on:

-   subject and scope;
-   customer;
-   product;
-   product revision/batch;
-   effective date;
-   document status;
-   explicit override conditions.

If authoritative sources remain contradictory after applicability
checks, the correct state is **CONFLICT**.

Detailed precedence logic is deferred to the AI Retrieval & Reasoning
Design.

------------------------------------------------------------------------

## 10. Response and Evidence Design

Material answers should communicate:

-   the direct conclusion;
-   information/decision state;
-   supporting facts;
-   applicable policy or technical evidence;
-   relevant limitations;
-   required approval/escalation where applicable;
-   source provenance.

The exact visual presentation is not defined in this HLD.

------------------------------------------------------------------------

## 11. Information and Decision States

General information states:

-   CONFIRMED
-   SUPPORTED / INFERRED
-   UNKNOWN
-   CONFLICT

Commercial states:

-   WITHIN AUTHORITY
-   APPROVAL REQUIRED
-   NOT ELIGIBLE
-   INSUFFICIENT INFORMATION
-   CONFLICT

These states are part of system behavior and must not exist only as
unconstrained free-form model wording.

------------------------------------------------------------------------

## 12. Security and Control Boundaries

### 12.1 Read-Only Business Access

All Copilot-accessible business-data capabilities are read-only for the
MVP.

### 12.2 No Arbitrary SQL

The AI does not receive unrestricted SQL execution capability.

### 12.3 No Consequential Actions

The Copilot cannot update records, alter inventory, create orders,
approve concessions, send external communications, issue final
quotations, or initiate fulfillment.

### 12.4 Evaluation Isolation

Evaluation ground truth must be logically or physically separated from
runtime information accessible to the Copilot.

### 12.5 Synthetic Environment

The prototype uses fictional organizations, customers, products,
agreements, policies, and operational records. Real confidential
enterprise data is not required.

------------------------------------------------------------------------

## 13. Observability and Failure Handling

The solution should capture sufficient telemetry without unnecessary
operational complexity.

### Ingestion

Capture unreadable documents, extraction failures, metadata-validation
failures, embedding failures, and vector-index failures.

### Retrieval and Business Tools

Capture capability used, success/failure, relevant source identifiers,
and useful latency information.

### Copilot Interactions

For evaluated interactions, retain the question, active context,
information capabilities used, consulted sources, resulting state, and
evaluation outcome where applicable.

### Failure Semantics

The system must distinguish:

-   no applicable result;
-   source unavailable;
-   retrieval failure;
-   insufficient evidence.

A failed source must not be silently interpreted as proof that
information does not exist.

------------------------------------------------------------------------

## 14. Synthetic Data and Runtime Representation

Human-readable synthetic source files remain separate from runtime
storage.

Representative artifacts may include:

``` text
data/
  accounts.csv
  sales_users.csv
  opportunities.json
  orders.csv
  order_lines.csv
  products.csv
  inventory.csv
  incoming_inventory.csv
  commercial_entitlements.csv
```

These files support transparency, version control, reproducibility,
review, and database seeding.

At runtime, structured business information is represented in
PostgreSQL.

------------------------------------------------------------------------

## 15. Document Corpus Representation

The knowledge repository contains actual documents rather than manually
inserted answer strings.

Conceptually:

``` text
knowledge/
  products/
  commercial/
  agreements/
  sales/
  archive/
```

The exact directory structure is not locked by this HLD.

Current and historical documents may coexist to support lifecycle and
applicability testing.

------------------------------------------------------------------------

## 16. Evaluation Architecture Boundary

Evaluation is external to normal Copilot reasoning.

``` text
              RUNTIME SYSTEM
                    |
            AI SALES COPILOT
                    |
         Runtime Business Sources

--------------------------------------

             EVALUATION LAYER
                    |
          Independent Test Cases
                    |
       Expected Outcomes / Oracle
                    |
            Compare / Evaluate
```

Evaluation artifacts may include test questions, scenario context,
expected states, required evidence, compatibility ground truth, and
expected missing-information behavior.

The runtime Copilot cannot access these artifacts.

------------------------------------------------------------------------

## 17. Deployment Context

The prototype is expected to run in a controlled development or
portfolio environment.

The solution may reuse the existing self-hosted automation environment
where appropriate, but deployment topology is not yet part of the design
baseline.

Enterprise production concerns such as SSO, high availability, disaster
recovery, multi-region deployment, and enterprise network architecture
are outside the MVP unless later required.

------------------------------------------------------------------------

## 18. Key Architectural Decisions

  -----------------------------------------------------------------------
  Decision                            Status
  ----------------------------------- -----------------------------------
  Semi-agentic, read-only Copilot     Locked

  n8n Hosted Chat as MVP interface    Locked

  n8n as orchestration platform       Locked

  Hybrid orchestration: agentic       Locked
  information gathering with          
  deterministic guardrails            

  PostgreSQL for structured runtime   Locked
  data                                

  Pinecone for vector knowledge index Locked

  Logical CRM / ERP / Product Master  Locked
  separation                          

  One physical relational DB may      Locked
  represent multiple logical systems  

  Bounded read-only business-data     Locked
  capabilities                        

  No arbitrary AI-generated SQL       Locked

  Actual document corpus as knowledge Locked
  source                              

  Dedicated knowledge-ingestion       Locked
  capability                          

  Dedicated knowledge-retrieval       Locked
  capability                          

  Explicit Sales User + Account +     Locked
  Opportunity context                 

  Conversation context does not       Locked
  overwrite business truth            

  Source provenance in material       Locked
  responses                           

  Explicit uncertainty/conflict       Locked
  states                              

  Evaluation truth isolated from      Locked
  runtime                             
  -----------------------------------------------------------------------

Detailed implementation choices such as embedding model, document
extraction, chunking, retrieval ranking, workflow decomposition, and
physical schema/index design are intentionally deferred to downstream
design artifacts.

------------------------------------------------------------------------

## 19. Key Design Risks

### 19.1 Semantic Relevance Without Authority

Relevant text may not be current or applicable. Retrieval must account
for metadata, lifecycle, and scope.

### 19.2 Excessive Metadata Filtering

Overly strict filters may exclude valid family-level, category-level, or
bulletin-level evidence.

### 19.3 Duplicate Sources of Truth

Business rules should not be duplicated as hardcoded database facts and
documents without a clear authoritative relationship.

### 19.4 Prompt-Embedded Business Logic

Embedding commercial or compatibility rules permanently in prompts would
reduce maintainability and undermine the RAG objective.

### 19.5 Demo-Tailored Synthetic Data

The dataset must represent an internally consistent fictional business
rather than exist only to answer predetermined demo questions.

### 19.6 False Certainty From Partial Availability

A successful query against one source does not prove that all required
evidence is available.

### 19.7 Architecture Inflation

Logical business-system separation is sufficient where physical
separation provides no meaningful prototype value.

------------------------------------------------------------------------
