Set-WSManQuickConfig -force

$config=Get-Content c:\scripts\server-config.json -raw | ConvertFrom-Json

$cert = New-SelfSignedCertificate -DnsName $config.FQDN -CertStoreLocation Cert:\LocalMachine\My -NotAfter (get-date).AddYears(5)

$selector_set = @{
       Address = "*"
       Transport = "HTTPS"
}
$value_set = @{
       CertificateThumbprint = $cert.ThumbPrint
}

New-WSManInstance -ResourceURI "winrm/config/Listener" -SelectorSet $selector_set -ValueSet $value_set
Get-ChildItem -Path WSMan:\localhost\Listener | Where-Object { $_.Keys -contains "Transport=HTTP" } | Remove-Item -Recurse -Force

$rule = @{
       Name = "WINRM-HTTPS-In-TCP"
       DisplayName = "Windows Remote Management (HTTPS-In)"
       Description = "Inbound rule for Windows Remote Management via WS-Management. [TCP 5986]"
       Enabled = "true"
       Direction = "Inbound"
       Profile = "Any"
       Action = "Allow"
       Protocol = "TCP"
       LocalPort = "5986"
}
New-NetFirewallRule @rule