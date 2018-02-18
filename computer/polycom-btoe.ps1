## Polycom BToE Disable Popups & PC Audio

New-Item "HKLM:\SOFTWARE\WOW6432Node\Polycom" -ErrorAction Ignore
New-Item "HKLM:\SOFTWARE\WOW6432Node\Polycom\Polycom BToE Connector" -ErrorAction Ignore

Set-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Polycom\Polycom BToE Connector" -Name "NOTIFY_MSG_EN" -Value "0" -Type DWord -ErrorAction Ignore
Set-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Polycom\Polycom BToE Connector" -Name "WRN_MSGBOX_EN" -Value "0" -Type DWord -ErrorAction Ignore
Set-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Polycom\Polycom BToE Connector" -Name "PLAYBACK_MODE_EN" -Value "0" -Type DWord -ErrorAction Ignore
