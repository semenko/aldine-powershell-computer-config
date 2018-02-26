#Module name:      O4BClientAutoConfig
#Author:           Jos Lieben (OGD)
#Author Company:   OGD (http://www.ogd.nl)
#Author Blog:      http://www.lieben.nu
#Date:             13-02-2018
#Purpose:          Configure Onedrive for Business (Onedrive.exe) to silently link to the user's business tenant, and optionally redirect known folders to desired subfolders
#Requirements:     Windows 10
#Instructions:     http://www.lieben.nu/liebensraum/o4bclientautoconfig/

#Mentions / articles used:
#@Per Larsen for writing on silent auto config: https://osddeployment.dk/2017/12/18/how-to-silently-configure-onedrive-for-business-with-intune/
#@Aaron Parker for writing on folder redirection using Powershell: https://stealthpuppy.com/onedrive-intune-folder-redirection
#https://support.office.com/en-us/article/Use-Group-Policy-to-control-OneDrive-sync-client-settings-0ecb2cf5-8882-42b3-a6e9-be6bda30899c
#https://support.office.com/en-us/article/deploy-the-new-onedrive-sync-client-in-an-enterprise-environment-3f3a511c-30c6-404a-98bf-76f95c519668
#http://www.lieben.nu/liebensraum/o4bclientautoconfig/

#REQUIRED CONFIGURATION:
$copyExistingFiles = $False #use with caution! Could take a long time and does not resist a reboot
$redirectFoldersToOnedriveForBusiness = $True #if enabled, the next array needs to be configured as well
$enableFilesOnDemand = $True #Needs Windows 10 1709 or higher
$listOfFoldersToRedirectToOnedriveForBusiness = @(#One line for each folder you want to redirect. For knownFolderInternalName choose from Get-KnownFolderPath function, for knownFolderInternalIdentifier choose from Set-KnownFolderPath function
    @{"knownFolderInternalName" = "Desktop";"knownFolderInternalIdentifier"="Desktop";"desiredSubFolderNameInOnedrive"="Desktop"},
    @{"knownFolderInternalName" = "MyDocuments";"knownFolderInternalIdentifier"="Documents";"desiredSubFolderNameInOnedrive"="Documents"},
    @{"knownFolderInternalName" = "Downloads";"knownFolderInternalIdentifier"="Downloads";"desiredSubFolderNameInOnedrive"="Downloads"},
    @{"knownFolderInternalName" = "MyPictures";"knownFolderInternalIdentifier"="Pictures";"desiredSubFolderNameInOnedrive"="Pictures"},
    @{"knownFolderInternalName" = "MyVideos";"knownFolderInternalIdentifier"="Videos";"desiredSubFolderNameInOnedrive"="Videos"}
)

#OPTIONAL CONFIGURATION:
$xmlDownloadURL = "https://g.live.com/1rewlive5skydrive/ODSUInsider"
$minimumOfflineVersionRequired = 17
$temporaryInstallerPath = Join-Path $Env:TEMP -ChildPath "OnedriveInstaller.EXE"
$logFileX64 = Join-Path $Env:TEMP -ChildPath "OnedriveAutoConfigx64.log"
$logFileX86 = Join-Path $Env:TEMP -ChildPath "OnedriveAutoConfigx86.log"

