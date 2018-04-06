# Deploy nxlog config file & mark read only

$configURL = "https://raw.githubusercontent.com/semenko/aldine-powershell-computer-config/master/nxlog/nxlog-aldine.conf"
$certURL = "https://raw.githubusercontent.com/semenko/aldine-powershell-computer-config/master/nxlog/papertrail-bundle.pem"

Write-Output "Downloading nxlog config files."

New-Item "C:\Program Files (x86)\nxlog\conf" -ItemType Directory

(New-Object System.Net.WebClient).DownloadFile($configURL, "C:\Program Files (x86)\nxlog\conf\nxlog-aldine.conf")


New-Item "C:\Program Files (x86)\nxlog\cert" -ItemType Directory

(New-Object System.Net.WebClient).DownloadFile($certURL, "C:\Program Files (x86)\nxlog\cert\papertrail-bundle.pem")



Write-Output "Done."
