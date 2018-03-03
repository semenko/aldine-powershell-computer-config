# Install Teams via Intune

$teamsURL = "https://statics.teams.microsoft.com/production-windows-x64/1.1.00.2251/Teams_windows_x64.exe"

Write-Output "Downloading teams."
(New-Object System.Net.WebClient).DownloadFile($teamsURL, "$env:TEMP\Teams_windows_x64.exe")

Write-Output "Running installer."
& "$env:TEMP\Teams_windows_x64.exe" /silent

Write-Output "Spawned installer."
