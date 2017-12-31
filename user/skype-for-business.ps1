### Set Skype for Business Registry Tweaks

# HKEY_CURRENT_USER\AppEvents\Schemes\Apps\Communicator\ LYNC_ringing.Current
# HKEY_CURRENT_USER\AppEvents\Schemes\Apps\Communicator\ LYNC_incomingteamcall.Current
# HKEY_CURRENT_USER\AppEvents\Schemes\Apps\Communicator\ LYNC_incomingdelegatecall.Current
# HKEY_CURRENT_USER\AppEvents\Schemes\Apps\Communicator\ LYNC_incomingteamcall.Current

Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\Common\General" -Name "ShownFirstRunOptin" -Value "1" -Type DWord -ErrorAction Ignore

Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Lync" -Name "EnableTracing" -Value "1" -Type DWord -ErrorAction Ignore
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Lync" -Name "EnableEventLogging" -Value "1" -Type DWord -ErrorAction Ignore
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Lync" -Name "DisableCalendarPresence" -Value "1" -Type DWord -ErrorAction Ignore
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Lync" -Name "DisplayPhoto" -Value "1" -Type DWord -ErrorAction Ignore

Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Lync" -Name "AlwaysShowMenu" -Value "1" -Type DWord -ErrorAction Ignore
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Lync" -Name "FirstRun" -Value "1" -Type DWord -ErrorAction Ignore
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Lync" -Name "AddToFirewallExceptionList" -Value "1" -Type DWord -ErrorAction Ignore
