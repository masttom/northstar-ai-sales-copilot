# Northstar Workflow Exports — Sanitized for Portfolio

These JSON exports are public-facing snapshots, **not directly runnable without relinking**.

After importing into n8n:
- Re-select OpenAI, Pinecone, and Gmail credentials.
- WF-01: reselect BT-01 through BT-09 subworkflows in each Tool Workflow node (workflow IDs were replaced with `RELINK_BT_XX_WORKFLOW_ID`).
- WF-01 and WF-02: set Settings > Error Workflow to the imported WF-03 (`RELINK_WF_03_ERROR_WORKFLOW` is a placeholder).
- WF-03: set Gmail `sendTo` to your monitoring address.
- WF-01 chat trigger: regenerate/publish webhook as needed.
- WF-02: `/files/northstar-knowledge/source/**/*.pdf` is an internal container path and must exist on the target deployment.
- WF-01/02: Pinecone index `northstar-knowledge-v1` and namespace `northstar-kb-staging` are retained for architecture documentation and must exist in target account.
- Verify published/active state and credentials after import.

Sanitization removes top-level workflow id/versionId/meta, credential IDs/names, webhook IDs, email recipient, subworkflow target IDs, and error-workflow target IDs. Node IDs, graph connections, prompt, code, query parameters, index/namespace, and settings (except error-workflow ID) are preserved.

Note: WF-02 has a Manual Trigger; n8n error-workflow behavior differs for manual executions.
