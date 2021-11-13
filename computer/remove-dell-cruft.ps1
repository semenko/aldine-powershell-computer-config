# Dell machines sometimes have pre-installed cruft:
# - Support Assist
# - Digital Delivery Services
# - Dell Command

# Let's remove them

Start-Transcript -Path "C:\intune_remove-dell-cruft.log.txt"

# Via https://stackoverflow.com/questions/56067312/how-to-uninstall-dell-support-assist-with-powershell

# Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  |
#   Get-ItemProperty |
#     Where-Object {$_.DisplayName -match "SupportAssist" -or $_.DisplayName -match "Dell Command" -or $_.DisplayName -match "Digital Delivery" } |
#     Where-Object {$_.DisplayVersion -notlike "3.2*"} |
#     Select-Object -Property  DisplayVersion, UninstallString, PSChildName

# $SAVer = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  |
#    Get-ItemProperty |
#        Where-Object {$_.DisplayName -match "SupportAssist" } |
#        Where-Object {$_.DisplayVersion -notlike "3.2*"} | 
#            Select-Object -Property DisplayVersion, UninstallString, PSChildName
            
$DellThings =  Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  | 
    Get-ItemProperty |
        Where-Object {$_.DisplayName -ne $null -and $_.DisplayName.StartsWith("Dell") } |
        Where-Object {$_.DisplayVersion -notlike "3.2*"} |
            Select-Object -Property DisplayName, DisplayVersion, UninstallString, PSChildName

Write-Host "Dell SW: $($DellThings)"

ForEach ($ver in $DellThings) {
    Write-Host "** Removing $($ver.DisplayName)"
    If ($ver.UninstallString) {
        Write-Host "  ** Version: $($ver.DisplayVersion)"
        $uninst = $ver.UninstallString
        & cmd /c $uninst /quiet /norestart

    }
}

Stop-Transcript