#Restart self in x64
If (!([Environment]::Is64BitProcess)){
    Start-Transcript -Path $logFileX86
    if([Environment]::Is64BitOperatingSystem){
        Write-Output "Running 32 bit Powershell on 64 bit OS, restarting as 64 bit process..."
        $arguments = "-NoProfile -ExecutionPolicy ByPass -WindowStyle Hidden -File `"" + $myinvocation.mycommand.definition + "`""
        $path = (Join-Path $Env:SystemRoot -ChildPath "\sysnative\WindowsPowerShell\v1.0\powershell.exe")
        Start-Process $path -ArgumentList $arguments -Verb Open -Wait
        Write-Output "finished x64 version of PS"
        Stop-Transcript
        Exit
    }else{
        Write-Output "Running 32 bit Powershell on 32 bit OS"
    }
}else{
    Start-Transcript -Path $logFileX64
}

#CREATE SILENT RUNNER (SO USER DOESN'T SEE A PS WINDOW)
$desiredBootScriptFolder = Join-Path $Env:ProgramData -ChildPath "Lieben.nu"
$vbsSilentPSRunner = "
Dim objShell,objFSO,objFile

Set objShell=CreateObject(`"WScript.Shell`")
Set objFSO=CreateObject(`"Scripting.FileSystemObject`")

strPath=WScript.Arguments.Item(0)

If objFSO.FileExists(strPath) Then
    set objFile=objFSO.GetFile(strPath)
    strCMD=`"powershell -nologo -executionpolicy ByPass -command `" & Chr(34) & `"&{`" &_
     objFile.ShortPath & `"}`" & Chr(34)
    objShell.Run strCMD,0
Else
    WScript.Echo `"Failed to find `" & strPath
    WScript.Quit
End If
"
$desiredBootScriptPath = Join-Path $desiredBootScriptFolder -ChildPath "O4BClientAutoConfig.ps1"
$desiredVBSScriptPath = Join-Path $desiredBootScriptFolder -ChildPath "O4BClientAutoConfig.vbs"

if(![System.IO.Directory]::($desiredBootScriptFolder)){
    New-Item -Path $desiredBootScriptFolder -Type Directory -Force
}

$vbsSilentPSRunner | Out-File $desiredVBSScriptPath -Force

#ENSURE CONFIG REGISTRY KEYS ARE CREATED
try{
    Write-Output "Adding registry keys for Onedrive"
    $res = New-Item -Path "HKLM:\Software\Policies\Microsoft" -Name OneDrive -Force -ErrorAction SilentlyContinue
    $res = New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\OneDrive" -Name SilentAccountConfig -Value 1 -PropertyType DWORD -Force -ErrorAction Stop
    if($enableFilesOnDemand){
        $res = New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\OneDrive" -Name FilesOnDemandEnabled -Value 1 -PropertyType DWORD -Force -ErrorAction Stop
    }
    $res = New-Item -Path "HKLM:\Software\Policies\Microsoft\OneDrive" -Name AllowTenantList -ErrorAction SilentlyContinue
    $res = New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\OneDrive\AllowTenantList" -Name a3230643-8a7c-41ca-b8e5-e7ee5c2d17b2 -PropertyType String -Force -ErrorAction Stop
    $res = New-Item -Path "HKLM:\Software\Policies\Microsoft\OneDrive" -Name DiskSpaceCheckThresholdMB -ErrorAction SilentlyContinue
    $res = New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\OneDrive\DiskSpaceCheckThresholdMB" -Name a3230643-8a7c-41ca-b8e5-e7ee5c2d17b2 -Value '00500000' -PropertyType DWORD -Force -ErrorAction Stop
    Write-Output "Registry keys for Onedrive added"
}catch{
    Write-Error "Failed to add Onedrive registry keys, installation may not be consistent" -ErrorAction Continue
    Write-Error $_ -ErrorAction Continue
}

#REGISTER SCRIPT TO RUN AT LOGON
$wscriptPath = Join-Path $env:SystemRoot -ChildPath "System32\wscript.exe"
$fullRunPath = "$wscriptPath `"$desiredVBSScriptPath`" `"$desiredBootScriptPath`""
try{
    Write-Output "Adding logon registry key"
    New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -Name OnedriveAutoConfig -Value $fullRunPath -PropertyType String -Force -ErrorAction Stop
    Write-Output "logon registry key added"
}catch{
    Write-Error "Failed to add logon registry keys, user config will likely fail" -ErrorAction Continue
    Write-Error $_ -ErrorAction Continue
}

# Create a scheduled task to run the script once
$action = New-ScheduledTaskAction -Execute $wscriptPath -Argument "`"$desiredVBSScriptPath`" `"$desiredBootScriptPath`""
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -Compatibility Win8
$principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Users"
$task = New-ScheduledTask -Action $action -Settings $settings -Principal $principal
Register-ScheduledTask -InputObject $task -TaskName "OnedriveAutoConfig"

$localScriptContent = "
#Module name:      O4BClientAutoConfig
#Author:           Jos Lieben (OGD)
#Author Company:   OGD (http://www.ogd.nl)
#Author Blog:      http://www.lieben.nu
#Date:             12-02-2018
#Purpose:          Configure Onedrive for Business (Onedrive.exe) to silently link to the user's business tenant, and optionally redirect known folders to desired subfolders
#Requirements:     Windows 10, Powershell script should run as an Admin if O4B wasn't installed yet
`$copyExistingFiles = `$$copyExistingFiles
`$redirectFoldersToOnedriveForBusiness = `$$redirectFoldersToOnedriveForBusiness
`$listOfFoldersToRedirectToOnedriveForBusiness = @("
$listOfFoldersToRedirectToOnedriveForBusiness | % {
        $localScriptContent += "@{`"knownFolderInternalName`"=`"$($_.knownFolderInternalName)`";`"knownFolderInternalIdentifier`"=`"$($_.knownFolderInternalIdentifier)`";`"desiredSubFolderNameInOnedrive`"=`"$($_.desiredSubFolderNameInOnedrive)`"},"
}
$localScriptContent = $localScriptContent -replace ".$"
$localScriptContent += ")
`$logFile = Join-Path `$Env:TEMP -ChildPath `"OnedriveAutoConfig.log`"
`$xmlDownloadURL = `"$xmlDownloadURL`"
`$temporaryInstallerPath = `"$temporaryInstallerPath`"
`$minimumOfflineVersionRequired = `"$minimumOfflineVersionRequired`"
`$onedriveRootKey = `"HKCU:\Software\Microsoft\OneDrive\Accounts\Business`"
`$desiredBootScriptFolder = `"$desiredBootScriptFolder`"
`$desiredBootScriptPath = `"$desiredBootScriptPath`"
Start-Transcript -Path `$logFile

#ENSURE CONFIG REGISTRY KEYS ARE CREATED
try{
    Write-Output `"Adding registry keys for Onedrive`"
    `$res = New-Item -Path `"HKCU:\Software\Microsoft`" -Name OneDrive -ErrorAction SilentlyContinue
    `$res = New-ItemProperty -Path `"HKCU:\Software\Microsoft\OneDrive`" -Name DefaultToBusinessFRE -Value 1 -PropertyType DWORD -Force -ErrorAction Stop
    `$res = New-ItemProperty -Path `"HKCU:\Software\Microsoft\OneDrive`" -Name DisablePersonalSync -Value 1 -PropertyType DWORD -Force -ErrorAction Stop
    `$res = New-ItemProperty -Path `"HKCU:\Software\Microsoft\OneDrive`" -Name EnableEnterpriseUpdate -Value 1 -PropertyType DWORD -Force -ErrorAction Stop
    `$res = New-ItemProperty -Path `"HKCU:\Software\Microsoft\OneDrive`" -Name EnableADAL -Value 1 -PropertyType DWORD -Force -ErrorAction Stop
    `$res = New-ItemProperty -Path `"HKCU:\Software\Microsoft\OneDrive`" -Name SilentAccountConfig -Value 1 -PropertyType DWORD -Force -ErrorAction Stop
    `$res = New-ItemProperty -Path `"HKCU:\Software\Microsoft\OneDrive`" -Name EnableAllOcsiClients -Value 1 -PropertyType DWORD -Force -ErrorAction Stop
    `$res = New-ItemProperty -Path `"HKCU:\Software\Microsoft\OneDrive`" -Name EnableHoldTheFile -Value 0 -PropertyType DWORD -Force -ErrorAction Stop

    `$res = New-Item -Path `"HKCU:\Software\Microsoft\OneDrive`" -Name AllowTenantList -ErrorAction SilentlyContinue
    `$res = New-ItemProperty -Path `"HKCU:\Software\Microsoft\OneDrive\AllowTenantList`" -Name a3230643-8a7c-41ca-b8e5-e7ee5c2d17b2 -PropertyType String -Force -ErrorAction Stop

    `$res = New-Item -Path `"HKCU:\Software\Microsoft\OneDrive`" -Name DisableCustomRoot -ErrorAction SilentlyContinue
    `$res = New-ItemProperty -Path `"HKCU:\Software\Microsoft\OneDrive\DisableCustomRoot`" -Name a3230643-8a7c-41ca-b8e5-e7ee5c2d17b2 -Value 1 -PropertyType DWORD -Force -ErrorAction Stop

    `$res = New-Item -Path `"HKCU:\Software\Policies\Microsoft`" -Name OneDrive -ErrorAction SilentlyContinue
    `$res = New-Item -Path `"HKCU:\Software\Policies\Microsoft\OneDrive`" -Name DisableCustomRoot -ErrorAction SilentlyContinue
    `$res = New-ItemProperty -Path `"HKCU:\Software\Policies\Microsoft\OneDrive\DisableCustomRoot`" -Name a3230643-8a7c-41ca-b8e5-e7ee5c2d17b2 -Value 1 -PropertyType DWORD -Force -ErrorAction Stop


    `$res = New-Item -Path `"HKCU:\Software\Microsoft\OneDrive`" -Name DiskSpaceCheckThresholdMB -ErrorAction SilentlyContinue
    `$res = New-ItemProperty -Path `"HKCU:\Software\Microsoft\OneDrive\DiskSpaceCheckThresholdMB`" -Name a3230643-8a7c-41ca-b8e5-e7ee5c2d17b2 -Value '00500000' -PropertyType DWORD -Force -ErrorAction Stop


    Write-Output `"Registry keys for Onedrive added v2`"
}catch{
    Write-Error `"Failed to add Onedrive registry keys, installation may not be consistent`" -ErrorAction Continue
    Write-Error `$_ -ErrorAction Continue
}

function returnEnclosedValue{
    Param(
        [Parameter(Mandatory = `$True)]`$sourceString,
        [Parameter(Mandatory = `$True)]`$searchString
    )
    try{
        `$endString = `"```"`"
        `$start = `$searchString
        `$startLoc = `$sourceString.IndexOf(`$start)+`$start.Length
        if(`$startLoc -eq `$start.Length-1){
            Throw `"Not Found`"
        }
        `$searchLength = `$sourceString.IndexOf(`$endString,`$startLoc)-`$startLoc
        if(`$searchLength -eq `$startLoc-1){
            Throw `"Not Found`"
        }
        return(`$sourceString.Substring(`$startLoc,`$searchLength))
    }catch{Throw}
}

function runProcess (`$cmd, `$params, `$windowStyle=1) {
    `$p = new-object System.Diagnostics.Process
    `$p.StartInfo = new-object System.Diagnostics.ProcessStartInfo
    `$exitcode = `$false
    `$p.StartInfo.FileName = `$cmd
    `$p.StartInfo.Arguments = `$params
    `$p.StartInfo.UseShellExecute = `$False
    `$p.StartInfo.RedirectStandardError = `$True
    `$p.StartInfo.RedirectStandardOutput = `$True
    `$p.StartInfo.WindowStyle = `$windowStyle; #1 = hidden, 2 =maximized, 3=minimized, 4=normal
    `$null = `$p.Start()
    `$output = `$p.StandardOutput.ReadToEnd()
    `$exitcode = `$p.ExitCode
    `$p.Dispose()
    `$exitcode
    `$output
}

`$isOnedriveUpToDate = `$False
#GET ONLINE VERSION INFO
try{
    `$xmlInfo = Invoke-WebRequest -UseBasicParsing -Uri `$xmlDownloadURL -Method GET
    `$version = returnEnclosedValue -sourceString `$xmlInfo.Content -searchString `"currentversion=```"`"
    `$downloadURL = returnEnclosedValue -sourceString `$xmlInfo.Content -searchString `"url=```"`"
    write-output `"Microsoft's XML shows the latest Onedrive version is `$version and can be downloaded from `$downloadURL`"
}catch{
    write-error `"Failed to download / read version info for Onedrive from `$xmlDownloadURL`" -ErrorAction Continue
    write-error `$_ -ErrorAction Continue
}

