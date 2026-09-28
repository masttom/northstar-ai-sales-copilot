# Business Data Tools Design

**Project:** Semi-Agentic AI Sales Copilot  
**Company:** Northstar Commercial Solutions  
**Version:** v1  
**Status:** Complete — v1

---

## 1. Purpose

This document defines the bounded Business Data Tools used by the AI Sales Copilot to retrieve authoritative structured business data from PostgreSQL.

These tools provide controlled access to business facts required by the Copilot's reasoning process.

They do not make sales decisions, interpret policy, determine technical compatibility, recommend products, or perform business actions.

The design follows a core principle:

> Tool inventory follows business questions, not database tables.

The AI may decide which approved tool is required, but each tool controls:

- what business question it answers,
- what inputs it accepts,
- what authoritative data it can access,
- what structured evidence it returns,
- and what it is explicitly not allowed to decide.

---

## 2. Design Principles

### 2.1 Bounded Access

Each tool has a specific business purpose and a defined input/output contract.

The Copilot does not receive unrestricted database access.

Tools such as the following are intentionally excluded:

- `run_sql()`
- `search_database()`
- `get_everything_about_customer()`

This prevents the reasoning layer from constructing arbitrary database queries or bypassing established data-access boundaries.

---

### 2.2 Facts Before Decisions

Business Data Tools retrieve authoritative structured facts.

They do not make reasoning conclusions.

For example:

- `get_inventory()` retrieves inventory positions and incoming inventory, but does not decide whether delivery can be promised.
- `get_commercial_context()` retrieves agreements and entitlements, but does not determine the discount a sales rep should offer.
- `get_product_details()` retrieves Product Master facts, but does not determine technical compatibility or product suitability.

Interpretation belongs to the reasoning layer using the appropriate structured and knowledge evidence.

---

### 2.3 Canonical Identity

Business entities must be resolved to canonical system identifiers before downstream retrieval whenever identity is not already established.

Examples:

- Customer → `account_id`
- Product → `product_id`
- Opportunity → `opportunity_id`

Natural-language references must not be treated as authoritative identifiers.

---

### 2.4 Ambiguity Is Preserved

Resolver tools must not silently choose between multiple plausible records.

Possible resolution outcomes are:

- zero matches → unresolved
- one match → unique candidate
- multiple matches → ambiguous

Candidate ranking may determine result order, but it must not be interpreted as a confidence score or automatic selection rule.

---

### 2.5 Unknown Is Not Failure

A valid tool request that returns no matching business record is a legitimate information state.

It must remain distinguishable from:

- invalid tool input,
- database failure,
- tool execution failure.

A missing record must not be fabricated or inferred merely to complete the reasoning process.

---

### 2.6 Parameterized Database Access

Database queries must use parameterized SQL.

User-controlled values must not be directly concatenated into executable SQL statements.

This keeps database access predictable and prevents user input from altering SQL structure.

---

### 2.7 Read-Only Scope

Business Data Tools v1 are read-only.

They do not:

- update CRM data,
- modify opportunities,
- create quotations,
- change inventory,
- approve discounts,
- modify agreements,
- send customer communication.

---

## 3. Tool Inventory

| Tool                                            | Business Purpose                                                   | Status    |
| ----------------------------------------------- | ------------------------------------------------------------------ | --------- |
| `resolve_account(query)`                        | Resolve an account reference to canonical account candidates       | Validated |
| `resolve_product(query)`                        | Resolve a product reference to canonical Product Master candidates | Validated |
| `get_account_context(account_id)`               | Retrieve current account and ownership context                     | Validated |
| `get_opportunity(opportunity_id)`               | Retrieve opportunity context and proposed solution lines           | Validated |
| `get_product_details(product_id)`               | Retrieve structured Product Master facts                           | Validated |
| `get_purchase_history(account_id, product_id?)` | Retrieve completed purchase history                                | Validated |
| `get_inventory(product_id)`                     | Retrieve inventory positions and incoming inventory                | Validated |
| `get_commercial_context(account_id)`            | Retrieve agreement and entitlement context                         | Validated |

---

## 4. Shared Resolver Behavior

Resolver tools translate user-facing entity references into canonical identifiers used by the structured business data layer.

They are responsible for candidate discovery, not business reasoning.

A resolver must:

1. validate that the input is present and usable,
2. search only approved identity fields,
3. return matching canonical candidates,
4. preserve ambiguity,
5. return an unresolved state when no candidate exists.

A resolver must not:

- invent an entity,
- use an LLM-generated mapping as authoritative evidence,
- silently choose between ambiguous candidates,
- convert candidate ranking into business certainty.

---

## 5. Account Resolver

### 5.1 `resolve_account(query)`

