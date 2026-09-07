# Dump Litro's on-device SQLite database.
#
#   .\tools\db.ps1                              all three tables
#   .\tools\db.ps1 "select * from bikes"        any SQL you like
#
# Pulls a COPY off the emulator each run, so what you see is always fresh.
# Editing the copy does nothing to the phone.

param([string]$Query)

$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
$sq  = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\sqlite3.exe"
$pkg = 'com.michaelmarfil.litro'
$tmp = Join-Path $env:TEMP 'litro-db.sqlite'

# cmd's redirect is binary-safe; PowerShell's `>` corrupts the file.
cmd /c "`"$adb`" exec-out run-as $pkg cat app_flutter/litro.sqlite > `"$tmp`""

if (-not (Test-Path $tmp) -or (Get-Item $tmp).Length -eq 0) {
    Write-Host "Couldn't read the database." -ForegroundColor Red
    Write-Host "Check: emulator running, app installed, at least one launch since install."
    exit 1
}

if ($Query) {
    & $sq $tmp -header -column $Query
    exit
}

foreach ($t in @('bikes', 'stations', 'fuel_entries')) {
    $n = (& $sq $tmp "select count(*) from $t;")
    Write-Host ""
    Write-Host "--- $t ($n rows) ---" -ForegroundColor Cyan
    if ($n -ne '0') { & $sq $tmp -header -column "select * from $t;" }
}
Write-Host ""
