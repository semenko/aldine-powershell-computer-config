# Fixes a Microsoft Intune bug

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force
Install-Module -Name Microsoft.WindowsPassportUtilities.Commands -Scope CurrentUser -Force
Remove-PassportContainer –CurrentUser
