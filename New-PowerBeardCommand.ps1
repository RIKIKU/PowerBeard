<#  Example of usage:
(SickAPI -Server localhost -Port 8081 -ApiKey ab3b1539af60c8d65775081a9fa1485f -ssl $false -ApiCMD "sb.searchtvdb&name=south park").data
if an APICMD is not specified the default of "sb" is used which will return general SickBeard server info.

Credit where due:
Github user Biranaddicks is the original creator of most of the code herein. I have simply taken part of it and turned it into
a function so it can be used to query a server more easily. His original content can be found here: 
https://github.com/brianaddicks/PowerShell/blob/master/Sickbeard-SnatchedToWanted.ps1
#>

Function New-PowerBeardCommand {
    Param (
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)][string[]]$ServerConnectionString, $ApiCMD = "sb")
    Begin{
        $sysvars = Get-Variable |
        select -ExpandProperty Name
        $sysvars += 'sysvars'
        }
    Process{
        [string]$url = "$($ServerConnectionString)?cmd=$ApiCMD"

        [net.httpWebRequest] $request  = [net.webRequest]::create($url)
        [net.httpWebResponse] $response = $request.getResponse()
        $responseStream = $response.getResponseStream()
        $sr = new-object IO.StreamReader($responseStream)
        $result = $sr.ReadToEnd()
        ConvertFrom-Json $result
        }
    End{
        Get-Variable | 
        where {$sysvars -notcontains $_.Name} |
        foreach {Remove-Variable $_ -ErrorAction SilentlyContinue}
        }
}