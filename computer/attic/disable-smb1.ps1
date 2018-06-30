

# Remove SMB1
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart | Out-Null
