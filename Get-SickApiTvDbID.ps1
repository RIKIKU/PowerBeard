Function Get-SickApiTvdbID{
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
    [string[]]$ServerConnectionString,
    [Parameter(Mandatory=$True)][string]$ShowName
        )
#compile the appropriate URL here.
[string]$url = $ServerConnectionString + "?cmd=sb.searchtvdb&name=" + $ShowName
#send request to server and retrieve output
[net.httpWebRequest] $request  = [net.webRequest]::create($url)
[net.httpWebResponse] $response = $request.getResponse()
$responseStream = $response.getResponseStream()
$sr = new-object IO.StreamReader($responseStream)
$result = $sr.ReadToEnd()
$showinfo = ConvertFrom-Json $result
$showinfo.data.results
}