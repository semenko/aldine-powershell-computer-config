# Remove old G2M Runfiles
Stop-Process -processname g2mstart
Stop-Process -processname g2mlauncher
Stop-Process -processname g2mcomm

Remove-Item "C:\Program Files (x86)\Citrix\GoToMeeting" -Force -Recurse -ErrorAction Ignore

Remove-ItemProperty -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" -Name "GoToMeetingInstall6956" -ErrorAction Ignore
Remove-ItemProperty -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" -Name "GoToMeetingInstall7155" -ErrorAction Ignore
Remove-ItemProperty -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run" -Name "GoToMeetingInstall7586" -ErrorAction Ignore

