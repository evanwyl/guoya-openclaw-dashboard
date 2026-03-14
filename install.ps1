param(
  [string]$WorkspaceDir = "",
  [string]$OpenClawDir = "",
  [int]$DashboardPort = 7000,
  [switch]$NonInteractive
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "OpenClaw Dashboard Windows Installer"
Write-Host "===================================="
Write-Host ""

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
  Write-Host "Node.js not found. Please install Node.js 18+ first."
  exit 1
}

$nodeVersion = (node --version).TrimStart("v").Split(".")[0]
if ([int]$nodeVersion -lt 18) {
  Write-Host "Node.js version is too old. Need v18+, current v$nodeVersion."
  exit 1
}

Write-Host "Node.js $(node --version) detected"

if (-not $WorkspaceDir) {
  if ($env:OPENCLAW_WORKSPACE) {
    $WorkspaceDir = $env:OPENCLAW_WORKSPACE
  } elseif (Test-Path (Join-Path $HOME ".openclaw\workspace")) {
    $WorkspaceDir = Join-Path $HOME ".openclaw\workspace"
  } else {
    $defaultWorkspace = Join-Path $HOME "clawd"
    if ($NonInteractive) {
      $WorkspaceDir = $defaultWorkspace
    } else {
      $inputValue = Read-Host "Enter your OpenClaw workspace path (default: $defaultWorkspace)"
      $WorkspaceDir = if ($inputValue) { $inputValue } else { $defaultWorkspace }
    }
  }
}

if (-not (Test-Path $WorkspaceDir)) {
  if ($NonInteractive) {
    New-Item -ItemType Directory -Force -Path $WorkspaceDir | Out-Null
  } else {
    $createNow = Read-Host "Workspace does not exist. Create it now? (y/n)"
    if ($createNow -match "^[Yy]") {
      New-Item -ItemType Directory -Force -Path $WorkspaceDir | Out-Null
    } else {
      Write-Host "Installation cancelled."
      exit 1
    }
  }
}

if (-not $OpenClawDir) {
  $OpenClawDir = Join-Path $HOME ".openclaw"
}

if (-not (Test-Path $OpenClawDir)) {
  Write-Host "Warning: OpenClaw directory not found: $OpenClawDir"
  if (-not $NonInteractive) {
    $continueAnyway = Read-Host "Continue anyway? (y/n)"
    if ($continueAnyway -notmatch "^[Yy]") {
      Write-Host "Installation cancelled."
      exit 1
    }
  }
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptsDir = Join-Path $WorkspaceDir "scripts"
New-Item -ItemType Directory -Force -Path $scriptsDir | Out-Null

foreach ($file in @("parse-claude-usage.py", "parse-gemini-usage.py")) {
  $source = Join-Path $scriptDir "scripts\$file"
  $dest = Join-Path $scriptsDir $file
  if ((Test-Path $source) -and -not (Test-Path $dest)) {
    Copy-Item $source $dest
  }
}

@(
  "DASHBOARD_PORT=$DashboardPort",
  "WORKSPACE_DIR=$WorkspaceDir",
  "OPENCLAW_DIR=$OpenClawDir",
  "OPENCLAW_AGENT=all"
) | Set-Content -Path (Join-Path $scriptDir ".env.windows")

Write-Host ""
Write-Host "Installation summary"
Write-Host "--------------------"
Write-Host "Workspace:    $WorkspaceDir"
Write-Host "OpenClaw Dir: $OpenClawDir"
Write-Host "Port:         $DashboardPort"
Write-Host "Env file:     $(Join-Path $scriptDir '.env.windows')"
Write-Host ""
Write-Host "Start with:"
Write-Host "  powershell -ExecutionPolicy Bypass -File .\run-dashboard.ps1"
Write-Host ""
Write-Host "Then open:"
Write-Host "  http://localhost:$DashboardPort"
Write-Host ""
Write-Host "Windows notes:"
Write-Host "  - Base dashboard works"
Write-Host "  - systemctl, tmux, journalctl and some Linux-only actions are not available on Windows"
