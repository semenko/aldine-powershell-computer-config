# Dervied from https://stackoverflow.com/questions/7690994/powershell-running-a-command-as-administrator

If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))

{
$arguments = "-NoProfile -ExecutionPolicy Bypass & '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}

######

########################################################
## Firewall Settings
########################################################

Import-Module NetSecurity
# Inbound Ping
New-NetFirewallRule -Name Allow_Ping -DisplayName "Allow Ping" -Description "Allow ICMPv4" -Protocol ICMPv4 -IcmpType 8 -Enabled True -Profile Any -Action Allow
# Enable RDP
Get-NetFirewallRule -DisplayName "Remote Desktop*" | Set-NetFirewallRule -enabled true

# Disable NLA
# Setting the NLA information to Disabled
(Get-WmiObject -class "Win32_TSGeneralSetting" -Namespace root\cimv2\terminalservices -ComputerName $env:computername -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0)
