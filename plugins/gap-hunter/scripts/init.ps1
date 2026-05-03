# Gap-Hunter Pattern - interactive setup (PowerShell)
#
# Generates _shared-context.md, ORCHESTRATOR-BRIEFING.md, brain.md skeleton,
# and state file for a new run. Designed to bring a new user from zero to
# launch-ready in under 5 minutes.
#
# Usage:
#   .\scripts\init.ps1
#   .\scripts\init.ps1 -Domain saas
#   .\scripts\init.ps1 -Quiet

param(
    [string]$Domain = "",
    [switch]$Quiet
)

$ErrorActionPreference = "Stop"

$PluginRoot = (Get-Item $PSScriptRoot).Parent.FullName
$ProjectDir = Get-Location

function Read-Default {
    param([string]$Label, [string]$Default = "")
    if ($Default) {
        $response = Read-Host "$Label [$Default]"
        if ([string]::IsNullOrWhiteSpace($response)) { return $Default }
        return $response
    }
    return Read-Host $Label
}

function Choose-Option {
    param([string]$Label, [string[]]$Options)
    Write-Host $Label
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host "  $($i+1)) $($Options[$i])"
    }
    $pick = Read-Host "Choice (1-$($Options.Count))"
    if (-not ($pick -as [int]) -or [int]$pick -lt 1 -or [int]$pick -gt $Options.Count) {
        throw "Invalid choice."
    }
    return $Options[[int]$pick - 1]
}

# Greeting

Write-Host @"

  Gap-Hunter Pattern - Interactive Setup

  This will generate the files needed to launch a research run.
  Estimated time: 3-5 minutes.

  Tip: if you are unsure whether to run the pattern at all,
  start with /gap-hunter:honestfilter instead - it will tell you honestly.

"@

# Project name

$ProjectName = Read-Default "Project name (used in shared-context header)" (Split-Path -Leaf $ProjectDir)

# Brief

Write-Host ""
Write-Host "Briefly describe what you want researched (2-3 sentences):"
Write-Host "(Enter blank line when done)"
$BriefLines = @()
while ($true) {
    $line = Read-Host
    if ([string]::IsNullOrWhiteSpace($line)) { break }
    $BriefLines += $line
}
$Brief = $BriefLines -join "`n"

if ([string]::IsNullOrWhiteSpace($Brief)) {
    Write-Error "Brief is empty. Setup cannot proceed."
    exit 1
}

# Adaptor selection

Write-Host ""
$Adaptor = if ($Domain) { $Domain } else {
    Choose-Option "Pick the adaptor closest to your project:" @(
        "saas-feature",
        "ml-model",
        "hardware",
        "compliance-heavy",
        "generic"
    )
}

$AdaptorFile = Join-Path $PluginRoot "adaptors/$Adaptor.yaml"
if (-not (Test-Path $AdaptorFile)) {
    Write-Error "Adaptor file not found: $AdaptorFile"
    exit 1
}

# Mode preference

Write-Host ""
$ModeFull = Choose-Option "Which mode do you intend to run?" @(
    "go (the main event - full pre-execution chain, ~4-6h overnight)",
    "honestfilter (unsure if you should run at all? this decides for you, ~10 min)",
    "mini (scope is open, reduced chain, ~1-2h)",
    "verify (post-wave reality check, requires prior go run)"
)
$Mode = ($ModeFull -split " ")[0]

# Invariants

Write-Host ""
Write-Host "List up to 5 system invariants (non-negotiables) for this project."
Write-Host "Examples: 'append-only audit log required', 'GDPR-compliant', 'must support SSO'"
Write-Host "One per line. Enter blank line when done."
$InvariantLines = @()
while ($true) {
    $line = Read-Host
    if ([string]::IsNullOrWhiteSpace($line)) { break }
    $InvariantLines += "- $line"
}
$Invariants = $InvariantLines -join "`n"

# Extra stakeholders

Write-Host ""
Write-Host "The $Adaptor adaptor pre-populates a default stakeholder list (see $AdaptorFile)."
$ExtraStakeholders = Read-Host "Add additional stakeholders? (comma-separated, or empty to skip)"

# Output paths

$RoundDir = Join-Path $ProjectDir "round-1"
$GhDir = Join-Path $ProjectDir ".gap-hunter"
$StrategyDir = Join-Path $ProjectDir "strategy"

New-Item -ItemType Directory -Path $RoundDir -Force | Out-Null
New-Item -ItemType Directory -Path $GhDir -Force | Out-Null
New-Item -ItemType Directory -Path $StrategyDir -Force | Out-Null

# _shared-context.md

$Date = Get-Date -Format "yyyy-MM-dd"
$DateTime = Get-Date -Format "yyyy-MM-dd HH:mm"
$DateUtc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

