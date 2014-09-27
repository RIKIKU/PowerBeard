Function Get-PowerBeardTvdbID{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)][string[]]$ServerConnectionString,
        [Parameter(Mandatory=$True)][string]$ShowName,
        [Parameter(Mandatory=$False)][switch]$PassThru
            )
    #compile the appropriate URL here.
    [string]$url = $ServerConnectionString + "?cmd=sb.searchtvdb&name=" + $ShowName
    #send request to server and retrieve output
    [net.httpWebRequest] $request  = [net.webRequest]::create($url)
    [net.httpWebResponse] $response = $request.getResponse()
    $responseStream = $response.getResponseStream()
    $sr = new-object IO.StreamReader($responseStream)
    $result = $sr.ReadToEnd()
    $CommandResponse = ConvertFrom-Json $result
    $FilteredResult=$CommandResponse.data.results
    if($PassThru){
        $FilteredResult | Add-Member NoteProperty ServerConnectionString $ServerConnectionString -PassThru
    }
    else{
        Write-Output $FilteredResult
        }
}