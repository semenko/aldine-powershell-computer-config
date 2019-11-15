# Enable virtualization / platform hardening
# Works via registry, since InTune / MDM nodes are not enabled for Windows 10 Business

New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -Name EnableVirtualizationBasedSecurity -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -Name RequirePlatformSecurityFeatures -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -Name Locked -Value 0 -PropertyType DWORD -Force -ErrorAction SilentlyContinue

New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name Enabled -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name Locked -Value 0 -PropertyType DWORD -Force -ErrorAction SilentlyContinue

New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\LSA" -Name LsaCfgFlags -Value 2 -PropertyType DWORD -Force -ErrorAction SilentlyContinue