$ExtraStakeholdersFormatted = if ($ExtraStakeholders) {
    ($ExtraStakeholders -split ',' | ForEach-Object { "- $($_.Trim())" }) -join "`n"
} else { "(none)" }

@"
# Shared Context - $ProjectName

**Date initialised:** $Date
**Adaptor:** $Adaptor
**Intended mode:** $Mode

## Brief

$Brief

## System invariants

$Invariants

## Stakeholders

Pre-populated from adaptor: ``$Adaptor`` (see ``$AdaptorFile``)

Additional stakeholders for this project:
$ExtraStakeholdersFormatted

## Current phase

(describe what phase the project is in - discovery / planning / execution / validation)

## Project architecture document

(path to architecture doc if one exists, otherwise omit)

## Notes for the chain

(any project-specific guidance for the agents - e.g. "we have already rejected Tool X for reason Y, do not re-suggest it")
"@ | Out-File (Join-Path $ProjectDir "_shared-context.md") -Encoding utf8

Write-Host ""
Write-Host "Generated: _shared-context.md"

# brain.md

@"
# Research Brain - $ProjectName

**Initialised:** $DateTime
**Mode:** $Mode
**Adaptor:** $Adaptor

This file is **append-only**. Every agent in the chain appends a section.
After the chain completes, this file remains open during execution for
ongoing findings, blockers, and deviations.

---

"@ | Out-File (Join-Path $ProjectDir "brain.md") -Encoding utf8

Write-Host "Generated: brain.md (empty, ready for first agent)"

# state.json

@"
{
  "version": "1.0",
  "mode": "$Mode",
  "adaptor": "$Adaptor",
  "round": 1,
  "started_at": "$DateUtc",
  "last_updated_at": "$DateUtc",
  "completed_agents": [],
  "pending_agents": [],
  "emergent_spawns": [],
  "last_checkpoint": null
}
"@ | Out-File (Join-Path $GhDir "state.json") -Encoding utf8

Write-Host "Generated: .gap-hunter/state.json"

# ORCHESTRATOR-BRIEFING.md

@"
# Orchestrator Briefing - $ProjectName

**Mode:** $Mode
**Adaptor:** $Adaptor
**Initialised:** $DateTime

## Your task

You are the orchestrator for a Gap-Hunter pattern run in **$Mode** mode.

1. Read ``_shared-context.md`` for project context and invariants
2. Read ``adaptors/$Adaptor.yaml`` for domain-specific stakeholder list and methodology focus
3. Run the chain for $Mode mode (see below)
4. After each agent completes, update ``.gap-hunter/state.json``
5. After the full chain, run ``scripts/post-process.sh`` (or ``post-process.ps1``) to generate derived artefacts

## Chain for $Mode mode

(The slash command ``/gap-hunter:$Mode`` will execute this. Defer to that command.)

## Persistence rules

- ``brain.md`` is append-only - every agent adds a section, never modifies existing ones
- ``gap-hunter-OUTPUT.md`` is never modified after the Gap-Hunter writes it (Verifier uses sidecar)
- ``.gap-hunter/state.json`` is updated after every agent completion
- ``.gap-hunter/plan.md`` is overwritten with the current orchestrator plan (survives context compaction)

## Stop conditions

- Any agent fails twice in a row -> hard-fail, surface to user, do not silently proceed
- Verifier reports ``gap_hunter_quality_signal.score == "low"`` -> surface prominently before Consolidation
- User explicitly cancels -> write current state to ``.gap-hunter/state.json`` for resume capability
"@ | Out-File (Join-Path $ProjectDir "ORCHESTRATOR-BRIEFING.md") -Encoding utf8

Write-Host "Generated: ORCHESTRATOR-BRIEFING.md"

# Final guidance

Write-Host @"

  Setup complete.

  Next steps:

  1. Review and edit _shared-context.md - fill in current phase, architecture doc path,
     and project-specific notes for the chain.

  2. Run the smoke test (5 minutes, recommended before overnight runs):

     claude --model opus --dangerously-skip-permissions
     > Read $ProjectDir\_shared-context.md and summarise it in three sentences.

     If the summary comes back without permission errors, setup is verified.
     End the session and open a fresh terminal for the real run.

  3. Launch the run:

     claude --model opus --dangerously-skip-permissions
     > /gap-hunter:$Mode

  4. (Optional, recommended for overnight runs) Launch the watchdog in a separate terminal:

     .\scripts\watchdog.ps1

     It will notify you if no agent has appended to brain.md in the last 30 minutes.

  Files generated:
    _shared-context.md
    brain.md
    ORCHESTRATOR-BRIEFING.md
    .gap-hunter\state.json
    round-1\         (output directory)
    strategy\        (final artefact directory)

"@
