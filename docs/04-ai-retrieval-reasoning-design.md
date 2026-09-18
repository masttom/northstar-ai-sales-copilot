# AI Sales Copilot --- AI Retrieval & Reasoning Design

**Version:** 1.0\
**Status:** Final

## 1. Purpose

This document defines how the AI Sales Copilot interprets conversational
requests, determines required evidence, retrieves structured business
data and company knowledge, validates evidence, resolves conflicts,
derives bounded conclusions, and produces grounded responses for sales
users.

The document defines behavioral and architectural rules rather than
implementation parameters. Embedding models, chunk sizes, top-K values,
similarity thresholds, reranking technology, caching intervals, and
physical n8n workflow decomposition are intentionally deferred until
implementation and evaluation.

## 2. Core Principle

The Copilot follows a bounded semi-agentic model:

**READ → RETRIEVE → REASON → RECOMMEND**

The AI may determine what information it needs and select bounded
retrieval capabilities. The system controls how authoritative business
information is accessed and validated, and deterministic guardrails
constrain consequential conclusions.

> **AI decides what information it needs; the system controls how
> authoritative business information is accessed and validated.**

The Copilot does not autonomously approve discounts, modify CRM records,
send quotations, commit inventory, promise installation dates, or
perform other consequential business actions.

## 3. End-to-End Reasoning Architecture

```text
User Message
      ↓
Context Resolution
      ↓
Claim & Intent Understanding
      ↓
Evidence Planning
      ↓
Agentic Information Gathering
├── Structured Business Tools
└── Knowledge Retrieval
      ↓
Evidence Assembly
      ↓
Evidence Validation
      ↓
Conflict Resolution
      ↓
Evidence Sufficiency
      ↓
Deterministic Guardrails
      ↓
Reasoning & Decision
      ↓
Structured Grounded Result
      ↓
Response Composer
      ↓
Grounded Sales Response
```

The five primary reasoning contexts are:

Context Primary Question

---

FIT What should I propose?
CONTEXT What applies to this customer?
COMMERCIAL What can I offer?
FEASIBILITY Can we actually deliver?
READINESS What should I know before talking to the customer?

These contexts guide reasoning but are not exclusive hard-routing
categories. A single request may span multiple contexts.

## 4. Evidence Requirements & Sufficiency

### 4.1 Claim-Level Requirements

Evidence requirements are determined by the **claim being made and its
business consequence**, not merely by the classified intent.

Evidence is classified conceptually as:

- **Required** --- the conclusion must not be confirmed without it.
- **Conditional** --- required when the claim depends on that
  condition.
- **Supporting** --- improves recommendation quality but does not
  independently block a conclusion when absent.

Missing required evidence limits the claim; it does not authorize the
model to fill the gap through inference.

### 4.2 FIT

FIT evaluates product suitability against customer requirements.

Evidence Requirement

---

Relevant customer requirements Required
Candidate product technical evidence Required
Product lifecycle/status Required
Installation requirements Conditional
Compatibility evidence Conditional
Existing installed products Conditional
Inventory Supporting
Commercial information Supporting
Sales guidance Supporting

Mandatory constraints are evaluated before preferences and trade-offs. A
product that fails a mandatory requirement is not treated as an
acceptable trade-off merely because it performs well elsewhere.

A recommendation such as "better aligned" is a derived conclusion, not
an objective product fact.

### 4.3 CONTEXT

CONTEXT determines what information applies to a specific customer.

Evidence Requirement

---

Correct account identity Required
Relevant customer history/state Required
Relevant product/business context Required
Applicable technical/customer knowledge Required
Opportunity context Conditional
Current agreement Conditional
Sales guidance Supporting

Technical documentation may establish compatibility, but
customer-specific reuse cannot be confirmed until the customer's
relevant ownership or installed-product history is also established.

### 4.4 COMMERCIAL

COMMERCIAL reasoning is intentionally strict because it may affect
pricing and authority.

Evidence Requirement

---

Sales-user identity and role Required
Account identity/current tier Required
Current deal context Required
Requested/current discount Required when relevant
Proposed products/eligible items Required when eligibility matters
Current applicable commercial policy Required
Approval authority rule Required
Active customer agreement/entitlement Conditional
Promotion/product exclusions Conditional
Sales guidance Supporting

The Copilot distinguishes **allowed** from **recommended**. Maximum
authority does not automatically represent the recommended negotiation
position.

### 4.5 FEASIBILITY

FEASIBILITY decomposes broad questions such as "Can we deliver?" into
the operational claims needed to answer them.

