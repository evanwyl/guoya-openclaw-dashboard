param(
  [int]$DashboardPort = 0,
  [string]$WorkspaceDir = "",
  [string]$OpenClawDir = "",
  [string]$OpenClawAgent = ""
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$envFile = Join-Path $scriptDir ".env.windows"

function Find-NodeBinary {
  $cmd = Get-Command node -ErrorAction SilentlyContinue
  if ($cmd -and $cmd.Source) {
    return $cmd.Source
  }

  $candidates = @(
    "C:\Program Files\nodejs\node.exe",
    "C:\Program Files (x86)\nodejs\node.exe",
    (Join-Path $env:LOCALAPPDATA "Programs\nodejs\node.exe"),
    (Join-Path $HOME "AppData\Local\Programs\nodejs\node.exe")
  ) | Where-Object { $_ -and (Test-Path $_) }

  if ($candidates.Count -gt 0) {
    return $candidates[0]
  }

  return $null
}

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

$nodeBin = Find-NodeBinary
if (-not $nodeBin) {
  Write-Host "Node.js 18+ not found."
  Write-Host "Please install Node.js LTS, or add node.exe to PATH."
  Write-Host "Common path: C:\Program Files\nodejs\node.exe"
  exit 1
}

Set-Location $scriptDir
& $nodeBin "server.js"
