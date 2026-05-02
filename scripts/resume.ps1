# Gap-Hunter Resume Helper (PowerShell)
#
# Inspects .gap-hunter/state.json and reports what would be resumed.
# The actual resume is orchestrated by the /gap-hunt-resume slash command;
# this script provides a quick state inspection for the user.

param(
    [string]$StateFile = ".\.gap-hunter\state.json",
    [switch]$Json,
    [switch]$Validate
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $StateFile)) {
    Write-Error "No state file found at $StateFile"
    Write-Host "Nothing to resume. Start a fresh run with: .\scripts\init.ps1"
    exit 1
}

if ($Json) {
    Get-Content $StateFile -Raw
    exit 0
}

$state = Get-Content $StateFile -Raw | ConvertFrom-Json

Write-Host "Gap-Hunter run state"
Write-Host "  Mode: $($state.mode)"
Write-Host "  Adaptor: $($state.adaptor)"
Write-Host "  Started: $($state.started_at)"
Write-Host "  Last update: $($state.last_updated_at)"
Write-Host "  Last checkpoint: $(if ($state.last_checkpoint) { $state.last_checkpoint } else { 'none' })"
Write-Host ""
Write-Host "  Completed agents ($($state.completed_agents.Count)):"
foreach ($agent in $state.completed_agents) {
    Write-Host "    - $($agent.id) ($($agent.completed_at))"
}
Write-Host ""
Write-Host "  Pending agents ($($state.pending_agents.Count)):"
foreach ($agent in $state.pending_agents) {
    Write-Host "    - $agent"
}

if ($Validate) {
    Write-Host ""
    Write-Host "  Validating output files for completed agents..."
    $invalid = 0
    foreach ($agent in $state.completed_agents) {
        $path = $agent.output_path
        if ((Test-Path $path) -and ((Get-Item $path).Length -gt 0)) {
            Write-Host "    OK: $path"
        } else {
            Write-Host "    MISSING or EMPTY: $path"
            $invalid++
        }
    }

    if ($invalid -gt 0) {
        Write-Host ""
        Write-Host "  WARNING: $invalid completed agent(s) have missing or empty output files."
        Write-Host "  Resume will need to re-run those agents."
    }
}

Write-Host ""
Write-Host "To resume the run:"
Write-Host "  claude --model opus --dangerously-skip-permissions"
Write-Host "  > /gap-hunt resume"