**Status:** Validated

### Purpose

Resolve an account reference into canonical account candidates from the authoritative Account data.

The reference may be a known account identifier, full account name, or partial account name.

---

### Input Contract

```json
{
  "query": "<account reference>"
}
```

Requirements:

- `query` is required.
- `query` must be a non-empty string.

---

### Authoritative Search Fields

The resolver searches:

- `account_id`
- `account_name`

Matching is case-insensitive.

The resolver supports:

- exact identifier matching,
- exact account-name matching,
- partial matching.

Fuzzy or typo-based matching is not performed in v1.

---

### Candidate Contract

Each matching candidate returns:

```json
{
  "account_id": "<canonical account_id>",
  "account_name": "<account name>",
  "segment": "<segment>",
  "account_tier": "<account tier>",
  "sales_territory": "<sales territory>"
}
```

These additional fields provide enough context to distinguish candidates without turning the resolver into a full account-context retrieval tool.

---

### Output Contract

The resolver returns:

```json
{
  "query": "<original query>",
  "match_count": 1,
  "matches": [
    {
      "account_id": "<canonical account_id>",
      "account_name": "<account name>",
      "segment": "<segment>",
      "account_tier": "<account tier>",
      "sales_territory": "<sales territory>"
    }
  ]
}
```

For multiple matches:

```json
{
  "query": "<original query>",
  "match_count": 2,
  "matches": [
    {
      "account_id": "<candidate account_id>",
      "account_name": "<candidate account name>",
      "segment": "<segment>",
      "account_tier": "<account tier>",
      "sales_territory": "<sales territory>"
    },
    {
      "account_id": "<candidate account_id>",
      "account_name": "<candidate account name>",
      "segment": "<segment>",
      "account_tier": "<account tier>",
      "sales_territory": "<sales territory>"
    }
  ]
}
```

For no match:

```json
{
  "query": "<original query>",
  "match_count": 0,
  "matches": []
}
```

A zero-match result represents unresolved identity, not tool failure.

---

### Boundaries

`resolve_account()` does not:

- retrieve full account context,
- retrieve purchase history,
- retrieve opportunities,
- retrieve agreements or entitlements,
- infer identity from unrelated business attributes,
- choose between ambiguous candidates,
- modify account data.

---

## 6. Product Resolver

### 6.1 `resolve_product(query)`

**Status:** Validated

### Purpose

Resolve a product reference into canonical Product Master candidates.

The resolver explicitly distinguishes between:

- user/model references,
- SKU,
- product name,
- canonical `product_id`.

A user-facing model reference must not automatically be treated as a canonical Product Master identifier.

---

### Input Contract

```json
{
  "query": "<product reference>"
}
```

Requirements:

- `query` is required.
- `query` must be a non-empty string.

---

### Authoritative Search Fields

The resolver searches:

- `product_id`
- `sku`
- `product_name`

---

### Normalization Rules

Matching is case-insensitive.

For normalized matching, the resolver ignores:

- hyphens (`-`),
- spaces.

This allows formatting variations to resolve consistently without requiring fuzzy matching.

For example, references with or without formatting separators may resolve to the same Product Master candidate.

The resolver does not perform arbitrary typo correction in v1.

A reference containing a possible typo must not automatically be rewritten into another product reference.

---

### Candidate Ranking

Matching candidates are ordered using the following deterministic ranking:

| Rank | Match Type                |
| ---: | ------------------------- |
|    0 | `EXACT_PRODUCT_ID`        |
|    1 | `EXACT_SKU`               |
|    2 | `EXACT_PRODUCT_NAME`      |
|    3 | `NORMALIZED_EXACT_SKU`    |
|    4 | `NORMALIZED_EXACT_NAME`   |
|    5 | `NORMALIZED_PARTIAL_SKU`  |
|    6 | `NORMALIZED_PARTIAL_NAME` |
|    7 | `PARTIAL`                 |

`match_rank` is an ordering mechanism.

It is not a confidence score and does not authorize automatic candidate selection when multiple candidates are returned.

---

### Candidate Contract

Each candidate returns:

```json
{
  "product_id": "<canonical product_id>",
  "sku": "<sku>",
  "product_name": "<product name>",
  "brand": "<brand>",
  "category": "<category>",
  "product_family": "<product family>",
  "lifecycle_status": "<lifecycle status>",
  "commercial_status": "<commercial status>",
  "match_type": "<match type>",
  "match_rank": 0
}
```

The resolver returns identity and lightweight distinguishing information only.

Technical specifications, compatibility rules, inventory, and commercial interpretation belong to other tools or knowledge sources.

---

### Output Contract

The resolver returns:

