# Gap-Hunter Smoke Test (PowerShell)
#
# 5-minute dry-run that confirms terminal, paths, permissions, and Claude Code
# setup are working correctly BEFORE you launch a real overnight run.

$ErrorActionPreference = "Stop"

$ProjectDir = Get-Location
$PluginRoot = (Get-Item $PSScriptRoot).Parent.FullName
$Errors = 0
$Warnings = 0

Write-Host ""
Write-Host "Gap-Hunter Smoke Test"
Write-Host ""

# Check 1: init artefacts

Write-Host "[1/4] Checking that init artefacts are present..."

$RequiredFiles = @(
    "_shared-context.md",
    "brain.md",
    "ORCHESTRATOR-BRIEFING.md",
    ".gap-hunter\state.json"
)

foreach ($f in $RequiredFiles) {
    $path = Join-Path $ProjectDir $f
    if (Test-Path $path) {
        Write-Host "    OK: $f"
    } else {
        Write-Host "    MISSING: $f"
        $Errors++
    }
}

if (-not (Test-Path (Join-Path $ProjectDir "round-1"))) {
    Write-Host "    MISSING: round-1\ directory"
    $Errors++
} else {
    Write-Host "    OK: round-1\ exists"
}

# Check 2: shared-context customisation

Write-Host ""
Write-Host "[2/4] Checking that _shared-context.md has been customised..."

$ContextPath = Join-Path $ProjectDir "_shared-context.md"
if (Test-Path $ContextPath) {
    $content = Get-Content $ContextPath -Raw
    if ($content -match '\(describe what phase the project is in') {
        Write-Host "    WARNING: _shared-context.md still contains the 'Current phase' placeholder."
        Write-Host "             Edit it before running the pattern, or the chain will run on incomplete context."
        $Warnings++
    } else {
        Write-Host "    OK: 'Current phase' placeholder has been replaced"
    }
}

# Check 3: scripts

Write-Host ""
Write-Host "[3/4] Checking plugin scripts..."

$ExpectedScripts = @(
    "scripts\init.ps1",
    "scripts\watchdog.ps1",
    "scripts\resume.ps1",
    "scripts\post-process.ps1"
)

foreach ($s in $ExpectedScripts) {
    $path = Join-Path $PluginRoot $s
    if (Test-Path $path) {
        Write-Host "    OK: $s"
    } else {
        Write-Host "    MISSING: $s"
        $Errors++
    }
}

# Check 4: agent briefings

Write-Host ""
Write-Host "[4/4] Checking agent briefings..."

$RequiredAgents = @(
    "agents\triage.md",
    "agents\wildcard-breadth.md",
    "agents\methodology.md",
    "agents\orchestration.md",
    "agents\structure.md",
    "agents\stakeholder-sweep.md",
    "agents\contradictions.md",
    "agents\gap-hunter.md",
    "agents\verifier.md",
    "agents\consolidation.md"
)

foreach ($a in $RequiredAgents) {
    $path = Join-Path $PluginRoot $a
    if (Test-Path $path) {
        Write-Host "    OK: $a"
    } else {
        Write-Host "    MISSING: $a"
        $Errors++
    }
}

# Summary

Write-Host ""
Write-Host "Summary: $Errors errors, $Warnings warnings"

if ($Errors -gt 0) {
    Write-Host ""
    Write-Host "Smoke test failed. Resolve the missing files before launching a real run."
    Write-Host "If init.ps1 has not been run yet, run it first:"
    Write-Host "    $PluginRoot\scripts\init.ps1"
    exit 1
}

# Manual step

Write-Host @"

Static checks passed.

Now do the live check (2 minutes):

  1. Open a fresh terminal in this directory ($ProjectDir)
  2. Run:

       claude --model opus --dangerously-skip-permissions

  3. At the prompt, type:

       Read $ProjectDir\_shared-context.md and summarise it in three sentences.

  4. If the summary returns within ~30 seconds and no permission errors appear,
     your setup is verified. End the session and open a fresh terminal for the
     real run.

  5. If you see permission errors:
     - Confirm you launched with --dangerously-skip-permissions
     - Confirm no other Claude Code session is running in this directory
     - Confirm the project directory is not inside a permission-restricted parent

"@

if ($Warnings -gt 0) {
    Write-Host "Note: $Warnings warning(s) above. Review _shared-context.md before launching."
}
