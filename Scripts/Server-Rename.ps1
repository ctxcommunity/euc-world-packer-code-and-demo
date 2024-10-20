$config=Get-Content c:\scripts\server-config.json -raw | ConvertFrom-Json
Rename-Computer $config.computername

