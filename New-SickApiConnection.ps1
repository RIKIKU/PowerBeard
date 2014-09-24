Function New-SickAPIConnection {
Param ($Server, $Port, $ApiKey, $ssl = $false)

if (($ssl -eq $true) -or ($ssl -match 'yes|Yes|y|Y')) {
    $urlbase = "https://$server`:$Port/api/$ApiKey/"
    # ignore certificate errors
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    [System.Net.ServicePointManager]::Expect100Continue = {$true}
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::ssl3
    }
else {
    $urlbase = "http://$server`:$Port/api/$ApiKey/"
    }
#need to output the $urlbase and be able to pipe it into another function.
$urlbase 

}