```json
{
  "query": "<original query>",
  "match_count": 1,
  "matches": [
    {
      "product_id": "<canonical product_id>",
      "sku": "<sku>",
      "product_name": "<product name>",
      "brand": "<brand>",
      "category": "<category>",
      "product_family": "<product family>",
      "lifecycle_status": "<lifecycle status>",
      "commercial_status": "<commercial status>",
      "match_type": "<match type>",
      "match_rank": 0
    }
  ]
}
```

For multiple candidates, all applicable candidates are returned in ranking order.

For no match:

```json
{
  "query": "<original query>",
  "match_count": 0,
  "matches": []
}
```

A zero-match result represents unresolved product identity, not tool failure.

---

### Boundaries

`resolve_product()` does not:

- recommend a product,
- determine product suitability,
- determine technical compatibility,
- retrieve inventory,
- interpret commercial policy,
- correct arbitrary product-name typos,
- choose between ambiguous candidates,
- generate authoritative product mappings using AI,
- modify Product Master data.

---

## 7. Retrieval Tools

Retrieval tools provide bounded access to authoritative structured business facts after the relevant entity identity has been established.

Unlike resolver tools, retrieval tools accept canonical identifiers and retrieve a defined business context.

A retrieval tool must not absorb responsibilities assigned to another tool merely for convenience.

---

### 7.1 `get_account_context(account_id)`

**Status:** Validated

#### Purpose

Retrieve the current structured business context of a canonical account.

The tool answers:

> What is the current identity, classification, territory, status, and ownership context of this account?

It intentionally provides only account and ownership context.

Commercial agreements, purchase history, opportunities, inventory, and other business domains remain the responsibility of their respective bounded tools.

---

#### Input Contract

```json
{
  "account_id": "<canonical account_id>"
}
```

Requirements:

- `account_id` is required.
- `account_id` must be a non-empty string.
- The input is expected to be a canonical account identifier established by authoritative context or prior entity resolution.

Missing or unusable input is treated as an input error, not as an unresolved account.

---

#### Authoritative Sources

The tool retrieves structured facts from:

- `accounts`
- `sales_users`

The account record is the primary entity.

Sales-user data is retrieved only to provide the current account-owner context.

---

#### Retrieved Account Fields

The tool retrieves:

- `account_id`
- `account_name`
- `segment`
- `account_tier`
- `account_status`
- `customer_since`
- `sales_territory`

Owner context includes:

- `sales_user_id`
- `name`
- `role`
- `territory`
- `status`

Account territory and owner territory remain separate fields because they represent different business facts.

---

#### Output Contract

When the account exists:

```json
{
  "account_id": "<requested account_id>",
  "found": true,
  "account": {
    "account_id": "<canonical account_id>",
    "account_name": "<account name>",
    "segment": "<segment>",
    "account_tier": "<account tier>",
    "account_status": "<account status>",
    "customer_since": "<date>",
    "sales_territory": "<account sales territory>",
    "owner": {
      "sales_user_id": "<canonical sales_user_id>",
      "name": "<owner name>",
      "role": "<owner role>",
      "territory": "<owner territory>",
      "status": "<owner status>"
    }
  }
}
```

When no account exists for the supplied canonical identifier:

```json
{
  "account_id": "<requested account_id>",
  "found": false,
  "account": null
}
```

A valid identifier with no matching record represents an unknown or unavailable business entity, not tool failure.

---

#### Owner Availability

`owner` is nullable by contract.

If the account exists but no resolvable owner record is available, the account remains a valid result:

```json
{
  "account_id": "<requested account_id>",
  "found": true,
  "account": {
    "account_id": "<canonical account_id>",
    "account_name": "<account name>",
    "segment": "<segment>",
    "account_tier": "<account tier>",
    "account_status": "<account status>",
    "customer_since": "<date>",
    "sales_territory": "<account sales territory>",
    "owner": null
  }
}
```

The absence of owner context must not cause the account itself to disappear from the result.

---

#### Retrieval Behavior

Account data is retrieved using the canonical `account_id`.

Owner context is joined to the account without requiring an owner record to exist.

The retrieval must therefore preserve the account even when owner context is unavailable.

The tool performs direct structured-data retrieval only. It does not derive additional customer metrics or business conclusions.

---

#### No-Result and Error Semantics

The following states are distinct:

| Condition                             | Tool Behavior                   |
| ------------------------------------- | ------------------------------- |
| Valid `account_id`, account exists    | `found: true`                   |
| Valid `account_id`, no account exists | `found: false`, `account: null` |
| Missing or unusable `account_id`      | Input error                     |
| Database/tool execution failure       | Tool failure                    |

A no-result state must not be converted into a fabricated account.

---

#### Boundaries

