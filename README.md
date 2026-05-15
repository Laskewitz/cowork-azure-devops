# Cowork Azure DevOps

A Microsoft 365 Copilot **Cowork** plugin that connects to Azure DevOps via the
remote MCP server, scoped to the `devrel` organization and `devrel` project.

## Contents

```
cowork-azure-devops/
├── manifest.json                          # M365 unified app manifest (devPreview)
├── color.png                              # 192×192 app icon (placeholder)
├── outline.png                            # 32×32 outline icon (placeholder)
└── skills/
    └── azure-devops-assistant/
        └── SKILL.md                       # The single skill
```

## What's in the package

- **1 skill** — `azure-devops-assistant`: guides Cowork through Azure DevOps
  scenarios (work items, pull requests, pipelines, boards) and always passes
  `organization = devrel` and `project = devrel` to the connector by default.
- **1 MCP server (connector)** — `ado-remote-mcp`: the Azure DevOps remote MCP
  server at `https://mcp.dev.azure.com/devrel`, authenticated via
  `OAuthPluginVault`.

## Packaging

From the repo root:

```powershell
Compress-Archive -Path manifest.json, color.png, outline.png, skills `
  -DestinationPath cowork-azure-devops.zip -Force
```

Then sideload `cowork-azure-devops.zip` via **M365 Admin Center → Manage Apps →
Upload custom app**, or submit through Partner Center.

## Notes

- `color.png` and `outline.png` in this repo are placeholders — replace them with
  real branded icons before publishing to the store.
- To target a different Azure DevOps organization or project, update
  `mcpServerUrl` in `manifest.json` and the **Defaults** table in
  `skills/azure-devops-assistant/SKILL.md`.
