## Assorted local site tweaks and customizations.

## Enable NumLock
# Derived from https://gist.github.com/alirobe/7f3b34ad89a159e6daa1
Write-Host "Enabling NumLock after startup..."
If (!(Test-Path "HKU:")) {
  New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS | Out-Null
}
Set-ItemProperty -Path "HKU:\.DEFAULT\Control Panel\Keyboard" -Name "InitialKeyboardIndicators" -Type DWord -Value 2147483650
Add-Type -AssemblyName System.Windows.Forms
If (!([System.Windows.Forms.Control]::IsKeyLocked('NumLock'))) {
  $wsh = New-Object -ComObject WScript.Shell
  $wsh.SendKeys('{NUMLOCK}')
}


## Polycom BToE Disable Popups & PC Audio

#[HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Polycom\Polycom BToE Connector]
#"NOTIFY_MSG_EN"=dword:00000000
#"PLAYBACK_MODE_EN"=dword:00000000
#"WRN_MSGBOX_EN"=dword:00000000


## GoToMyPC


# 
