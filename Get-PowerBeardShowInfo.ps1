Function Get-PowerBeardShowInfo{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)]$tvdbid,
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)][string[]]$ServerConnectionString
            )

    Begin{
          }
    Process{
        #compile the appropriate URL here.
            [string]$url = $ServerConnectionString + "?cmd=show&tvdbid=" + $tvdbid
            
        #send request to server and retrieve output
            [net.httpWebRequest] $request  = [net.webRequest]::create($url)
            [net.httpWebResponse] $response = $request.getResponse()
            $responseStream = $response.getResponseStream()
            $sr = new-object IO.StreamReader($responseStream)
            $result = $sr.ReadToEnd()
            $PreprocessInfo = ConvertFrom-Json $result
        #filter the output based on result message.
            if($PreprocessInfo.result -eq "success"){
                $showinfo = $PreprocessInfo.data
                Add-Member -InputObject $showinfo NoteProperty tvdbid $tvdbid -PassThru | Add-Member NoteProperty result success -PassThru
                }
            else{
                Add-Member -InputObject $PreprocessInfo NoteProperty tvdbid $tvdbid -PassThru | select -Property message, result, tvdbid
                }
            }
    End{
        }
}