# System-wide OneDrive settings

New-Item -Path "HKLM:\Software\Policies\Microsoft" -Name OneDrive -Force -ErrorAction SilentlyContinue

New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\OneDrive" -Name SilentAccountConfig -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\OneDrive" -Name FilesOnDemandEnabled -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue

New-Item -Path "HKLM:\Software\Policies\Microsoft\OneDrive" -Name AllowTenantList -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\OneDrive\AllowTenantList" -Name a3230643-8a7c-41ca-b8e5-e7ee5c2d17b2 -PropertyType String -Force -ErrorAction SilentlyContinue

New-Item -Path "HKLM:\Software\Policies\Microsoft\OneDrive" -Name DiskSpaceCheckThresholdMB -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\OneDrive\DiskSpaceCheckThresholdMB" -Name a3230643-8a7c-41ca-b8e5-e7ee5c2d17b2 -Value '00500000' -PropertyType DWORD -Force -ErrorAction SilentlyContinue
