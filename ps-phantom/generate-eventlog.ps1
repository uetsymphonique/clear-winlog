# generate-eventlog.ps1
# Writes sample events to Application, System logs
# Security log requires audit-trigger (see below)

$src       = 'Phant0mTestSource'
$eventId   = 9001
$message   = 'Test event from Phant0m validation script.'

# --- Application Log ---
$appLog = 'Application'
if (-not [System.Diagnostics.EventLog]::SourceExists($src)) {
    New-EventLog -LogName $appLog -Source $src
}
1..3 | ForEach-Object {
    Write-EventLog -LogName $appLog -Source $src -EntryType Information `
        -EventId $eventId -Message "$message [Application] Iteration=$_"
    Start-Sleep -Milliseconds 100
}
Write-Host "[+] Application log: 3 events written" -ForegroundColor Green

# --- System Log ---
# System log uses built-in sources; we borrow 'EventLog' source (safe for testing)
1..3 | ForEach-Object {
    Write-EventLog -LogName System -Source 'EventLog' -EntryType Warning `
        -EventId $eventId -Message "$message [System] Iteration=$_"
    Start-Sleep -Milliseconds 100
}
Write-Host "[+] System log: 3 events written" -ForegroundColor Green

# --- Security Log (indirect trigger) ---
# Security log cannot be written directly via Write-EventLog.
# We trigger a failed logon to generate event 4625 (Audit Logon Failure).
try {
    $badCred = New-Object System.Management.Automation.PSCredential('FakeUser', (ConvertTo-SecureString 'x' -AsPlainText -Force))
    Start-Process -FilePath 'cmd.exe' -ArgumentList '/c echo test' -Credential $badCred -ErrorAction Stop
} catch {
    # Expected to fail; failure itself generates Security event if Audit Logon is enabled
}
Write-Host "[+] Security log: triggered failed logon (Event 4625 if Audit enabled)" -ForegroundColor Yellow

Write-Host ""
Write-Host "Verify with:"
Write-Host "  Get-EventLog -LogName Application -Newest 5 -Source $src"
Write-Host "  Get-EventLog -LogName System -Newest 5 | Where-Object { `$_.EventID -eq $eventId }"
Write-Host "  Get-WinEvent -LogName Security -MaxEvents 5 | Format-Table TimeCreated,Id,Message -Wrap"