#GET LOCAL INSTALL STATUS AND VERSION
try{
    `$installedVersion = (Get-ItemProperty -Path `"HKCU:\Software\Microsoft\OneDrive`" -Name `"Version`" -ErrorAction Stop).Version
    `$installedVersionPath = (Get-ItemProperty -Path `"HKCU:\Software\Microsoft\OneDrive`" -Name `"OneDriveTrigger`" -ErrorAction Stop).OneDriveTrigger
    Write-Output `"Detected `$installedVersion in registry`"
    if(`$installedVersion -le `$minimumOfflineVersionRequired -or (`$version -and `$version -gt `$installedVersion)){
        Write-Output `"Onedrive is not up to date!`"
    }else{
        `$isOnedriveUpToDate = `$True
        Write-Output `"Installed version of Onedrive is newer or the same as advertised version`"
    }
}catch{
    write-error `"Failed to read Onedrive version information from the registry, assuming Onedrive is not installed`" -ErrorAction Continue
    write-error `$_ -ErrorAction Continue
}

# Kill any existing OneDrive tasks
get-process | where {`$_.ProcessName -like `"onedrive*`"} | Stop-Process -Force -Confirm:`$False

#DOWNLOAD ONEDRIVE INSTALLER AND RUN IT
try{
    if(!`$isOnedriveUpToDate -and `$downloadURL -and `$False){
        Write-Output `"downloading from download URL: `$downloadURL`"
        Invoke-WebRequest -UseBasicParsing -Uri `$downloadURL -Method GET -OutFile `$temporaryInstallerPath
        Write-Output `"downloaded finished from download URL: `$downloadURL`"
        if([System.IO.File]::Exists(`$temporaryInstallerPath)){
            Write-Output `"Starting client installer`"
            Sleep -s 5 #let A/V scan the file so it isn't locked
            #first kill existing instances
            get-process | where {`$_.ProcessName -like `"onedrive*`"} | Stop-Process -Force -Confirm:`$False
            Sleep -s 5
            runProcess `$temporaryInstallerPath `"/silent`"
            Sleep -s 5
            Write-Output `"Install finished`"
        }
        `$installedVersionPath = (Get-ItemProperty -Path `"HKCU:\Software\Microsoft\OneDrive`" -Name `"OneDriveTrigger`" -ErrorAction Stop).OneDriveTrigger
    }
}catch{
    Write-Error `"Failed to download or install from `$downloadURL`" -ErrorAction Continue
    Write-Error `$_ -ErrorAction Continue
}