`get_account_context()` does not:

- resolve ambiguous natural-language account references,
- retrieve opportunities,
- retrieve orders or purchase history,
- retrieve agreements,
- retrieve commercial entitlements,
- retrieve inventory,
- retrieve commercial policy,
- calculate customer value or other derived metrics,
- determine commercial eligibility,
- modify account or sales-user data.

These responsibilities remain separated across the appropriate bounded tools and knowledge sources.

---

### 7.2 `get_opportunity(opportunity_id)`

**Status:** Validated

#### Purpose

Retrieve the current structured business context of a canonical sales opportunity together with its proposed solution lines.

The tool answers:

> What is the current deal state, customer requirement context, commercial request state, and proposed solution composition of this opportunity?

The tool retrieves structured opportunity facts only. It does not evaluate technical compatibility, commercial eligibility, inventory feasibility, or approval requirements.

---

#### Input Contract

```json
{
  "opportunity_id": "<canonical opportunity_id>"
}
```

Requirements:

- `opportunity_id` is required.
- `opportunity_id` must be a non-empty string.
- The input is expected to be a canonical opportunity identifier established by authoritative context.

Missing or unusable input is treated as an input error, not as an unresolved opportunity.

---

#### Authoritative Sources

The tool retrieves structured facts from:

- `opportunities`
- `opportunity_solution_lines`
- `products`

The opportunity record is the primary entity.

Product Master data is joined only to provide lightweight identity and commercial context for proposed solution lines.

---

#### Retrieved Opportunity Fields

The tool retrieves:

- `opportunity_id`
- `account_id`
- `owner_id`
- `opportunity_name`
- `stage`
- `estimated_value_idr`
- `expected_close_date`
- `target_deployment_date`
- `customer_requirements`
- `current_discount_pct`
- `requested_discount_pct`
- `outstanding_questions`

Each proposed solution line includes:

- `solution_line_id`
- `product_id`
- `sku`
- `product_name`
- `product_role`
- `commercial_status`
- `quantity`
- `estimated_unit_price_idr`

The storage fields `customer_requirements_json` and `outstanding_questions_json` are exposed through the business-facing output fields `customer_requirements` and `outstanding_questions`.

Their underlying values are preserved without interpretation.

---

#### Output Contract

When the opportunity exists:

```json
{
  "opportunity_id": "<requested opportunity_id>",
  "found": true,
  "opportunity": {
    "opportunity_id": "<canonical opportunity_id>",
    "account_id": "<canonical account_id>",
    "owner_id": "<canonical sales_user_id>",
    "opportunity_name": "<opportunity name>",
    "stage": "<stage>",
    "estimated_value_idr": 0,
    "expected_close_date": "<date>",
    "target_deployment_date": "<date>",
    "customer_requirements": {},
    "current_discount_pct": 0,
    "requested_discount_pct": 0,
    "outstanding_questions": [],
    "solution_lines": [
      {
        "solution_line_id": "<canonical solution_line_id>",
        "product_id": "<canonical product_id>",
        "sku": "<sku>",
        "product_name": "<product name>",
        "product_role": "<product role>",
        "commercial_status": "<commercial status>",
        "quantity": 0,
        "estimated_unit_price_idr": null
      }
    ]
  }
}
```

When no opportunity exists for the supplied canonical identifier:

```json
{
  "opportunity_id": "<requested opportunity_id>",
  "found": false,
  "opportunity": null
}
```

A valid identifier with no matching record represents an unknown or unavailable business entity, not tool failure.

---

#### Solution-Line Availability

`solution_lines` may be an empty array.

An opportunity may exist before a proposed solution has been defined:

```json
{
  "opportunity_id": "<requested opportunity_id>",
  "found": true,
  "opportunity": {
    "...": "...",
    "solution_lines": []
  }
}
```

The absence of solution lines must not cause the opportunity itself to be treated as unresolved.

The current seed dataset contains no opportunity without solution lines. Empty-array behavior is therefore defined by contract and supported by the retrieval design, but has not been observed as a positive runtime fixture in the current seed.

---

#### Price Semantics

`estimated_value_idr` represents the CRM opportunity-level forecast.

`estimated_unit_price_idr` represents the current estimated commercial value of an individual proposed solution line when that information is available.

These values have different business meanings.

The tool must not:

- recalculate `estimated_value_idr` from solution lines,
- require the sum of solution lines to equal `estimated_value_idr`,
- replace a missing `estimated_unit_price_idr` with Product Master list price,
- infer a missing line price from another commercial value.

A missing `estimated_unit_price_idr` remains `null`.

---

#### Product Context Boundary

Solution lines include lightweight Product Master context:

- product identity,
- product role,
- commercial status.

