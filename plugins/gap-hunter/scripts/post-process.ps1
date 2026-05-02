# Gap-Hunter Post-Process Validator (PowerShell)
#
# Validates that the Consolidation agent produced all expected artefacts.
# The Consolidation agent itself generates the artefacts; this script
# checks that they are present, non-empty, and structurally valid.

param(
    [switch]$Strict,
    [switch]$Delta,
    [string]$StrategyDir = ".\strategy"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $StrategyDir)) {
    Write-Error "Strategy directory not found at $StrategyDir"
    exit 1
}

$Suffix = if ($Delta) { "-v2" } else { "" }

$Catalog = Join-Path $StrategyDir "integration-catalog$Suffix.md"
$Decisions = Join-Path $StrategyDir "decisions$Suffix.md"
$Tasks = Join-Path $StrategyDir "tasks$Suffix.json"
$Risks = Join-Path $StrategyDir "risk-register$Suffix.md"
$BriefingsDir = Join-Path $StrategyDir "wave-briefings$Suffix"

# Mode detection: explore-mode produces DPRs (Decision-Pending-Records),
# plan/validate-modes produce ADRs. Validation patterns must match.
$Mode = "plan"
$StateFile = ".gap-hunter\state.json"
if (Test-Path $StateFile) {
    try {
        $stateJson = Get-Content $StateFile -Raw | ConvertFrom-Json
        if ($stateJson.mode) {
            $Mode = $stateJson.mode
        }
    } catch {
        # Ignore parse errors, fall back to default
    }
}

switch ($Mode) {
    "explore" {
        $DecisionRegex = '^#+\s+(DPR|Trunk-Decision|Decision-Pending)-'
        $DecisionLabel = "DPR/Trunk-Decision"
    }
    default {
        $DecisionRegex = '^#+\s+ADR-'
        $DecisionLabel = "ADR"
    }
}
$RiskRegex = '^#+\s+RISK-'

$Errors = 0
$Warnings = 0

function Test-Artefact {
    param([string]$Path, [string]$Label, [int]$MinSize = 100)

    if (-not (Test-Path $Path)) {
        Write-Host "  MISSING: $Label ($Path)"
        $script:Errors++
        return $false
    }

    $size = (Get-Item $Path).Length
    if ($size -lt $MinSize) {
        Write-Host "  TOO SMALL: $Label ($Path) -- $size bytes, expected at least $MinSize"
        $script:Warnings++
        return $false
    }

    Write-Host "  OK: $Label ($Path) -- $size bytes"
    return $true
}

Write-Host "Gap-Hunter post-process validation"
Write-Host ""
Write-Host "Strategy directory: $StrategyDir"
Write-Host ""

Write-Host "Primary artefact:"
Test-Artefact $Catalog "integration-catalog" 1000 | Out-Null

Write-Host ""
Write-Host "Derived artefacts:"
Test-Artefact $Decisions "decisions (ADRs)" 200 | Out-Null
Test-Artefact $Tasks "tasks (JSON)" 50 | Out-Null
Test-Artefact $Risks "risk-register" 200 | Out-Null

Write-Host ""
Write-Host "Wave briefings:"
if (-not (Test-Path $BriefingsDir)) {
    Write-Host "  MISSING: wave-briefings directory ($BriefingsDir)"
    $Errors++
} else {
    $count = (Get-ChildItem $BriefingsDir -Filter *.md -File).Count
    if ($count -eq 0) {
        Write-Host "  EMPTY: wave-briefings directory has no .md files"
        $Warnings++
    } else {
        Write-Host "  OK: $count briefing(s) found"
    }
}

if ($Strict) {
    Write-Host ""
    Write-Host "Strict checks:"

    if (Test-Path $Tasks) {
        try {
            $taskList = Get-Content $Tasks -Raw | ConvertFrom-Json
            Write-Host "  OK: tasks.json parses, $($taskList.Count) tasks"
        } catch {
            Write-Host "  ERROR: tasks.json does not parse as valid JSON"
            $Errors++
        }
    }

    if (Test-Path $Decisions) {
        $decisionCount = (Select-String -Path $Decisions -Pattern $DecisionRegex).Count
        if ($decisionCount -eq 0) {
            Write-Host "  WARNING: decisions.md contains no $DecisionLabel headers (mode: $Mode)"
            $Warnings++
        } else {
            Write-Host "  OK: decisions.md contains $decisionCount $DecisionLabel(s) (mode: $Mode)"
        }
    }

    if (Test-Path $Risks) {
        $riskCount = (Select-String -Path $Risks -Pattern $RiskRegex).Count
        if ($riskCount -eq 0) {
            Write-Host "  WARNING: risk-register.md contains no RISK- entries"
            $Warnings++
        } else {
            Write-Host "  OK: risk-register.md contains $riskCount risk(s)"
        }
    }
}

Write-Host ""
Write-Host "Summary: $Errors errors, $Warnings warnings"

if ($Errors -gt 0) {
    Write-Host ""
    Write-Host "If artefacts are missing, the Consolidation agent did not complete fully."
    Write-Host "Re-run consolidation:"
    Write-Host "  > /gap-hunt resume"
    exit 1
}

if ($Warnings -gt 0) {
    Write-Host ""
    Write-Host "Artefacts exist but may be incomplete. Review them manually."
    exit 0
}

Write-Host ""
Write-Host "All artefacts validated. Ready for handoff to execution phase."
Write-Host ""
Write-Host "Next steps:"
Write-Host "  - Open strategy\integration-catalog.md and read the executive summary"
Write-Host "  - Import strategy\tasks.json into your tracker"
Write-Host "  - Review strategy\risk-register.md for assigned ownership"
Write-Host "  - Use strategy\wave-briefings\<id>.md as direct prompts for execution agents"
