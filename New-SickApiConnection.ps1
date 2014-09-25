Function New-SickAPIConnection {
[CmdletBinding()]
Param ($Server, $Port, $ApiKey, $ssl = $false)

if (($ssl -eq $true) -or ($ssl -match 'yes|Yes|y|Y')) {
    $urlbase = "https://$server`:$Port/api/$ApiKey/"
    # ignore certificate errors
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    [System.Net.ServicePointManager]::Expect100Continue = {$true}
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::ssl3
    }
else {
    [string]$urlbase = "http://$server`:$Port/api/$ApiKey/"
    Write-Output $urlbase
    }
#need to output the $urlbase and be able to pipe it into another function.


}

# New-SickAPIConnection -Server localhost -Port 8081 -ApiKey ab3b1539af60c8d65775081a9fa1485f