This allows the opportunity composition to be understood without requiring additional product-detail retrieval merely to identify each proposed line.

The join does not turn `get_opportunity()` into a full product-detail tool.

Technical specifications, lifecycle analysis, compatibility rules, product recommendations, and other detailed product information remain outside this tool.

---

#### No-Result and Error Semantics

| Condition                                     | Tool Behavior                       |
| --------------------------------------------- | ----------------------------------- |
| Valid `opportunity_id`, opportunity exists    | `found: true`                       |
| Valid `opportunity_id`, no opportunity exists | `found: false`, `opportunity: null` |
| Missing or unusable `opportunity_id`          | Input error                         |
| Database/tool execution failure               | Tool failure                        |

A no-result state must not be converted into a fabricated opportunity.

---

#### Boundaries

`get_opportunity()` does not:

- retrieve full account context,
- retrieve sales-user details,
- retrieve purchase history,
- retrieve inventory,
- retrieve agreements or commercial entitlements,
- retrieve commercial or technical policy documents,
- evaluate product compatibility,
- determine commercial eligibility,
- calculate an eligible commercial subtotal,
- determine discount authority or approval requirements,
- determine delivery feasibility,
- recommend products,
- replace missing commercial values,
- modify opportunity or product data.

Those responsibilities remain separated across the appropriate bounded tools, knowledge retrieval capabilities, deterministic guardrails, and reasoning layer.

---

### 7.3 `get_product_details(product_id)`

**Status:** Validated

#### Purpose

Retrieve the current structured Product Master facts for a canonical product.

The tool answers:

> What is this product according to the Product Master?

It provides product identity, classification, lifecycle, and commercial-status facts without interpreting what those facts mean for a specific deal.

---

#### Input Contract

```json
{
  "product_id": "<canonical product_id>"
}
```

Requirements:

- `product_id` is required.
- `product_id` must be a non-empty string.
- The input is expected to be a canonical product identifier established by authoritative context or prior product resolution.

Natural-language product references should first be resolved through `resolve_product(query)`.

Missing or unusable input is treated as an input error, not as an unresolved product.

---

#### Authoritative Source

The tool retrieves structured facts from:

- `products`

No other business-data table or knowledge source is required.

---

#### Output Contract

When the product exists:

```json
{
  "product_id": "<requested product_id>",
  "found": true,
  "product": {
    "product_id": "<canonical product_id>",
    "sku": "<sku>",
    "product_name": "<product name>",
    "brand": "<brand>",
    "category": "<category>",
    "product_family": "<product family>",
    "product_role": "<product role>",
    "lifecycle_status": "<lifecycle status>",
    "commercial_status": "<commercial status>",
    "list_price_idr": 0,
    "launch_date": "<date>",
    "discontinued_date": null
  }
}
```

When no product exists for the supplied canonical identifier:

```json
{
  "product_id": "<requested product_id>",
  "found": false,
  "product": null
}
```

A valid identifier with no matching product represents an unknown or unavailable business entity, not tool failure.

---

#### Lifecycle and Commercial Semantics

`lifecycle_status` and `commercial_status` are returned as Product Master facts.

The tool does not interpret these statuses as recommendations or commercial decisions.

For example:

- `PHASE_OUT` does not automatically mean the product must not be proposed.
- `DISCONTINUED` does not by itself determine compatibility or replacement strategy.
- `PROMOTIONAL` does not by itself determine discount eligibility.
- `PRICE_PROTECTED` does not by itself determine applicable commercial treatment.

Those conclusions require the appropriate knowledge evidence and reasoning.

`discontinued_date` may be `null` when the product has not reached the `DISCONTINUED` lifecycle state.

---

#### No-Result and Error Semantics

| Condition                             | Tool Behavior                   |
| ------------------------------------- | ------------------------------- |
| Valid `product_id`, product exists    | `found: true`                   |
| Valid `product_id`, no product exists | `found: false`, `product: null` |
| Missing or unusable `product_id`      | Input error                     |
| Database/tool execution failure       | Tool failure                    |

A no-result state must not be converted into a fabricated product.

---

#### Boundaries

`get_product_details()` does not:

- resolve natural-language product references,
- retrieve technical specifications from the knowledge corpus,
- evaluate product compatibility,
- retrieve inventory,
- retrieve customer purchase history,
- retrieve customer-specific commercial terms,
- retrieve discount policies,
- determine commercial eligibility,
- recommend products,
- determine replacement products,
- modify Product Master data.

These responsibilities remain separated across resolver tools, other bounded business-data tools, knowledge retrieval, and the reasoning layer.

---

### 7.4 `get_purchase_history(account_id, product_id?)`

**Status:** Validated

