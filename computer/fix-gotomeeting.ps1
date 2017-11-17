# Remove old G2M Runfiles

Remove-ItemProperty -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" -Name "GoToMeetingInstall6956" -ErrorAction Ignore
Remove-ItemProperty -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" -Name "GoToMeetingInstall7155" -ErrorAction Ignore
Remove-ItemProperty -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" -Name "GoToMeetingInstall7586" -ErrorAction Ignore