---

Evidence Requirement

---

Required product/configuration Required

Quantity Required

Relevant inventory position Required for stock claims

Incoming inventory and ETA Conditional

Target deployment date Required for timing claims

Installation requirements Conditional

Installation/service capacity Required for installation
commitments

Site information Conditional

---

Equipment availability does not establish installation capacity.
Incoming inventory ETA does not establish completed deployment.

### 4.6 READINESS

READINESS is a multi-domain aggregation context. Minimum context
normally includes the account, opportunity, known requirements, and
current solution where applicable. Commercial, technical, inventory,
historical, and advisory evidence is added when relevant.

A readiness response may cover deal position, product/solution position,
commercial position, operational feasibility, risks, open questions,
suggested talking points, and unsupported commitments that should not be
made.

### 4.7 Evidence Sufficiency

Evidence is sufficient for a claim when it is:

```text
AVAILABLE
+
RELEVANT
+
APPLICABLE
+
AUTHORITATIVE ENOUGH FOR THE CLAIM
+
NO UNRESOLVED CRITICAL CONFLICT
→ SUFFICIENT EVIDENCE
```

The threshold depends on the claim. Advisory recommendations may rely on
supported inference, while technical compatibility, commercial
authority, and customer commitments require appropriate authoritative
evidence.

## 5. Retrieval Strategy

### 5.1 Evidence-Driven Retrieval

Retrieval queries are derived from evidence needs rather than copied
directly from user wording.

A customer-specific question may therefore generate several retrieval
tasks across structured and unstructured sources.

### 5.2 Separate Retrieval Paths

```text
Current Business State
→ Bounded Structured Business Tools
→ PostgreSQL

Technical / Company / Customer Rules
→ Knowledge Retrieval
→ Pinecone

Advisory Guidance
→ Knowledge Retrieval
→ Pinecone
```

Pinecone is not a general-purpose business database.

### 5.3 Multi-Task Retrieval

One request may require several independent retrieval tasks. The
objective is not to find one perfect document but to assemble the
**smallest sufficient evidence set**.

### 5.4 Metadata-Aware Retrieval

Metadata narrows retrieval when constraints are known with sufficient
confidence. Relevant metadata may include document type, authority
class, product IDs, product family, account ID, agreement ID, lifecycle
status, revision, and effective dates.

Filters must not be so restrictive that potentially authoritative
evidence is excluded. Broader product-family documents or conditional
bulletins may remain relevant even when they do not contain every entity
identifier in metadata.

### 5.5 Retrieval Scope

Retrieval may operate in three conceptual modes:

- **Targeted** --- entities and required evidence are clearly known.
- **Contextual** --- the domain is known but several rules/documents
  may apply.
- **Exploratory** --- broader context is gathered before progressively
  narrowing the search.

### 5.6 Candidate Evidence

Vector results are **retrieval candidates**, not accepted truth.

Candidates must be evaluated for relevance, applicability, authority,
lifecycle, specificity, and consistency before supporting a conclusion.
A reranking or validation stage therefore exists conceptually after
initial retrieval; its technology is deferred.

### 5.7 Weak Retrieval

Nearest vector results are not necessarily relevant. Weak evidence may
be rejected. The Copilot must be able to conclude that no reliable
evidence was found rather than forcing an answer from semantically
related content.

Exact thresholds will be calibrated through evaluation.

### 5.8 Historical Knowledge

Historical and superseded documents remain retrievable for historical
terms, legacy products, and prior decisions. They must not silently
replace current applicable authority in current-state decisions.

### 5.9 Retrieval Stopping

Retrieval stops when required evidence is sufficient or reasonable
retrieval paths have been exhausted. Attempts are bounded and must avoid
repeatedly issuing equivalent searches.

### 5.10 Provenance

Accepted evidence retains traceability to its source document or
authoritative structured source. Retrieval metadata such as similarity
scores may be retained for debugging but is not itself business
evidence.

## 6. Evidence Validation & Conflict Resolution

### 6.1 Validation Pipeline

```text
Candidate Evidence
      ↓
Relevance
      ↓
Applicability
      ↓
Authority
      ↓
Lifecycle
      ↓
Specificity
      ↓
Consistency
      ↓
Accepted Evidence
or Rejected / Context-Only / Unresolved
```

**Different information is not automatically conflicting information.**

### 6.2 Relevance

Evidence must actually support the claim. Merely mentioning the same
product, customer, or topic is insufficient.

### 6.3 Applicability

