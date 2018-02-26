## OneDrive User Settings
# Since it's not clear how well the redirect script / task works

New-Item -Path "HKCU:\Software\Microsoft" -Name OneDrive -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKCU:\Software\Microsoft\OneDrive" -Name DefaultToBusinessFRE -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKCU:\Software\Microsoft\OneDrive" -Name DisablePersonalSync -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKCU:\Software\Microsoft\OneDrive" -Name EnableEnterpriseUpdate -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKCU:\Software\Microsoft\OneDrive" -Name EnableADAL -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKCU:\Software\Microsoft\OneDrive" -Name SilentAccountConfig -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKCU:\Software\Microsoft\OneDrive" -Name EnableAllOcsiClients -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKCU:\Software\Microsoft\OneDrive" -Name EnableHoldTheFile -Value 0 -PropertyType DWORD -Force -ErrorAction SilentlyContinue

New-Item -Path "HKCU:\Software\Microsoft\OneDrive" -Name AllowTenantList -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKCU:\Software\Microsoft\OneDrive\AllowTenantList" -Name a3230643-8a7c-41ca-b8e5-e7ee5c2d17b2 -PropertyType String -Force -ErrorAction SilentlyContinue

New-Item -Path "HKCU:\Software\Microsoft\OneDrive" -Name DisableCustomRoot -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKCU:\Software\Microsoft\OneDrive\DisableCustomRoot" -Name a3230643-8a7c-41ca-b8e5-e7ee5c2d17b2 -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue

New-Item -Path "HKCU:\Software\Policies\Microsoft" -Name OneDrive -ErrorAction SilentlyContinue
New-Item -Path "HKCU:\Software\Policies\Microsoft\OneDrive" -Name DisableCustomRoot -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\OneDrive\DisableCustomRoot" -Name a3230643-8a7c-41ca-b8e5-e7ee5c2d17b2 -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue


New-Item -Path "HKCU:\Software\Microsoft\OneDrive" -Name DiskSpaceCheckThresholdMB -ErrorAction SilentlyContinue
New-ItemProperty -Path "HKCU:\Software\Microsoft\OneDrive\DiskSpaceCheckThresholdMB" -Name a3230643-8a7c-41ca-b8e5-e7ee5c2d17b2 -Value '00500000' -PropertyType DWORD -Force -ErrorAction SilentlyContinue

