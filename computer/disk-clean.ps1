# Run Disk Cleanup
# Via https://stackoverflow.com/questions/40534323/windows-update-cleanup-in-registry-editor

$SageSet = "StateFlags0099"
$Base = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\"

$Locations= @(
    "Active Setup Temp Folders"
    "BranchCache"
    "Downloaded Program Files"
    "GameNewsFiles"
    "GameStatisticsFiles"
    "GameUpdateFiles"
    "Internet Cache Files"
    "Memory Dump Files"
    "Offline Pages Files"
    "Old ChkDsk Files"
    "Previous Installations"
    "Recycle Bin"
    "Service Pack Cleanup"
    "Setup Log Files"
    "System error memory dump files"
    "System error minidump files"
    "Temporary Files"
    "Temporary Setup Files"
    "Temporary Sync Files"
    "Thumbnail Cache"
    "Update Cleanup"
    "Upgrade Discarded Files"
    "User file versions"
    "Windows Defender"
    "Windows Error Reporting Archive Files"
    "Windows Error Reporting Queue Files"
    "Windows Error Reporting System Archive Files"
    "Windows Error Reporting System Queue Files"
    "Windows ESD installation files"
    "Windows Upgrade Log Files"
)

ForEach($Location in $Locations) {
    Set-ItemProperty -Path $($Base+$Location) -Name $SageSet -Type DWORD -Value 2 -ea silentlycontinue | Out-Null
}

# do the cleanup . have to convert the SageSet number
$Args = "/sagerun:$([string]([int]$SageSet.Substring($SageSet.Length-4)))"
Start-Process -Wait "$env:SystemRoot\System32\cleanmgr.exe" -ArgumentList $Args -WindowStyle Hidden

# Remove the Stateflags
ForEach($Location in $Locations)
{
    Remove-ItemProperty -Path $($Base+$Location) -Name $SageSet -Force -ea silentlycontinue | Out-Null
}