Evidence may be correct but not applicable to the current case.
Applicability may depend on product, product family, customer,
agreement, date, revision, configuration, production batch, commercial
status, or conditions stated inside the document.

Not every applicability dimension must be metadata; applicability may be
established through both metadata and document content.

### 6.4 Authority

Authority is evaluated relative to the claim, not through one universal
ranking.

Examples:

- manufacturer technical evidence for technical requirements;
- Northstar commercial policy for general commercial rules;
- applicable customer-specific agreements for customer-specific terms;
- sales advisory material for non-authoritative guidance.

Authority also follows **information ownership**. Structured operational
facts remain governed by their authoritative structured source.

### 6.5 Specificity

The most specific applicable authoritative rule governs only within its
defined scope.

A customer agreement does not automatically override every company
policy. It governs only the provisions and conditions it explicitly
covers.

### 6.6 Lifecycle

Document lifecycle states are:

- `CURRENT`
- `SUPERSEDED`
- `RETIRED`

Current evidence is preferred for current-state decisions. Historical or
superseded evidence may remain valid for historical questions or legacy
equipment.

**Historical truth ≠ current applicability.**

### 6.7 Conflict Definition

A conflict exists when two or more relevant authoritative claims:

1.  appear applicable to the same decision context;
2.  imply materially different conclusions; and
3.  cannot be reconciled through scope, applicability, specificity,
    authority, lifecycle, or explicit supersession.

Conditional rules with unresolved applicability produce `UNKNOWN`, not
automatically `CONFLICT`.

### 6.8 Conflict Resolution

```text
Potential Contradiction
      ↓
Same Claim?
      ↓
Same Applicability?
      ↓
Explicit Supersession?
      ↓
More Specifically Applicable Rule?
      ↓
Authoritative vs Advisory?
      ↓
Can Conditions Reconcile the Claims?
      ↓
Resolved → Use Applicable Evidence
Unresolved → CONFLICT
```

Newer evidence does not automatically win.

### 6.9 Claim-Level Isolation

Missing or conflicting evidence limits the affected claim rather than
necessarily invalidating the entire response.

### 6.10 User Assertions

User statements provide conversational or hypothetical context but do
not overwrite authoritative business truth. Material discrepancies are
surfaced when relevant.

### 6.11 Evidence Lineage

```text
Conclusion
→ Claim
→ Accepted Evidence
→ Document Chunk / Structured Tool Result
→ Authoritative Source
```

This supports evaluation of whether the Copilot reached the correct
answer for the correct reason.

## 7. Reasoning & Decision Model

### 7.1 Claim-Level Reasoning

Multi-part requests are decomposed into material claims and reasoned
over independently before response synthesis.

A conceptual reasoning unit may contain:

```text
Claim
Required Evidence
Supporting Evidence
Accepted Evidence
Missing Evidence
Conflicting Evidence
Information State
Decision State
Conclusion
Conditions
Required Verification
Do Not Promise
```

This is a conceptual contract, not a finalized physical schema.

### 7.2 Information States

The Copilot uses four information states:

- **CONFIRMED** --- required authoritative evidence is available,
  applicable, sufficient, and free of unresolved critical conflict.
- **SUPPORTED / INFERRED** --- a conclusion is reasonably derived from
  validated evidence but is not itself directly established as an
  authoritative fact.
- **UNKNOWN** --- required evidence is unavailable after the relevant
  authoritative source was successfully checked, or applicability
  cannot be established because required context is missing.
- **CONFLICT** --- materially different authoritative evidence applies
  to the same claim and cannot be reconciled.

These states are evidence-based. The system does not use artificial
model-confidence percentages as substitutes for evidence quality.

### 7.3 System Condition

Source availability is modeled separately:

- `AVAILABLE`
- `DEGRADED`
- `FAILED`

A failed inventory lookup is not `UNKNOWN` inventory. It means inventory
could not be confirmed because the authoritative source could not be
accessed.

### 7.4 Conditional Conclusions

A conclusion may remain `CONFIRMED` when an explicit condition is part
of the authoritative rule. Material conditions must be preserved.

### 7.5 Derived Recommendations

Recommendations are distinguished from direct facts.

```text
Customer Requirements
      ↓
Candidate Facts
      ↓
Mandatory Constraints
      ↓
Trade-offs
      ↓
Customer Priorities
      ↓
Recommendation
```

A recommendation such as "better aligned" is normally
`SUPPORTED / INFERRED`, while the supporting technical facts may
individually be `CONFIRMED`.

### 7.6 Commercial Decision States

