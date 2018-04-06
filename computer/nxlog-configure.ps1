# Deploy nxlog config file & mark read only

$configURL = "https://raw.githubusercontent.com/semenko/aldine-powershell-computer-config/master/nxlog/nxlog-aldine.conf"
$certURL = "https://raw.githubusercontent.com/semenko/aldine-powershell-computer-config/master/nxlog/papertrail-bundle.pem"

Write-Output "Downloading nxlog config files."

New-Item "C:\Program Files (x86)\nxlog\conf" -ItemType Directory -ErrorAction SilentlyContinue

(New-Object System.Net.WebClient).DownloadFile($configURL, "C:\Program Files (x86)\nxlog\conf\nxlog-aldine.conf")

Copy-Item "C:\Program Files (x86)\nxlog\conf\nxlog-aldine.conf" "C:\Program Files (x86)\nxlog\conf\nxlog.conf" -ErrorAction SilentlyContinue
Set-ItemProperty "C:\Program Files (x86)\nxlog\conf\nxlog.conf" -name IsReadOnly -value $true -ErrorAction SilentlyContinue

New-Item "C:\Program Files (x86)\nxlog\cert" -ItemType Directory -ErrorAction SilentlyContinue

(New-Object System.Net.WebClient).DownloadFile($certURL, "C:\Program Files (x86)\nxlog\cert\papertrail-bundle.pem")


Restart-Service -Name nxlog

Write-Output "Done."
