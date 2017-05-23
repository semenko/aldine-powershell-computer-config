@echo off

IF NOT "%USERDOMAIN%" == "AzureAD" (
    echo Connected to Azure AD -- Spawning PowerShell command.
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& './redirect-folders-and-setup-apps.ps1'"
    echo Done.
) ELSE (
    echo Not on Azure AD -- nothing to do.
)
