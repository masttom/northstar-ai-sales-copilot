# Northstar AI Sales Copilot

**Evidence-grounded sales decision support for a fictional nationwide Indonesian B2B equipment distributor.**

Northstar AI Sales Copilot is a working **portfolio MVP** built with **n8n, OpenAI GPT-4o, PostgreSQL, and Pinecone**. It helps sales representatives evaluate product fit, technical requirements, commercial terms, and stock availability by combining structured business records with internal knowledge documents.

> **AI recommends. Human decides.**

The Copilot recommends next steps; it does **not** approve discounts, grant commercial exceptions, reserve inventory, place orders, or promise delivery dates.

## Project status

**Working Portfolio Prototype — MVP v1** (October 2026)

The primary workflows and nine modular business tools have been implemented and exercised in targeted functional scenarios. This project is **not production-ready**. See the [regression test report](docs/testing/regression-test-report.md) for observed results and limitations.

## What it does

- **Product discovery and technical guidance:** retrieves product documents and proposes relevant equipment while identifying missing compatibility or site-readiness evidence.
- **Commercial decision support:** examines opportunities, agreements, discount policies, and approval authority; compares negotiation options without treating recommendations as approvals.
- **Financial simulation:** delegates opportunity-level discount arithmetic to a PostgreSQL-backed calculation tool rather than relying on the language model's mental arithmetic.
- **Inventory assessment:** resolves product identities and checks warehouse-level on-hand, reserved, available, and incoming quantities; distinguishes stock snapshots from confirmed fulfillment.
- **Evidence-aware responses:** distinguishes verified facts, recommendations, conditional options, and unresolved questions.

## Architecture

```text
Sales Representative
       |
       v
n8n Hosted Chat
       |
       v
WF-01: AI Sales Copilot (GPT-4o AI Agent)
       |
       +-- BT-01 ... BT-09: modular business tools --> PostgreSQL 17
       |
       +-- search_northstar_knowledge --> Pinecone
                                            ^
                                            |
                          WF-02: PDF knowledge ingestion

WF-03: Shared Error Handling --> Gmail notifications
```

**Retrieval strategy:** structured records (accounts, products, opportunities, agreements, orders, inventory) are queried through explicit PostgreSQL tools; technical and commercial documents are retrieved through Pinecone. The AI selects tools and synthesizes recommendations, but business calculations and authoritative records remain external to the model.

### Business tools

| Tool  | Purpose                          |
| ----- | -------------------------------- |
| BT-01 | Resolve Account                  |
| BT-02 | Resolve Product                  |
| BT-03 | Get Account Context              |
| BT-04 | Get Opportunity                  |
| BT-05 | Get Product Details              |
| BT-06 | Get Purchase History             |
| BT-07 | Get Inventory                    |
| BT-08 | Get Commercial Context           |
| BT-09 | Calculate Opportunity Financials |

## Technology stack

| Layer                           | Technology                      |
| ------------------------------- | ------------------------------- |
| Workflow orchestration and chat | n8n (self-hosted), Hosted Chat  |
| Language model                  | OpenAI GPT-4o                   |
| Embeddings                      | OpenAI `text-embedding-3-small` |
| Structured business data        | PostgreSQL 17                   |
| Document retrieval              | Pinecone vector index           |
| Error notifications             | Gmail via n8n                   |
| Local database environment      | Docker Compose                  |

## Repository structure

```text
.
├── README.md
├── .env.example
├── .gitignore
├── docker-compose.yml
├── database/
│   └── schema.sql
├── data/
│   └── seed/                 # Synthetic CSV data, manifest, validation notes
├── docs/
│   ├── 01-business-requirements.md
│   ├── 02-high-level-design.md
│   ├── 03-data-knowledge-design.md
│   ├── 04-ai-retrieval-reasoning-design.md
│   ├── 05-business-data-tools-design.md
│   └── testing/
│       └── regression-test-report.md
├── knowledge/
│   └── source/               # Synthetic technical and commercial PDFs
└── workflows/
    ├── WF-01-northstar-ai-sales-copilot.json
    ├── WF-02-knowledge-ingestion.json
    ├── WF-03-shared-error-handling.json
    ├── business-tools/       # BT-01 through BT-09
    └── README-import-notes.md
```

## Local setup (manual configuration required)

