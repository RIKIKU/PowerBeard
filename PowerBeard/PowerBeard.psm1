Function Get-PowerBeardShowInfo{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)]$tvdbid,
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)][string[]]$ServerConnectionString
            )

    Begin{
        $sysvars = Get-Variable |
        select -ExpandProperty Name
        $sysvars += 'sysvars'
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
        Get-Variable | 
        where {$sysvars -notcontains $_.Name} |
        foreach {Remove-Variable $_ -ErrorAction SilentlyContinue}
        }
}

Function Get-PowerBeardShows{
    [CmdletBinding()]
    Param (
            [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)][string[]]$ServerConnectionString
            )

    Begin{ 
            $sysvars = Get-Variable |
            select -ExpandProperty Name
            $sysvars += 'sysvars'
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
                         $output = ($PreprocessInfo.data.$($tvdbid.name)) | select -Property show_name, tvrage_name, tvdbid, tvrage_id, status, next_ep_airdate, quality, paused, network, language, air_by_date, cache
                         Write-Output $output
                        }
                }

            else{
                Write-Output $PreprocessInfo | select -Property message, result
                }
            }
        
    End{
        Get-Variable | 
        where {$sysvars -notcontains $_.Name } |
        foreach {Remove-Variable $_ -ErrorAction SilentlyContinue}
        }
}

Function Get-PowerBeardTvdbID{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)][string[]]$ServerConnectionString,
        [Parameter(Mandatory=$True)][string]$ShowName,
        [Parameter(Mandatory=$False)][switch]$PassThru
            )
    Begin{
        $sysvars = Get-Variable |
        select -ExpandProperty Name
        $sysvars += 'sysvars'
        }
    Process{
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
    End{
        Get-Variable | 
        where {$sysvars -notcontains $_.Name} |
        foreach {Remove-Variable $_ -ErrorAction SilentlyContinue}
    }

}

Function New-PowerBeardConnection {
[CmdletBinding()]
Param (
        [Parameter(Mandatory=$True)]$Server,
        [Parameter(Mandatory=$True)]$Port,
        [Parameter(Mandatory=$True)]$ApiKey,
        [Parameter(Mandatory=$false)][switch]$ssl,
        [parameter(Mandatory=$false)][switch]$TestConneciton
        )
    Begin{
        $sysvars = Get-Variable |
        select -ExpandProperty Name
        $sysvars += 'sysvars'
        }
    Process{
        if($ssl){
            [string]$urlbase = "https://$server`:$Port/api/$ApiKey/"
            # ignore certificate errors
            [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
            [System.Net.ServicePointManager]::Expect100Continue = {$true}
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::ssl3
            }
        else{
            [string]$urlbase = "http://$server`:$Port/api/$ApiKey/"
            }
        if($TestConneciton){
            $url = $urlbase + "/?cmd=sb"

        [net.httpWebRequest] $request  = [net.webRequest]::create($url)
        [net.httpWebResponse] $response = $request.getResponse()
        $responseStream = $response.getResponseStream()
        $sr = new-object IO.StreamReader($responseStream)
        $result = $sr.ReadToEnd()
        ConvertFrom-Json $result | select -Property message, result | fl
            }
        #need to output the $urlbase and be able to pipe it into another function.
        else{
            $CSS = new-object psobject -Property @{ ServerConnectionString="$urlbase"}
            Write-Output $CSS
            }
        }
    End{
        Get-Variable | 
        where {$sysvars -notcontains $_.Name} |
        foreach {Remove-Variable $_ -ErrorAction SilentlyContinue}
        }
}