#### Purpose

Retrieve completed purchase history for a canonical account, optionally filtered to a canonical product.

The tool answers:

> What has this customer actually purchased?

Purchase history represents completed historical transactions. It must not be interpreted as a current quotation, current product preference, or current commercial entitlement.

---

#### Input Contract

```json
{
  "account_id": "<canonical account_id>",
  "product_id": null
}
```

Requirements:

- `account_id` is required and must be a non-empty canonical account identifier.
- `product_id` is optional.
- When provided, `product_id` must be a canonical product identifier.
- Natural-language entity references must be resolved before calling this tool.

Missing or unusable `account_id` is treated as an input error.

---

#### Authoritative Sources

The tool retrieves structured facts from:

- `accounts`
- `orders`
- `order_lines`
- `products`

The account record is used to distinguish an existing account with no matching purchase history from an account that does not exist.

Orders and order lines provide historical transaction evidence.

Product Master provides lightweight product identity for each transaction line.

`order_line_id` preserves the canonical identity of each transaction line, including cases where the same product appears more than once within a single order.

---

#### Purchase Evidence Rule

Only completed or otherwise explicitly fulfilled orders may be treated as evidence that a customer purchased a product.

For the current synthetic dataset, valid purchase evidence is represented by:

```text
order_status = COMPLETED
```

A pending, cancelled, or otherwise non-fulfilled order must not be presented as completed purchase history.

---

#### Output Contract

When the account exists and matching completed purchases are available:

```json
{
  "account_id": "<canonical account_id>",
  "product_id": null,
  "found": true,
  "orders": [
    {
      "order_id": "<order_id>",
      "order_date": "<date>",
      "order_status": "COMPLETED",
      "lines": [
        {
          "order_line_id": "<canonical order_line_id>",
          "product_id": "<canonical product_id>",
          "sku": "<sku>",
          "product_name": "<product name>",
          "quantity": 0,
          "unit_price_idr": 0,
          "installation_location": "<location>"
        }
      ]
    }
  ]
}
```

When the account exists but no matching completed purchase is available:

```json
{
  "account_id": "<canonical account_id>",
  "product_id": "<optional product filter>",
  "found": true,
  "orders": []
}
```

When the account does not exist:

```json
{
  "account_id": "<requested account_id>",
  "product_id": "<optional product filter>",
  "found": false,
  "orders": []
}
```

---

#### Optional Product Filter

When `product_id` is omitted or `null`, the tool returns completed purchase history across products for the account.

When `product_id` is provided, only completed purchase lines matching that canonical product are returned.

An existing account with no matching purchase for the supplied product remains:

```text
found: true
```

with:

```json
"orders": []
```

The absence of matching purchase history must not be interpreted as an unresolved account.

---

#### Historical Price Semantics

`unit_price_idr` represents the actual historical transaction price recorded on the completed order line.

Historical transaction price must not be treated as:

- current list price,
- current quoted price,
- current customer entitlement,
- guaranteed future price.

The tool reports the historical fact only.

---

#### No-Result and Error Semantics

| Condition                                             | Tool Behavior                     |
| ----------------------------------------------------- | --------------------------------- |
| Existing account with matching completed purchases    | `found: true`, populated `orders` |
| Existing account with no matching completed purchases | `found: true`, `orders: []`       |
| Nonexistent account                                   | `found: false`, `orders: []`      |
| Missing or unusable `account_id`                      | Input error                       |
| Database/tool execution failure                       | Tool failure                      |

Account existence must therefore be established independently from the presence of purchase-history rows.

---

#### Boundaries

`get_purchase_history()` does not:

- resolve natural-language account or product references,
- retrieve open opportunities,
- retrieve current inventory,
- retrieve agreements or commercial entitlements,
- retrieve current pricing policy,
- calculate customer lifetime value,
- calculate total historical spend,
- infer customer product preference,
- infer current product suitability,
- treat historical price as a current offer,
- recommend products,
- modify order or account data.

These responsibilities remain separated across other bounded tools, knowledge retrieval, and the reasoning layer.

---

### 7.5 `get_inventory(product_id)`

**Status:** Validated

#### Purpose

Retrieve current inventory positions and incoming inventory records for a canonical product.

The tool answers:

> What inventory facts currently exist for this product?

The tool reports inventory evidence only. It does not determine whether inventory is sufficient for a specific opportunity or whether a delivery commitment can be made.

---

#### Input Contract

```json
{
  "product_id": "<canonical product_id>"
}
```

Requirements:

- `product_id` is required.
- `product_id` must be a non-empty canonical product identifier.
- Natural-language product references must be resolved through `resolve_product()` before calling this tool.

Missing or unusable `product_id` is treated as an input error.

