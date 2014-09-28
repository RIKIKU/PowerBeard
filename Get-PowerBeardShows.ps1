Function Get-PowerBeardShows{
    [CmdletBinding()]
    Param (
            [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)][string[]]$ServerConnectionString
            )

    Begin{
          }
    Process{
        #compile the appropriate URL here.
            [string]$url = $ServerConnectionString + "?cmd=shows"
            
        #send request to server and retrieve output
            [net.httpWebRequest] $request  = [net.webRequest]::create($url)
            [net.httpWebResponse] $response = $request.getResponse()
            $responseStream = $response.getResponseStream()
            $sr = new-object IO.StreamReader($responseStream)
            $result = $sr.ReadToEnd()
            $PreprocessInfo = ConvertFrom-Json $result
            
            if($PreprocessInfo.result -eq "success"){
                [array]$shows = $PreprocessInfo.data
                $tvdbids = ($shows | Get-Member | Where-Object -Property Name -NotMatch 'a|e|i|o|u' | select -Property Name)
                foreach ($tvdbid in $tvdbids){
                         $output = ($PreprocessInfo.data."$tvdbid.name")
                         Write-Output $output
                        }
                }
                #Add-Member -InputObject $showinfo NoteProperty tvdbid $tvdbid -PassThru | Add-Member NoteProperty result success -PassThru |Add-Member NoteProperty tvdbid
            else{
                write-host "else occurred"
                #Add-Member -InputObject $PreprocessInfo NoteProperty tvdbid $tvdbid -PassThru | select -Property message, result, tvdbid
                }
            }
        
    End{
        }
}