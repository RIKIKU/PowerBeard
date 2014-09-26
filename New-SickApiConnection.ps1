Function New-SickAPIConnection {
[CmdletBinding()]
Param (
        [Parameter(Mandatory=$True)]$Server,
        [Parameter(Mandatory=$True)]$Port,
        [Parameter(Mandatory=$True)]$ApiKey,
        [Parameter(Mandatory=$false)]$ssl = $false,
        [parameter(Mandatory=$false)][switch]$TestConneciton
        )

if(($ssl -eq $true) -or ($ssl -match 'yes|Yes|y|Y')) {
    [string]$urlbase = "https://$server`:$Port/api/$ApiKey/"
    # ignore certificate errors
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    [System.Net.ServicePointManager]::Expect100Continue = {$true}
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::ssl3
    }
else{
    [string]$urlbase = "http://$server`:$Port/api/$ApiKey/"
    }
if($TestConneciton){
    $url = $urlbase + "/?cmd=sb"

[net.httpWebRequest] $request  = [net.webRequest]::create($url)
[net.httpWebResponse] $response = $request.getResponse()
$responseStream = $response.getResponseStream()
$sr = new-object IO.StreamReader($responseStream)
$result = $sr.ReadToEnd()
ConvertFrom-Json $result | select -Property message, result | fl
    }
#need to output the $urlbase and be able to pipe it into another function.
else{ Write-Output $urlbase
    }

}

# New-SickAPIConnection -Server localhost -Port 8081 -ApiKey ab3b1539af60c8d65775081a9fa1485f