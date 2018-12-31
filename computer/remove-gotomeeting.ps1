# Old GoToMeeting Installs Hang Around (Why?)

$app = Get-WmiObject -Class Win32_Product -Filter "Name = 'GoToMeeting 8.5.6956 IT Installer'"
$app.Uninstall()

$app = Get-WmiObject -Class Win32_Product -Filter "Name = 'GoToMeeting 8.7.7155 IT Installer'"
$app.Uninstall()

$app = Get-WmiObject -Class Win32_Product -Filter "Name = 'GoToMeeting 8.11.7586 IT Installer'"
$app.Uninstall()

$app = Get-WmiObject -Class Win32_Product -Filter "Name = 'GoToMeeting 8.15.7759 IT Installer'"
$app.Uninstall()

$app = Get-WmiObject -Class Win32_Product -Filter "Name = 'GoToMeeting 8.20.8199 IT Installer'"
$app.Uninstall()
