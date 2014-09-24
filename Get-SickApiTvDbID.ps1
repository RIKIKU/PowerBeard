Function Get-SickApiTvdbID{
Param ($ShowName)

#server info needs to come in here



$url = $urlbase + "/?cmd=" + $ApiCMD

[net.httpWebRequest] $request  = [net.webRequest]::create($url)
[net.httpWebResponse] $response = $request.getResponse()
$responseStream = $response.getResponseStream()
$sr = new-object IO.StreamReader($responseStream)
$result = $sr.ReadToEnd()
ConvertFrom-Json $result


}