Commercial reasoning uses a separate decision dimension:

- `WITHIN AUTHORITY`
- `APPROVAL REQUIRED`
- `NOT ELIGIBLE`
- `INSUFFICIENT INFORMATION`
- `CONFLICT`

Information state describes how well the conclusion is established.
Decision state describes what the applicable commercial rules mean
operationally.

### 7.7 Fact → Rule → Decision

```text
FACTS
What is true about the current case?
      ↓
APPLICABLE RULES
What authoritative rules govern it?
      ↓
DERIVATION
What follows from applying those rules?
      ↓
DECISION
What can reliably be concluded?
```

The reasoning layer must never fill missing required evidence through
unsupported inference.

### 7.8 Language Strength

The strength of conclusion language must not exceed the strength of
validated evidence.

### 7.9 Allowed vs Recommended

Commercial permission and sales recommendation are separate. Policy
establishes what may be offered; advisory reasoning may separately
inform negotiation strategy.

### 7.10 Do Not Promise

When unresolved consequential dependencies prevent a reliable customer
commitment, the reasoning result may include explicit `Do Not Promise`
guidance.

### 7.11 Required Verification

`UNKNOWN` and `CONFLICT` should identify the next required information,
verification, or escalation path whenever possible.

### 7.12 Partial Answers

The Copilot maximizes useful grounded information without allowing
uncertainty in one claim to contaminate unrelated confirmed claims.

## 8. Response & Grounding Contract

### 8.1 Structured Grounded Result

Reasoning produces a structured grounded result before natural-language
response generation.

Conceptually:

```yaml
request_context:
  account:
  opportunity:
  sales_user:

claims:
  - claim:
    information_state:
    decision_state:
    conclusion:
    conditions:
    supporting_evidence:
    information_gaps:
    required_verification:
    do_not_promise:

sources:
  - source_id:
    source_type:
    title:
    revision:
```

The exact implementation schema is deferred.

### 8.2 Response Composer Boundary

The response composer formats and explains the grounded result. It does
not independently redo consequential reasoning.

It must not:

- upgrade certainty;
- remove material conditions;
- hide conflicts;
- fill missing evidence;
- invent a recommendation basis.

### 8.3 Adaptive Response Depth

Response structure adapts to complexity rather than following one rigid
template.

Simple questions may use:

```text
Conclusion
→ Material Condition
→ Short Evidence Basis
→ Sources
```

Incomplete/conflicting questions may use:

```text
What Is Known
→ What Cannot Be Confirmed
→ Why
→ Required Verification
→ Sources
```

READINESS requests may use:

```text
Deal Position
Product / Solution Position
Commercial Position
Feasibility
Risks
Open Questions
Do Not Promise
Suggested Talking Points
Sources
```

### 8.4 Conclusion First

Responses lead with the strongest conclusion permitted by validated
evidence.

### 8.5 Grounded Explanation

Evidence is synthesized into an explanation of why the conclusion
follows. Raw chunks are not dumped into the response.

### 8.6 Human-Readable Provenance

Material business facts and rules retain human-readable provenance.
Internal retrieval details such as similarity scores and chunk IDs are
not exposed unless needed for debugging.

### 8.7 Claim-Linked Sources

Sources remain linked to the claims they support, particularly in
complex multi-domain responses.

### 8.8 Conditions and Limitations

Material conditions and limitations are part of the conclusion and must
survive response compression or summarization.

### 8.9 UNKNOWN and CONFLICT Responses

An `UNKNOWN` response identifies what cannot be confirmed, what
information is missing, why it matters, and what should be verified.

A `CONFLICT` response identifies the unresolved issue, why available
evidence cannot resolve it, and the appropriate verification or
escalation path.

### 8.10 Do Not Promise

`Do Not Promise` is shown only when meaningful, not as an empty standard
section in every response.

### 8.11 Hypothetical Reasoning

Explicit hypothetical assumptions may be used for scenario analysis but
remain clearly separated from authoritative business truth and do not
mutate source data.

### 8.12 Citation Density

Consequential facts and rules should have visible provenance without
turning ordinary responses into citation-heavy diagnostic reports.

## 9. Context & Conversation Resolution

### 9.1 Context Types

The system distinguishes:

1.  **Authoritative Business Context** --- structured sources and
    authoritative documents.
2.  **Conversation Context** --- active entities, topics, and referents.
3.  **User-Provided / Hypothetical Context** --- assumptions or claims
    introduced in chat.

These may interact but are not equivalent sources of truth.

### 9.2 Working Context

