param(
  [int]$DashboardPort = 0,
  [string]$WorkspaceDir = "",
  [string]$OpenClawDir = "",
  [string]$OpenClawAgent = ""
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$envFile = Join-Path $scriptDir ".env.windows"

if (Test-Path $envFile) {
  Get-Content $envFile | ForEach-Object {
    if ($_ -match "^\s*([^=]+)=(.*)\s*$") {
      [Environment]::SetEnvironmentVariable($matches[1], $matches[2], "Process")
    }
  }
}

if ($DashboardPort -gt 0) { $env:DASHBOARD_PORT = "$DashboardPort" }
if ($WorkspaceDir) { $env:WORKSPACE_DIR = $WorkspaceDir }
if ($OpenClawDir) { $env:OPENCLAW_DIR = $OpenClawDir }
if ($OpenClawAgent) { $env:OPENCLAW_AGENT = $OpenClawAgent }

if (-not $env:DASHBOARD_PORT) { $env:DASHBOARD_PORT = "7000" }
if (-not $env:WORKSPACE_DIR) {
  $preferredWorkspace = Join-Path $HOME ".openclaw\workspace"
  if (Test-Path $preferredWorkspace) {
    $env:WORKSPACE_DIR = $preferredWorkspace
  } else {
    $env:WORKSPACE_DIR = Join-Path $HOME "clawd"
  }
}
if (-not $env:OPENCLAW_DIR) { $env:OPENCLAW_DIR = Join-Path $HOME ".openclaw" }
if (-not $env:OPENCLAW_AGENT) { $env:OPENCLAW_AGENT = "all" }

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  Write-Host "Node.js not found in PATH. Please install Node.js 18+ and retry."
  exit 1
}

Set-Location $scriptDir
node server.js
