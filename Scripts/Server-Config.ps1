$username = $args[0] + "\" + $args[1]
$password = $args[2] | ConvertTo-SecureString -asPlainText -Force

$config=Get-Content c:\scripts\server-config.json -raw | ConvertFrom-Json
#
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

Set-TimeZone -Id $config.timezone

$params = @{
       DomainName = $config.domainname
       OUPath = $config.OUPath
       credential = New-Object System.Management.Automation.PSCredential($username,$password)
}
   
Add-Computer @params