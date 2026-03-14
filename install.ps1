param(
  [string]$WorkspaceDir = "",
  [string]$OpenClawDir = "",
  [int]$DashboardPort = 7000,
  [switch]$NonInteractive
)

$ErrorActionPreference = "Stop"

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

Write-Host ""
Write-Host "OpenClaw Dashboard Windows Installer"
Write-Host "===================================="
Write-Host ""

$nodeBin = Find-NodeBinary
if (-not $nodeBin) {
  Write-Host "Node.js 18+ not found."
  Write-Host "Please install Node.js LTS, or add node.exe to PATH."
  Write-Host "Common path: C:\Program Files\nodejs\node.exe"
  exit 1
}

$nodeVersion = (& $nodeBin --version).TrimStart("v").Split(".")[0]
if ([int]$nodeVersion -lt 18) {
  Write-Host "Node.js version is too old. Need v18+, current v$nodeVersion."
  exit 1
}

Write-Host "Node.js $(& $nodeBin --version) detected"

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
