<#  Example of usage:
(SickAPI -Server localhost -Port 8081 -ApiKey ab3b1539af60c8d65775081a9fa1485f -ssl $false -ApiCMD "sb.searchtvdb&name=south park").data
if an APICMD is not specified the default of "sb" is used which will return general SickBeard server info.

Credit where due:
Github user Biranaddicks is the original creator of most of the code herein. I have simply taken part of it and turned it into
a function so it can be used to query a server more easily. His original content can be found here: 
https://github.com/brianaddicks/PowerShell/blob/master/Sickbeard-SnatchedToWanted.ps1
#>

Function New-SickAPIQuery {
Param ($Server, $Port, $ApiKey, $ssl = $false, $ApiCMD = "sb")

if (($ssl -eq $true) -or ($ssl -match 'yes|Yes|y|Y')) {
    $urlbase = "https://$server`:$Port/api/$ApiKey/"
    # ignore certificate errors
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    [System.Net.ServicePointManager]::Expect100Continue = {$true}
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::ssl3
} else {
    $urlbase = "http://$server`:$Port/api/$ApiKey/"
}

$url = $urlbase + "/?cmd=" + $ApiCMD

[net.httpWebRequest] $request  = [net.webRequest]::create($url)
[net.httpWebResponse] $response = $request.getResponse()
$responseStream = $response.getResponseStream()
$sr = new-object IO.StreamReader($responseStream)
$result = $sr.ReadToEnd()
ConvertFrom-Json $result
}