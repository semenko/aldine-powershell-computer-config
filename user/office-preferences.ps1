
## Outlook
# Show All Images in Emails
New-ItemProperty -Path "HKCU:\Software\Microsoft\Office\16.0\Outlook\Options\Mail" -Name "BlockExtContent" -Value 0 -PropertyType DWORD -Force | Out-Null