---

#### Authoritative Sources

The tool retrieves structured facts from:

- `products`
- `inventory_positions`
- `incoming_inventory`

Product Master is used to establish whether the requested canonical product exists.

`inventory_positions` provides current inventory facts per warehouse.

`incoming_inventory` provides separately recorded incoming inventory facts.

---

#### Output Contract

When the product exists:

```json
{
  "product_id": "<canonical product_id>",
  "found": true,
  "inventory_positions": [
    {
      "warehouse_id": "<warehouse_id>",
      "on_hand": 0,
      "reserved": 0,
      "available": 0,
      "last_updated": "<timestamp>"
    }
  ],
  "incoming_inventory": [
    {
      "incoming_id": "<incoming_id>",
      "warehouse_id": "<warehouse_id>",
      "quantity": 0,
      "expected_arrival": "<date>",
      "status": "<status>"
    }
  ]
}
```

When the product exists but has no current inventory positions or incoming inventory, the corresponding collections remain empty.

Example:

```json
{
  "product_id": "<canonical product_id>",
  "found": true,
  "inventory_positions": [],
  "incoming_inventory": []
}
```

When the product does not exist:

```json
{
  "product_id": "<requested product_id>",
  "found": false,
  "inventory_positions": [],
  "incoming_inventory": []
}
```

---

#### Current Inventory Semantics

Inventory positions are returned per warehouse.

Each position preserves the authoritative values:

- `on_hand`
- `reserved`
- `available`
- `last_updated`

Warehouse positions with zero inventory remain valid inventory evidence and must not be removed from the result.

The tool does not aggregate warehouse positions into a national inventory total.

---

#### Incoming Inventory Semantics

Incoming inventory is returned separately from current inventory.

Each incoming record preserves:

- `incoming_id`
- `warehouse_id`
- `quantity`
- `expected_arrival`
- `status`

Incoming inventory must not be added to current `available` inventory.

The current synthetic dataset contains incoming statuses including:

```text
CONFIRMED
DELAYED
IN_TRANSIT
```

These statuses are returned as source facts. The tool does not interpret them as delivery commitments or guaranteed availability.

---

#### No-Result and Error Semantics

| Condition                                            | Tool Behavior                                  |
| ---------------------------------------------------- | ---------------------------------------------- |
| Existing product with inventory evidence             | `found: true`, populated inventory collections |
| Existing product without current inventory positions | `found: true`, `inventory_positions: []`       |
| Existing product without incoming inventory          | `found: true`, `incoming_inventory: []`        |
| Nonexistent product                                  | `found: false`, both collections empty         |
| Missing or unusable `product_id`                     | Input error                                    |
| Database/tool execution failure                      | Tool failure                                   |

Product existence must be established independently from the presence of inventory records.

---

#### Boundaries

`get_inventory()` does not:

- resolve natural-language product references,
- aggregate inventory into national available stock,
- add incoming quantity to current available inventory,
- determine whether inventory is sufficient for an opportunity,
- allocate inventory to a customer or opportunity,
- select a fulfillment warehouse,
- determine delivery feasibility,
- guarantee an incoming arrival date,
- interpret an incoming status as guaranteed availability,
- recommend substitute products,
- modify inventory data.

Inventory sufficiency and delivery feasibility remain responsibilities of the reasoning layer using the relevant opportunity requirements and other evidence.

---

### 7.6 `get_commercial_context(account_id)`

**Status:** Validated

#### Purpose

Retrieve customer-specific structured commercial facts for a canonical account.

The tool answers:

> What customer-specific commercial agreements and entitlements exist for this account?

The tool returns both current and historical commercial records together with their recorded status and effective dates.

It reports commercial facts only. It does not determine whether an agreement or entitlement is currently applicable to a specific deal.

---

#### Input Contract

```json
{
  "account_id": "<canonical account_id>"
}
```

Requirements:

- `account_id` is required.
- `account_id` must be a non-empty canonical account identifier.
- Natural-language customer references must be resolved through `resolve_account()` before calling this tool.

Missing or unusable `account_id` is treated as an input error.

---

#### Authoritative Sources

The tool retrieves structured facts from:

- `accounts`
- `agreements`
- `commercial_entitlements`

The account record establishes whether the requested canonical account exists.

Agreements provide customer-specific commercial agreement records.

Commercial entitlements provide structured entitlement records associated with those agreements.

Global commercial policies, discount rules, approval matrices, stacking rules, and other policy interpretation remain authoritative knowledge retrieved separately from the knowledge corpus.

---

#### Output Contract

When the account exists and commercial records are available:

