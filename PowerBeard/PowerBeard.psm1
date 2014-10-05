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
    <#
    .SYNOPSIS
        When a show name is entered the TVDBID of that show is returned.

        
    .DESCRIPTION
        This funciton searches for a showname and returns the tvdbid of those shows. Wild cards can be used.
        This function may retrun many TVDBIDs.

    .PARAMETER  ServerConnectionString
        This parameter accepts pipeline input from New-PowerBeardConnection. A correctly formated URI or variable may
        be used here instead.

    .PARAMETER  ShowName
       Enter the name of the show you are looking for here.
       
    .PARAMETER  PassThru
       Use this switch if you want to pass the ServerConnectionString through to the pipeline.


    .EXAMPLE
        New-PowerBeardConnection -Server MySickBeardServer -Port 8081 -ApiKey ab3a1537af30c8d65765081a9fa148ff |
        Get-PowerBeardTvdbID -ShowName "South Park"

        In this example, we are looking for the show "South Park" and the TVDBID is returned.


    .OUTPUTS
        This funciton outputs a Powershell Object.

    .FUNCTIONALITY
        This function is used to retrieve the TVDBID of any show.

    #>
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
<#
    .SYNOPSIS
        Generates the ServerConnectionString which is required for many other PowerBeard Functions

        
    .DESCRIPTION
        Helps a user generate a correctly formatted URL string by asking for a set of
        parameters and passing the info to the pipeline. This funciton can also be used
        to test the supplied connection info and return a success or error message.

    .PARAMETER  Server
        Specify the Hostname of the server that you want to connect to.

    .PARAMETER  Port
       Specify the port number of the server.
       
    .PARAMETER  ApiKey
       Specify the API Key. You can get this information or generate a new API key in
       the settins on the SickBeard web interface.

    .PARAMETER  ssl
       Use this switch if you are connecting to a server that uses SSL.

    .PARAMETER  TestConneciton
       Use this switch if you want to test the connection settings you just entered.


    .EXAMPLE
        New-PowerBeardConnection -Server MySBServer -Port 8081 -ApiKey ab3a1537af30c8d65765081a9fa148ff

        Output
        
        ServerConnectionString                                                                                                                    
        ----------------------                                                                                                                    
        http://MySBServer:8081/api/ab3a1537af30c8d65765081a9fa148ff/

        In this example, the server connection string object is generated based on what was entered in the
        required parameters.

    .EXAMPLE
        New-PowerBeardConnection -Server MySBServer -Port 8081 -ApiKey ab3a1537af30c8d65765081a9fa148ff -ssl

        Output
        
        ServerConnectionString                                                                                                                    
        ----------------------                                                                                                                    
        https://MySBServer:8081/api/ab3a1537af30c8d65765081a9fa148ff/

        In this example, the connection info is the same as example 1, however, the ssl switch is used so the
        protocol used is https instead of http.

        
    .EXAMPLE
        New-PowerBeardConnection -Server MySBServer -Port 8081 -ApiKey ab3a1537af30c8d65765081a9fa148ff -TestConneciton

        Output
        

        message : 
        result  : success

        In this example, the test connection switch is used and as you can see the connection result is a success.
        If it were to fail, the result would be "error" and there would be a message displayed as to what the error is.


    .OUTPUTS
        This funciton outputs a Powershell Object.

    .FUNCTIONALITY
        This command is intended as a precurser to any PowerBeard function.

#>

[CmdletBinding()]
Param (
        [Parameter(Mandatory=$True)][string]$Server,
        [Parameter(Mandatory=$True)][int]$Port,
        [Parameter(Mandatory=$True)][string]$ApiKey,
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
            $url = $urlbase + "?cmd=sb"

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