#WAIT FOR CLIENT CONFIGURATION AND REDETERMINE PATH
`$maxWaitTime = 600
`$waited = 0
Write-Output `"Checking existence of client folder`"
:detectO4B while(`$true){
    if(`$waited -gt `$maxWaitTime){
        Write-Output `"Waited too long for client folder to appear. Running auto updater, then exiting`"
        `$updaterPath = Join-Path `$Env:LOCALAPPDATA -ChildPath `"Microsoft\OneDrive\OneDriveStandaloneUpdater.exe`"
        runProcess `$updaterPath
        Sleep -s 60
        runProcess `$installedVersionPath
        Sleep -s 60
    }

    `$checks = 5
    for(`$i=1;`$i -le `$checks;`$i++){
        #check if a root path for the key exists
        `$subPath = `"`$(`$onedriveRootKey)`$(`$i)`"
        if(Test-Path `$subPath){
            `$detectedTenant = (Get-ItemProperty -Path `"`$(`$subPath)\`" -Name `"ConfiguredTenantId`" -ErrorAction SilentlyContinue).ConfiguredTenantId
            #we've found a business key with the correct TenantID, Onedrive has been started, check for the folder path
            `$detectedFolderPath = (Get-ItemProperty -Path `"`$(`$subPath)\`" -Name `"UserFolder`" -ErrorAction SilentlyContinue).UserFolder
            if(`$detectedFolderPath -and [System.IO.Directory]::Exists(`$detectedFolderPath)){
                Write-Output `"detected user folder at `$detectedFolderPath, linked to tenant `$detectedTenant`"
                break detectO4B
            }
        }
    }
    if(`$waited -gt `$maxWaitTime){
        break
    }
    Write-Output `"failed to detect user folder! Sleeping for 30 seconds`"
    Sleep -Seconds 30
    `$waited+=30

    #GET LOCAL INSTALL PATH
    try{
        `$installedVersionPath = (Get-ItemProperty -Path `"HKCU:\Software\Microsoft\OneDrive`" -Name `"OneDriveTrigger`" -ErrorAction Stop).OneDriveTrigger
        Write-Output `"Detected Onedrive at `$installedVersionPath`"
    }catch{
        write-error `"Failed to read Onedrive version information from the registry`" -ErrorAction Continue
        `$installedVersionPath = Join-Path `$Env:LOCALAPPDATA -ChildPath `"Microsoft\OneDrive\OneDrive.exe`"
        Write-output `"Will use auto-guessed value of `$installedVersionPath`"
    }

    #RUN THE LOCAL CLIENT IF ALREADY INSTALLED
    Write-Output `"Starting client...`"
    & `$installedVersionPath
}

if(!`$redirectFoldersToOnedriveForBusiness){
    Stop-Transcript
    Exit
}

###DEFINE EXTERNAL FUNCTIONS
Function Set-KnownFolderPath {
    Param (
            [Parameter(Mandatory = `$true)][ValidateSet('AddNewPrograms', 'AdminTools', 'AppUpdates', 'CDBurning', 'ChangeRemovePrograms', 'CommonAdminTools', 'CommonOEMLinks', 'CommonPrograms', `
            'CommonStartMenu', 'CommonStartup', 'CommonTemplates', 'ComputerFolder', 'ConflictFolder', 'ConnectionsFolder', 'Contacts', 'ControlPanelFolder', 'Cookies', `
            'Desktop', 'Documents', 'Downloads', 'Favorites', 'Fonts', 'Games', 'GameTasks', 'History', 'InternetCache', 'InternetFolder', 'Links', 'LocalAppData', `
            'LocalAppDataLow', 'LocalizedResourcesDir', 'Music', 'NetHood', 'NetworkFolder', 'OriginalImages', 'PhotoAlbums', 'Pictures', 'Playlists', 'PrintersFolder', `
            'PrintHood', 'Profile', 'ProgramData', 'ProgramFiles', 'ProgramFilesX64', 'ProgramFilesX86', 'ProgramFilesCommon', 'ProgramFilesCommonX64', 'ProgramFilesCommonX86', `
            'Programs', 'Public', 'PublicDesktop', 'PublicDocuments', 'PublicDownloads', 'PublicGameTasks', 'PublicMusic', 'PublicPictures', 'PublicVideos', 'QuickLaunch', `
            'Recent', 'RecycleBinFolder', 'ResourceDir', 'RoamingAppData', 'SampleMusic', 'SamplePictures', 'SamplePlaylists', 'SampleVideos', 'SavedGames', 'SavedSearches', `
            'SEARCH_CSC', 'SEARCH_MAPI', 'SearchHome', 'SendTo', 'SidebarDefaultParts', 'SidebarParts', 'StartMenu', 'Startup', 'SyncManagerFolder', 'SyncResultsFolder', `
            'SyncSetupFolder', 'System', 'SystemX86', 'Templates', 'TreeProperties', 'UserProfiles', 'UsersFiles', 'Videos', 'Windows')]
            [string]`$KnownFolder,
            [Parameter(Mandatory = `$true)][string]`$Path
    )

    # Define known folder GUIDs
    `$KnownFolders = @{
        'AddNewPrograms' = 'de61d971-5ebc-4f02-a3a9-6c82895e5c04';'AdminTools' = '724EF170-A42D-4FEF-9F26-B60E846FBA4F';'AppUpdates' = 'a305ce99-f527-492b-8b1a-7e76fa98d6e4';
        'CDBurning' = '9E52AB10-F80D-49DF-ACB8-4330F5687855';'ChangeRemovePrograms' = 'df7266ac-9274-4867-8d55-3bd661de872d';'CommonAdminTools' = 'D0384E7D-BAC3-4797-8F14-CBA229B392B5';
        'CommonOEMLinks' = 'C1BAE2D0-10DF-4334-BEDD-7AA20B227A9D';'CommonPrograms' = '0139D44E-6AFE-49F2-8690-3DAFCAE6FFB8';'CommonStartMenu' = 'A4115719-D62E-491D-AA7C-E74B8BE3B067';
        'CommonStartup' = '82A5EA35-D9CD-47C5-9629-E15D2F714E6E';'CommonTemplates' = 'B94237E7-57AC-4347-9151-B08C6C32D1F7';'ComputerFolder' = '0AC0837C-BBF8-452A-850D-79D08E667CA7';
        'ConflictFolder' = '4bfefb45-347d-4006-a5be-ac0cb0567192';'ConnectionsFolder' = '6F0CD92B-2E97-45D1-88FF-B0D186B8DEDD';'Contacts' = '56784854-C6CB-462b-8169-88E350ACB882';
        'ControlPanelFolder' = '82A74AEB-AEB4-465C-A014-D097EE346D63';'Cookies' = '2B0F765D-C0E9-4171-908E-08A611B84FF6';'Desktop' = @('B4BFCC3A-DB2C-424C-B029-7FE99A87C641');
        'Documents' = @('FDD39AD0-238F-46AF-ADB4-6C85480369C7','f42ee2d3-909f-4907-8871-4c22fc0bf756');'Downloads' = @('374DE290-123F-4565-9164-39C4925E467B','7d83ee9b-2244-4e70-b1f5-5393042af1e4');
        'Favorites' = '1777F761-68AD-4D8A-87BD-30B759FA33DD';'Fonts' = 'FD228CB7-AE11-4AE3-864C-16F3910AB8FE';'Games' = 'CAC52C1A-B53D-4edc-92D7-6B2E8AC19434';
        'GameTasks' = '054FAE61-4DD8-4787-80B6-090220C4B700';'History' = 'D9DC8A3B-B784-432E-A781-5A1130A75963';'InternetCache' = '352481E8-33BE-4251-BA85-6007CAEDCF9D';
        'InternetFolder' = '4D9F7874-4E0C-4904-967B-40B0D20C3E4B';'Links' = 'bfb9d5e0-c6a9-404c-b2b2-ae6db6af4968';'LocalAppData' = 'F1B32785-6FBA-4FCF-9D55-7B8E7F157091';
        'LocalAppDataLow' = 'A520A1A4-1780-4FF6-BD18-167343C5AF16';'LocalizedResourcesDir' = '2A00375E-224C-49DE-B8D1-440DF7EF3DDC';'Music' = @('4BD8D571-6D19-48D3-BE97-422220080E43','a0c69a99-21c8-4671-8703-7934162fcf1d');
        'NetHood' = 'C5ABBF53-E17F-4121-8900-86626FC2C973';'NetworkFolder' = 'D20BEEC4-5CA8-4905-AE3B-BF251EA09B53';'OriginalImages' = '2C36C0AA-5812-4b87-BFD0-4CD0DFB19B39';
        'PhotoAlbums' = '69D2CF90-FC33-4FB7-9A0C-EBB0F0FCB43C';'Pictures' = @('33E28130-4E1E-4676-835A-98395C3BC3BB','0ddd015d-b06c-45d5-8c4c-f59713854639');
        'Playlists' = 'DE92C1C7-837F-4F69-A3BB-86E631204A23';'PrintersFolder' = '76FC4E2D-D6AD-4519-A663-37BD56068185';'PrintHood' = '9274BD8D-CFD1-41C3-B35E-B13F55A758F4';
        'Profile' = '5E6C858F-0E22-4760-9AFE-EA3317B67173';'ProgramData' = '62AB5D82-FDC1-4DC3-A9DD-070D1D495D97';'ProgramFiles' = '905e63b6-c1bf-494e-b29c-65b732d3d21a';
        'ProgramFilesX64' = '6D809377-6AF0-444b-8957-A3773F02200E';'ProgramFilesX86' = '7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E';'ProgramFilesCommon' = 'F7F1ED05-9F6D-47A2-AAAE-29D317C6F066';
        'ProgramFilesCommonX64' = '6365D5A7-0F0D-45E5-87F6-0DA56B6A4F7D';'ProgramFilesCommonX86' = 'DE974D24-D9C6-4D3E-BF91-F4455120B917';'Programs' = 'A77F5D77-2E2B-44C3-A6A2-ABA601054A51';
        'Public' = 'DFDF76A2-C82A-4D63-906A-5644AC457385';'PublicDesktop' = 'C4AA340D-F20F-4863-AFEF-F87EF2E6BA25';'PublicDocuments' = 'ED4824AF-DCE4-45A8-81E2-FC7965083634';
        'PublicDownloads' = '3D644C9B-1FB8-4f30-9B45-F670235F79C0';'PublicGameTasks' = 'DEBF2536-E1A8-4c59-B6A2-414586476AEA';'PublicMusic' = '3214FAB5-9757-4298-BB61-92A9DEAA44FF';
        'PublicPictures' = 'B6EBFB86-6907-413C-9AF7-4FC2ABF07CC5';'PublicVideos' = '2400183A-6185-49FB-A2D8-4A392A602BA3';'QuickLaunch' = '52a4f021-7b75-48a9-9f6b-4b87a210bc8f';
        'Recent' = 'AE50C081-EBD2-438A-8655-8A092E34987A';'RecycleBinFolder' = 'B7534046-3ECB-4C18-BE4E-64CD4CB7D6AC';'ResourceDir' = '8AD10C31-2ADB-4296-A8F7-E4701232C972';
        'RoamingAppData' = '3EB685DB-65F9-4CF6-A03A-E3EF65729F3D';'SampleMusic' = 'B250C668-F57D-4EE1-A63C-290EE7D1AA1F';'SamplePictures' = 'C4900540-2379-4C75-844B-64E6FAF8716B';
        'SamplePlaylists' = '15CA69B3-30EE-49C1-ACE1-6B5EC372AFB5';'SampleVideos' = '859EAD94-2E85-48AD-A71A-0969CB56A6CD';'SavedGames' = '4C5C32FF-BB9D-43b0-B5B4-2D72E54EAAA4';
        'SavedSearches' = '7d1d3a04-debb-4115-95cf-2f29da2920da';'SEARCH_CSC' = 'ee32e446-31ca-4aba-814f-a5ebd2fd6d5e';'SEARCH_MAPI' = '98ec0e18-2098-4d44-8644-66979315a281';
        'SearchHome' = '190337d1-b8ca-4121-a639-6d472d16972a';'SendTo' = '8983036C-27C0-404B-8F08-102D10DCFD74';'SidebarDefaultParts' = '7B396E54-9EC5-4300-BE0A-2482EBAE1A26';
        'SidebarParts' = 'A75D362E-50FC-4fb7-AC2C-A8BEAA314493';'StartMenu' = '625B53C3-AB48-4EC1-BA1F-A1EF4146FC19';'Startup' = 'B97D20BB-F46A-4C97-BA10-5E3608430854';
        'SyncManagerFolder' = '43668BF8-C14E-49B2-97C9-747784D784B7';'SyncResultsFolder' = '289a9a43-be44-4057-a41b-587a76d7e7f9';'SyncSetupFolder' = '0F214138-B1D3-4a90-BBA9-27CBC0C5389A';
        'System' = '1AC14E77-02E7-4E5D-B744-2EB1AE5198B7';'SystemX86' = 'D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27';'Templates' = 'A63293E8-664E-48DB-A079-DF759E0509F7';
        'TreeProperties' = '5b3749ad-b49f-49c1-83eb-15370fbd4882';'UserProfiles' = '0762D272-C50A-4BB0-A382-697DCD729B80';'UsersFiles' = 'f3ce0f7c-4901-4acc-8648-d5d44b04ef8f';
        'Videos' = @('18989B1D-99B5-455B-841C-AB7C74E4DDFC','35286a68-3c57-41a1-bbb1-0eae73d76c95');'Windows' = 'F38BF404-1D43-42F2-9305-67DE0B28FC23';
    }

    `$Type = ([System.Management.Automation.PSTypeName]'KnownFolders').Type
    If (-not `$Type) {
        `$Signature = @'
[DllImport(`"shell32.dll`")]
public extern static int SHSetKnownFolderPath(ref Guid folderId, uint flags, IntPtr token, [MarshalAs(UnmanagedType.LPWStr)] string path);
'@
        `$Type = Add-Type -MemberDefinition `$Signature -Name 'KnownFolders' -Namespace 'SHSetKnownFolderPath' -PassThru
    }

	If (!(Test-Path `$Path -PathType Container)) {
		New-Item -Path `$Path -Type Directory -Force -Verbose
    }

    If (Test-Path `$Path -PathType Container) {
        ForEach (`$guid in `$KnownFolders[`$KnownFolder]) {
            Write-Verbose `"Redirecting `$KnownFolders[`$KnownFolder]`"
            `$result = `$Type::SHSetKnownFolderPath([ref]`$guid, 0, 0, `$Path)
            If (`$result -ne 0) {
                `$errormsg = `"Error redirecting `$(`$KnownFolder). Return code `$(`$result) = `$((New-Object System.ComponentModel.Win32Exception(`$result)).message)`"
                Throw `$errormsg
            }
        }
    } Else {
        Throw New-Object System.IO.DirectoryNotFoundException `"Could not find part of the path `$Path.`"
    }

	Attrib +r `$Path
    Return `$Path
}

Function Redirect-Folder {
    Param (
        `$SyncFolder,
        `$GetFolder,
        `$SetFolder,
        `$Target
    )

    Write-Verbose `"Redirecting `$SetFolder to `$(Join-Path `$SyncFolder -ChildPath `$Target)`"
    Set-KnownFolderPath -KnownFolder `$SetFolder -Path (Join-Path `$SyncFolder -ChildPath `$Target)
}

if(`$detectedFolderPath -and `$redirectFoldersToOnedriveForBusiness){
    `$listOfFoldersToRedirectToOnedriveForBusiness | % {
        Write-Output `"Redirecting `$(`$_.knownFolderInternalName) to `$detectedFolderPath\`$(`$_.desiredSubFolderNameInOnedrive)`"
        try{
            Redirect-Folder -SyncFolder `$detectedFolderPath -GetFolder `$_.knownFolderInternalName -SetFolder `$_.knownFolderInternalIdentifier -Target `$_.desiredSubFolderNameInOnedrive
            Write-Output `"Redirection succeeded`"
        }catch{
            Write-Error `"Failed to redirect this folder!`" -ErrorAction Continue
            Write-Error `$_ -ErrorAction Continue
        }
    }
}
Stop-Transcript
Exit
"

$localScriptContent | Out-File $desiredBootScriptPath -Force

Stop-Transcript

Start-ScheduledTask -TaskName "OnedriveAutoConfig"

Exit
