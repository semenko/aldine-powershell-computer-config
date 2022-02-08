## Set Zoom requirements
# Updated for Zoom 5.9.0

# LOL
New-Item -Path "HKLM:\Software\Policies\Zoom" -Force | Out-Null
New-Item -Path "HKLM:\SOFTWARE\Policies\Zoom\Zoom Meetings" -Force | Out-Null
New-Item -Path "HKLM:\SOFTWARE\Policies\Zoom\Zoom Meetings\General" -Force | Out-Null
New-Item -Path "HKLM:\SOFTWARE\Policies\Zoom\Zoom Meetings\Chat" -Force | Out-Null

$ZoomGeneral = "HKLM:\SOFTWARE\Policies\Zoom\Zoom Meetings\General"

# Aggressive update policies -- some may be the default, but just enforce if not
Set-ItemProperty -Path $ZoomGeneral -Name "EnableClientAutoUpdate" -Type DWORD -Value 1
Set-ItemProperty -Path $ZoomGeneral -Name "EnableSilentAutoUpdate" -Type DWORD -Value 1
Set-ItemProperty -Path $ZoomGeneral -Name "AlwaysCheckLatestVersion" -Type DWORD -Value 1
Set-ItemProperty -Path $ZoomGeneral -Name "SetUpdatingChannel" -Type DWORD -Value 1

# Start and keep starting
Set-ItemProperty -Path $ZoomGeneral -Name "AutoStartAfterReboot" -Type DWORD -Value 1
Set-ItemProperty -Path $ZoomGeneral -Name "CloseToSystemTray" -Type DWORD -Value 0
Set-ItemProperty -Path $ZoomGeneral -Name "AutoStartAfterReboot" -Type DWORD -Value 1
Set-ItemProperty -Path $ZoomGeneral -Name "KeepSignedIn" -Type DWORD -Value 1

# Login SSO
Set-ItemProperty -Path $ZoomGeneral -Name "SetSSOURL" -Type String -Value "aldinetravel.zoom.us"
Set-ItemProperty -Path $ZoomGeneral -Name "ForceSSOURL" -Type String -Value "aldinetravel"
Set-ItemProperty -Path $ZoomGeneral -Name "ForceLoginWithSSO" -Type DWORD -Value 1
Set-ItemProperty -Path $ZoomGeneral -Name "DisableFacebookLogin" -Type DWORD -Value 1
Set-ItemProperty -Path $ZoomGeneral -Name "DisableGoogleLogin" -Type DWORD -Value 1
Set-ItemProperty -Path $ZoomGeneral -Name "DisableLoginWithEmail" -Type DWORD -Value 1
Set-ItemProperty -Path $ZoomGeneral -Name "EnforceSignInToJoin" -Type DWORD -Value 1


# Crashlogs
Set-ItemProperty -Path $ZoomGeneral -Name "EnableAutoUploadDumps" -Type DWORD -Value 1
Set-ItemProperty -Path $ZoomGeneral -Name "EnableAutoUploadMemlogs" -Type DWORD -Value 1

# Yes outlook, no apps
Set-ItemProperty -Path $ZoomGeneral -Name "IntegrateZoomWithOutlook" -Type DWORD -Value 1
Set-ItemProperty -Path $ZoomGeneral -Name "DisableZoomApps" -Type DWORD -Value 1


# Chat non-defaults

$ZoomChat = "HKLM:\SOFTWARE\Policies\Zoom\Zoom Meetings\Chat"

Set-ItemProperty -Path $ZoomChat -Name "SetMessengerDoNotDropThread" -Type DWORD -Value 1
Set-ItemProperty -Path $ZoomChat -Name "AlwaysShowIMNotificationBanner" -Type DWORD -Value 1
