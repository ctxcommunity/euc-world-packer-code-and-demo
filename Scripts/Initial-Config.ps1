####
#
#

#copy unique file name to a generic name for parse as we don't have access to
# the computername yet

New-Item -Path "c:\" -Name "scripts" -ItemType "directory"

Copy-Item -Path a:\server-config-*.json -Destination c:\scripts\server-config.json

$config=Get-Content c:\scripts\server-config.json -raw | ConvertFrom-Json

$adapter = get-netadapter -name Ether*
if ($config.staticip -match "true") {
	Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses $config.dns1,$config.dns2 -PassThru
	New-NetIPAddress -InterfaceIndex $adapter.ifIndex -AddressFamily IPv4 -IPAddress $config.ipaddress -PrefixLength $config.subnet_length -DefaultGateway $config.gateway
}
Set-NetConnectionProfile -InterfaceIndex $adapter.ifIndex -NetworkCategory Private


