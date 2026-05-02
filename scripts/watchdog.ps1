# Gap-Hunter Watchdog (PowerShell)
#
# Monitors brain.md mtime. If no append for $Threshold seconds, fires
# a Windows toast notification. Catches the most common silent failure mode:
# an agent hangs while the orchestrator waits.
#
# Usage:
#   .\scripts\watchdog.ps1
#   .\scripts\watchdog.ps1 -Threshold 900
#   .\scripts\watchdog.ps1 -CheckEvery 60

param(
    [int]$Threshold = 1800,
    [int]$CheckEvery = 60,
    [string]$BrainPath = ".\brain.md"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $BrainPath)) {
    Write-Error "brain.md not found at $BrainPath"
    exit 1
}

Write-Host "Watchdog active."
Write-Host "  Watching: $BrainPath"
Write-Host "  Stale threshold: ${Threshold}s"
Write-Host "  Check interval: ${CheckEvery}s"
Write-Host ""
Write-Host "Press Ctrl-C to stop."
Write-Host ""

$NotifiedStale = $false

function Send-Notification {
    param([string]$Title, [string]$Body)

    try {
        Add-Type -AssemblyName System.Windows.Forms
        $balloon = New-Object System.Windows.Forms.NotifyIcon
        $balloon.Icon = [System.Drawing.SystemIcons]::Information
        $balloon.BalloonTipTitle = $Title
        $balloon.BalloonTipText = $Body
        $balloon.Visible = $true
        $balloon.ShowBalloonTip(10000)
        Start-Sleep -Seconds 1
        $balloon.Dispose()
    } catch {
        Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] $Title -- $Body"
    }
}

while ($true) {
    if (-not (Test-Path $BrainPath)) {
        Send-Notification "Gap-Hunter Watchdog" "brain.md disappeared - orchestrator may have crashed."
        Start-Sleep -Seconds $CheckEvery
        continue
    }

    $mtime = (Get-Item $BrainPath).LastWriteTime
    $age = (Get-Date) - $mtime
    $ageSeconds = [int]$age.TotalSeconds

    if ($ageSeconds -gt $Threshold) {
        if (-not $NotifiedStale) {
            $minutes = [int]($ageSeconds / 60)
            Send-Notification "Gap-Hunter Watchdog" "brain.md has been stale for $minutes minutes - an agent may be stuck."
            $NotifiedStale = $true
        }
    } else {
        if ($NotifiedStale) {
            Send-Notification "Gap-Hunter Watchdog" "brain.md activity resumed."
            $NotifiedStale = $false
        }
    }

    Start-Sleep -Seconds $CheckEvery
}
