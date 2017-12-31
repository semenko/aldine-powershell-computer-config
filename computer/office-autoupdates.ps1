#

# Force Updates
New-Item -Path "HKLM:\Software\Policies\Microsoft\Office" -Force | Out-Null
New-Item -Path "HKLM:\Software\Policies\Microsoft\Office\16.0" -Force | Out-Null
New-Item -Path "HKLM:\Software\Policies\Microsoft\Office\16.0\Common" -Force | Out-Null
New-Item -Path "HKLM:\Software\Policies\Microsoft\Office\16.0\Common\OfficeUpdate" -Force | Out-Null
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Office\16.0\Common\OfficeUpdate" -Name "EnableAutomaticUpdates" -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Office\16.0\Common\OfficeUpdate" -Name "HideEnableDisableUpdates" -Value 1 -PropertyType DWORD -Force | Out-Null