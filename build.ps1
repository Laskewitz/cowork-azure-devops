<#
.SYNOPSIS
  Build a Cowork plugin package by substituting {{ORGANIZATION}} and {{PROJECT}}
  placeholders in the template files, then zipping the result.

.EXAMPLE
  .\build.ps1
  .\build.ps1 -Organization contoso -Project payments
  .\build.ps1 -Organization devrel -Project devrel -OutputDir .\dist
#>
[CmdletBinding()]
param(
    [string]$Organization = "devrel",
    [string]$Project      = "devrel",
    [string]$OutputDir    = (Join-Path $PSScriptRoot "build")
)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

function Expand-Template {
    param([string]$Path)
    (Get-Content -Raw -LiteralPath $Path) `
        -replace '\{\{ORGANIZATION\}\}', $Organization `
        -replace '\{\{PROJECT\}\}',      $Project
}

Write-Host "Building package for organization='$Organization' project='$Project'..."

# Clean and recreate output directory
if (Test-Path $OutputDir) { Remove-Item -Recurse -Force $OutputDir }
$pkgDir = Join-Path $OutputDir "package"
New-Item -ItemType Directory -Path $pkgDir -Force | Out-Null

# manifest.json
Expand-Template (Join-Path $root "manifest.template.json") |
    Set-Content -LiteralPath (Join-Path $pkgDir "manifest.json") -Encoding utf8

# Icons (copied as-is)
Copy-Item (Join-Path $root "color.png")   $pkgDir
Copy-Item (Join-Path $root "outline.png") $pkgDir

# Skills: expand every *.template.md to its sibling without .template, and copy
# any other companion files verbatim.
$skillsSrc = Join-Path $root  "skills"
$skillsDst = Join-Path $pkgDir "skills"
Get-ChildItem -Recurse -File $skillsSrc | ForEach-Object {
    $rel    = $_.FullName.Substring($skillsSrc.Length).TrimStart('\','/')
    $relOut = $rel -replace '\.template\.md$', '.md'
    $dst    = Join-Path $skillsDst $relOut
    New-Item -ItemType Directory -Path (Split-Path $dst) -Force | Out-Null
    if ($_.Name -like '*.template.md') {
        Expand-Template $_.FullName | Set-Content -LiteralPath $dst -Encoding utf8
    } else {
        Copy-Item $_.FullName $dst
    }
}

# Zip
$zipName = "azure-devops-for-copilot-cowork-$Organization-$Project.zip"
$zipPath = Join-Path $OutputDir $zipName
Compress-Archive -Path (Join-Path $pkgDir "*") -DestinationPath $zipPath -Force

Write-Host "Done: $zipPath"
