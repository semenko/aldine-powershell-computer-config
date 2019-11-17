# Set audit logging of processes

AuditPol /set /subcategory:"Process Creation" /success:enable /failure:enable

# Firewall drop logging

netsh advfirewall set allprofiles logging droppedconnections enable