The repository contains **sanitized n8n workflow exports**. They document the implementation but cannot be imported and run without re-linking credentials, subworkflows, and environment-specific resources.

### 1. Start PostgreSQL

Install Docker and Docker Compose, then create a local `.env` file from `.env.example` and set a strong local `POSTGRES_PASSWORD`. Do not commit `.env`.

```bash
cp .env.example .env
# Edit .env and replace the example password
docker compose up -d
```

The included `docker-compose.yml` starts **PostgreSQL only**; it does not deploy n8n, Pinecone, or the complete application stack.

### 2. Initialize the database

Apply [`database/schema.sql`](database/schema.sql) to the database specified in `.env`. Load the synthetic CSV files from [`data/seed/`](data/seed/) in an order that respects foreign-key dependencies. Review [`data/seed/VALIDATION.md`](data/seed/VALIDATION.md) and [`manifest.json`](data/seed/manifest.json) before importing.

**Note:** This repository does not yet include a single-command database seeding script. Database initialization and CSV import are manual steps.

### 3. Configure n8n and external services

1. Deploy or access a separate n8n instance with the required nodes and database connectivity.
2. Create credentials for OpenAI, PostgreSQL, Pinecone, and Gmail (for error notifications).
3. Import **BT-01 through BT-09**, followed by WF-01, WF-02, and WF-03.
4. Re-select each imported business subworkflow in WF-01 and reconfigure credentials and error-workflow references.
5. Provision the Pinecone index `northstar-knowledge-v1` and namespace `northstar-kb-staging` in your own account, or update the workflow configuration to your chosen names.
6. Make the repository's PDF corpus accessible to the n8n container at the path expected by WF-02 (`/files/northstar-knowledge/source/`), then run WF-02 to ingest the documents.
7. Confirm the model and embedding configuration, enable the required workflows, and test the Hosted Chat interface.

See [workflow import notes](workflows/README-import-notes.md) for additional relinking details. Paths and resource names in exported workflows reflect the development environment and may need adjustment.

## Evaluation

Three focused functional scenarios were evaluated:

| Test   | Scenario                                       | Observed result                      |
| ------ | ---------------------------------------------- | ------------------------------------ |
| FT-01B | Commercial negotiation and discount simulation | **PASS with observations**           |
| FT-02  | Product discovery and compatibility pre-check  | **CONDITIONAL PASS**                 |
| FT-03  | Inventory availability and order feasibility   | **PASS for availability assessment** |

Highlights include verifying discount calculations using BT-09 and correctly reporting **4 on-hand − 1 reserved = 3 available** units of BrewCore BC-920 in the inventory scenario. Compatibility for one proposed equipment pairing was **not conclusively verified**, and stock availability was **not** treated as a confirmed delivery commitment.

**Full evidence and caveats:** [Regression Test Report](docs/testing/regression-test-report.md).

## Known limitations

- Compatibility conclusions depend on retrieving complete authoritative document passages; a relevant matrix excerpt may omit the required row.
- Inventory records may be stale; availability does not establish allocation, transit time, or installation readiness.
- Discount policy eligibility, approval authority, and exception authorization are separate decisions; the AI does not grant approval.
- A complete multi-stage sales conversation has not been evaluated end-to-end as a single scenario.
- Production security, reliability, concurrency, observability, and operational performance have not been validated.
- Sanitized workflow exports require manual relinking and configuration before use.

## Data and project scope

Northstar is a **fictional distributor**, and its accounts, opportunities, commercial agreements, products, and supporting documents are **synthetic**. The checked-in dataset is a representative portfolio subset rather than a full production-scale enterprise dataset. Nothing in this repository represents real customer records or commercial entitlements.

## Design documentation

- [Business Requirements](docs/01-business-requirements.md)
- [High-Level Design](docs/02-high-level-design.md)
- [Data & Knowledge Design](docs/03-data-knowledge-design.md)
- [AI Retrieval & Reasoning Design](docs/04-ai-retrieval-reasoning-design.md)
- [Business Data Tools Design](docs/05-business-data-tools-design.md)
- [Regression Test Report](docs/testing/regression-test-report.md)

---

**Design principle:** **Read → Retrieve → Reason → Recommend**  
**Human oversight:** **AI recommends. Human decides.**
