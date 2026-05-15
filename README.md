# Azure DevOps for Copilot Cowork

A Microsoft 365 **Copilot Cowork** plugin that connects to Azure DevOps via the
remote MCP server, scoped to the `devrel` organization and `devrel` project.

## Contents

```
cowork-azure-devops/
├── manifest.template.json                 # M365 manifest template (devPreview)
├── color.png                              # 192×192 app icon (placeholder)
├── outline.png                            # 32×32 outline icon (placeholder)
├── build.ps1                              # Builds the .zip from templates
└── skills/
    └── azure-devops-assistant/
        └── SKILL.template.md              # The single skill (templated)
```

The source files use `{{ORGANIZATION}}` and `{{PROJECT}}` placeholders. The build
script substitutes them and produces a deployable `.zip`.

## What's in the package

- **1 skill** — `azure-devops-assistant`: guides Cowork through Azure DevOps
  scenarios (work items, pull requests, pipelines, boards) and always passes the
  configured `organization` and `project` to the connector by default.
- **1 MCP server (connector)** — `ado-remote-mcp`: the Azure DevOps remote MCP
  server at `https://mcp.dev.azure.com/<organization>`, authenticated via
  `OAuthPluginVault`.

## Are variables supported in M365 app packages?

**No.** The M365 unified app manifest used by Copilot Cowork doesn't support
runtime variables or inputs in `agentConnectors[].toolSource.remoteMcpServer.mcpServerUrl`
— the URL must be literal. The `"inputs": []` array you may have seen in dev-time
`mcp.json` files is a VS Code feature, not a manifest feature. The only piece
that's resolved dynamically at runtime is `authorization.referenceId`, via the
Microsoft Enterprise Token Store.

The workaround in this repo is **build-time substitution**: keep templates with
`{{ORGANIZATION}}` and `{{PROJECT}}` placeholders, and run `build.ps1` to
generate a per-tenant package.

## Building

From the repo root:

```powershell
# Defaults: Organization = devrel, Project = devrel
.\build.ps1

# Or for a different tenant
.\build.ps1 -Organization contoso -Project payments
```

The script writes the staged package contents to `./build/package/` and the
final zip to `./dist/azure-devops-for-copilot-cowork-<org>-<project>.zip`.

Then sideload the `.zip` via **M365 Admin Center → Manage Apps → Upload custom
app**, or submit through Partner Center.

## Updating the plugin

Skills can't be edited in place after a user imports the plugin — `SKILL.md`
content is part of the immutable app package. To change a skill (or any other
package content), re-publish a new version:

1. Edit `skills/<skill>/SKILL.template.md` (or other package files) in this repo.
2. Bump `"version"` in `manifest.template.json` (for example, `1.0.0` → `1.0.1`).
   Keep the `"id"` GUID stable across versions — that's what tells M365 this is
   an update rather than a new app.
3. Run `.\build.ps1` to produce a new `.zip`.
4. Re-upload via **M365 Admin Center → Manage Apps → Upload custom app** for
   sideloaded testing, or submit the new version through Partner Center for the
   store. Installed users pick up the new version automatically.

End users themselves can only enable/disable the plugin (and individual skills)
from the **Sources & Skills** panel, and complete connector sign-in. They can't
edit skill prompts or frontmatter.

> [!TIP]
> The MCP connector's tool surface is discovered at runtime via `tools/list`,
> so changes that live in the MCP server itself don't require re-packaging the
> plugin — only changes to `manifest.json`, `SKILL.md`, icons, or companion
> files do.

## Notes

- `color.png` and `outline.png` in this repo are placeholders — replace them with
  real branded icons before publishing to the store.
- The `id` GUID in `manifest.template.json` is shared across all builds. If you
  publish to different tenants/orgs as separate apps, generate a new GUID per
  build.
