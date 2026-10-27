# Northstar Workflow Exports — Sanitized for Portfolio

These JSON exports are public-facing snapshots, **not directly runnable without relinking and configuration**.

## After Importing into n8n

1. Re-select the required OpenAI, Pinecone, Gmail, and PostgreSQL credentials in the applicable workflows.
2. **WF-01:** Re-select the imported BT-01 through BT-09 subworkflows in each Tool Workflow node. The sanitized WF-01 export uses placeholders such as `REPLACE_WITH_BT-01_ID`.
3. **WF-01 and WF-02:** Configure **Settings → Error Workflow** to reference the imported WF-03.
4. **WF-03:** Set the Gmail `sendTo` field to your monitoring email address.
5. **WF-01:** Verify the Chat Trigger configuration and activate or publish the workflow as required.
6. **WF-02:** Ensure the knowledge PDF files are available at `/files/northstar-knowledge/source/` inside the target n8n container.
7. **WF-01 and WF-02:** Configure the Pinecone index and namespace. The export retains `northstar-knowledge-v1` and `northstar-kb-staging` as implementation references; these must exist or be updated to match the target environment.
8. Verify credentials, workflow references, and activation status before running the imported workflows.

## Sanitization Notes

The public exports remove or replace sensitive and instance-specific references, including:

- Top-level workflow identifiers and instance metadata.
- Credential IDs and account names.
- Webhook identifiers.
- Monitoring email recipients.
- Subworkflow target IDs.
- Error Workflow target IDs.

The functional workflow structure, node connections, prompts, tool descriptions, code, SQL parameters, and relevant architectural settings are retained.

**Note:** WF-02 includes a Manual Trigger. Error Workflow behavior for manually initiated executions may differ from automatic executions.

These exports are intended for architecture review, portfolio demonstration, and manual reconstruction in a separate n8n environment.
