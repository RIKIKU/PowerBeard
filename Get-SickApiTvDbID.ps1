Function Get-SickApiTvdbID{
[CmdletBinding()]
Param (
[Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
[string[]]$ServerConnectionString, $ShowName)
<#Param (
[Parameter(Mandatory=$True,ValueFromPipeline=$false,ValueFromPipelinebyPropertyName=$false)]
[string[]]$ShowName
)#>

<#server info comes in here want to modify this so that you could specify a server info parameter too though.
That would be great in the long term.#>

[string]$ServerConnectionString

[string]$url = $ServerConnectionString + "?cmd=sb.searchtvdb&name=" + $ShowName

[net.httpWebRequest] $request  = [net.webRequest]::create($url)
[net.httpWebResponse] $response = $request.getResponse()
$responseStream = $response.getResponseStream()
$sr = new-object IO.StreamReader($responseStream)
$result = $sr.ReadToEnd()
$showinfo = ConvertFrom-Json $result
$showinfo.data.results

}