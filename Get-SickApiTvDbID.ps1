Function Get-SickApiTvdbID{
[CmdletBinding()]
Param (
[Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
[string[]]$urlbase, $ShowName)

<#server info comes in here want to modify this so that you could specify a server info parameter too though.
That would be great in the long term.#>

$urlbase

$url = $urlbase + "?cmd=sb.searchtvdb&name=" + $ShowName

[net.httpWebRequest] $request  = [net.webRequest]::create($url)
[net.httpWebResponse] $response = $request.getResponse()
$responseStream = $response.getResponseStream()
$sr = new-object IO.StreamReader($responseStream)
$result = $sr.ReadToEnd()
$showinfo = ConvertFrom-Json $result
$showinfo.data.results.tvdbid

}