A compact session context maintains conversational continuity.

```yaml
working_context:
  sales_user_id:
  account_id:
  opportunity_id:
  active_entities:
  active_topics:
  scenario_overrides:
```

It is not a new system of record and does not duplicate the underlying
business databases.

### 9.3 Reference Resolution

References are resolved before evidence planning. Resolved entities are
normalized to canonical business IDs whenever possible.

### 9.4 Ambiguity

Implicit references are resolved automatically when sufficiently
unambiguous. If ambiguity could materially change the conclusion, the
Copilot asks a targeted clarification rather than guessing.

### 9.5 Conversation Is Not Business Truth

Conversation remembers what was said; authoritative sources establish
what is true.

### 9.6 Evidence Reuse and Freshness

Previously grounded evidence may be reused when appropriate. Mutable
facts must be refreshed when current state materially affects the
answer. Exact caching/freshness intervals are implementation decisions.

### 9.7 Context Switching

Explicit account or opportunity switches replace customer-specific
working context to prevent information leakage between discussions.

### 9.8 Opportunity Disambiguation

When multiple opportunities remain plausible and deal context affects
the conclusion, targeted clarification is required.

### 9.9 Hypothetical Scenario Overrides

Scenario values remain separate from base authoritative state and never
mutate the underlying opportunity or other source data.

### 9.10 Previous Copilot Outputs

Previous Copilot responses may provide conversational reference but
never become authoritative evidence for their own conclusions.

### 9.11 Responsibility Boundaries

```text
Context Resolver
→ What object or discussion is the user referring to?

Evidence Validator
→ Is the retrieved information applicable and authoritative?

Reasoning Layer
→ What conclusion follows from the validated evidence?
```

## 10. Deterministic Guardrails

The Copilot is semi-agentic, but consequential claims are bounded by
deterministic requirements.

Examples:

- commercial authority claims require applicable authority evidence;
- customer-specific compatibility claims require customer context plus
  technical compatibility evidence;
- deployment commitments require confirmation of all critical
  operational dependencies;
- missing required evidence cannot be replaced by model intuition;
- unresolved authoritative conflicts cannot be silently resolved by
  the model.

The system therefore permits flexible information gathering while
maintaining controlled decision boundaries.

## 11. Failure & Uncertainty Boundaries

The design explicitly distinguishes:

### Information Uncertainty

The relevant source was successfully checked, but required information
is unavailable or applicability cannot be established.

→ `UNKNOWN`

### Evidence Conflict

Applicable authoritative evidence materially disagrees and cannot be
reconciled.

→ `CONFLICT`

### Source/System Failure

The authoritative source could not be checked.

→ `DEGRADED` or `FAILED`

A failed source lookup must not be represented as if the underlying
business information itself were known to be unavailable.

## 12. Deferred Implementation Decisions

The following are intentionally deferred until the actual synthetic
dataset and document corpus exist and can be evaluated:

- document extraction implementation;
- normalization implementation;
- chunk size and overlap;
- embedding model;
- Pinecone index and namespace details;
- metadata-filter implementation;
- retrieval top-K;
- similarity/relevance thresholds;
- reranking technology;
- query expansion implementation;
- retrieval-attempt limits;
- caching and freshness intervals;
- exact structured grounded-result schema;
- exact bounded tool definitions;
- physical n8n workflow decomposition;
- prompt implementation.

These parameters will be selected and calibrated against the actual
corpus and evaluation set rather than guessed during architecture
design.

## 13. Design Summary

The AI Sales Copilot is a grounded, semi-agentic decision-support system
rather than a generic question-answering chatbot.

The architecture:

- resolves conversational context without treating chat history as
  business truth;
- decomposes requests into claims and evidence needs;
- separates structured business truth from document knowledge;
- retrieves multiple evidence sources when required;
- validates relevance, applicability, authority, lifecycle, and
  specificity;
- resolves apparent contradictions deterministically where possible;
- surfaces unresolved conflict rather than guessing;
- distinguishes confirmed facts from supported recommendations;
- limits claim strength to available evidence;
- identifies missing information and required verification;
- preserves material conditions and provenance;
- provides useful partial answers when only part of a request can be
  established;
- prevents consequential conclusions when mandatory evidence is
  absent;
- produces concise, adaptive, grounded responses for sales users.

The resulting architecture supports the Copilot's core objective:

> **Help sales representatives assemble reliable business context and
> company knowledge into evidence-backed recommendations without
> allowing the AI to invent missing facts or autonomously make
> consequential business decisions.**