```json
{
  "account_id": "<canonical account_id>",
  "found": true,
  "agreements": [
    {
      "agreement_id": "<agreement_id>",
      "agreement_name": "<agreement name>",
      "agreement_type": "<agreement type>",
      "effective_from": "<date>",
      "effective_to": "<date>",
      "status": "<status>",
      "entitlements": [
        {
          "entitlement_id": "<entitlement_id>",
          "entitlement_type": "<entitlement type>",
          "effective_from": "<date>",
          "effective_to": "<date>",
          "status": "<status>"
        }
      ]
    }
  ]
}
```

When the account exists but has no commercial agreement records:

```json
{
  "account_id": "<canonical account_id>",
  "found": true,
  "agreements": []
}
```

When the account does not exist:

```json
{
  "account_id": "<requested account_id>",
  "found": false,
  "agreements": []
}
```

---

#### Agreement History Semantics

The tool returns both active and historical agreement records.

Expired agreements are not removed from the result.

This preserves evidence that an agreement existed while allowing downstream reasoning to evaluate its status and effective dates.

For example, an expired agreement remains a historical commercial fact but must not automatically be treated as a currently applicable entitlement.

The tool itself does not make that applicability decision.

---

#### Entitlement Relationship

Entitlements are returned within their associated agreement:

```text
Agreement
└── Entitlements[]
```

The output uses an array even when the current dataset contains one entitlement per agreement.

The database model does not require the tool contract to assume a permanent one-to-one relationship.

No separate `unlinked_entitlements` collection is included in v1. Runtime validation found no entitlement records without a corresponding agreement.

---

#### Commercial Interpretation Boundary

The following fields are structured commercial facts:

- agreement identity,
- agreement type,
- agreement effective dates,
- agreement status,
- entitlement identity,
- entitlement type,
- entitlement effective dates,
- entitlement status.

The tool does not transform these facts into commercial decisions.

In particular, it does not produce fields such as:

```text
allowed_discount_pct
approval_required
agreement_applicable
can_stack
eligible_for_volume_discount
```

Those are reasoning outcomes that may require opportunity facts, commercial policy documents, approval rules, product status, deal composition, and other evidence.

---

#### No-Result and Error Semantics

| Condition                                | Tool Behavior                         |
| ---------------------------------------- | ------------------------------------- |
| Existing account with commercial records | `found: true`, populated `agreements` |
| Existing account without agreements      | `found: true`, `agreements: []`       |
| Nonexistent account                      | `found: false`, `agreements: []`      |
| Missing or unusable `account_id`         | Input error                           |
| Database/tool execution failure          | Tool failure                          |

Account existence must be established independently from the presence of agreement records.

---

#### Boundaries

`get_commercial_context()` does not:

- resolve natural-language customer references,
- retrieve opportunity details,
- retrieve product commercial status,
- retrieve commercial policy documents,
- calculate an allowed discount,
- determine volume-discount eligibility,
- determine whether benefits can stack,
- determine approval authority,
- determine whether approval is required,
- determine whether an agreement is applicable to a specific deal,
- treat historical agreements as current entitlements,
- recommend commercial terms,
- modify agreements or entitlements.

Commercial decisions remain responsibilities of the reasoning layer using structured business facts together with authoritative commercial knowledge.

---

## 8. Implementation Boundary

The Business Data Tool layer sits between the Copilot's evidence-planning process and PostgreSQL.

Conceptually:

```text
Copilot / Evidence Planner
          |
          v
Approved Business Data Tool
          |
          v
Input Validation
          |
          v
Parameterized PostgreSQL Query
          |
          v
Structured Tool Result
          |
          v
Evidence Validation / Reasoning
```

The AI selects from approved tools.

The tool controls database access.

PostgreSQL remains the source of truth for structured business state.

The tool result becomes evidence for downstream reasoning; it is not itself the final business decision.

---

## 9. Explicitly Excluded Tools

The following tool patterns are intentionally excluded from v1:

- `run_sql()`
- `search_database()`
- `get_everything_about_customer()`
- `calculate_allowed_discount()`
- `recommend_product()`
- `check_compatibility()`
- `decide_delivery_feasibility()`

The first group provides excessively broad data access.

The second group incorrectly moves reasoning or decision responsibility into the data-retrieval layer.

---

## 10. Current Validation Status

### Validated

- `resolve_account(query)`
- `resolve_product(query)`
- `get_account_context(account_id)`
- `get_opportunity(opportunity_id)`
- `get_product_details(product_id)`
- `get_purchase_history(account_id, product_id?)`
- `get_inventory(product_id)`
- `get_commercial_context(account_id)`

All eight bounded Business Data Tools defined for v1 have completed contract design and PostgreSQL runtime validation.

No unrestricted database-access tool is included in v1.

---
