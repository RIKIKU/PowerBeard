﻿Function New-PowerBeardConnection {
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
            [string]$url += $urlbase
            [string]$url += "?cmd=sb"

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

Function New-PowerBeardCommand {
    <#
    .SYNOPSIS
        Allows for use of custom API commands and API commands not covered by the PowerBeard Module.

        
    .DESCRIPTION
        Allows a user to be able to specify any API command or a "chain" of API commands. Nearly all of the functions in the PowerBeard
        Module are built on top of this function so that should give you an idea as to how powerfull this function is.

    .PARAMETER  ServerConnectionString
        This parameter accepts pipeline input from New-PowerBeardConnection. A correctly formated URI or variable may
        be used here instead.

    .PARAMETER  ApiCMD
       specify an API command here. You can use the normal API method for stringing multiple commands together.
       
    .EXAMPLE
        $ServerConnectionString = (New-PowerBeardConnection -Server MySBServer -Port 8081 -ApiKey ab3a1537af30c8d65765081a9fa148ff)
        $ServerConnectionString | New-PowerBeardCommand -ApiCMD sb

        Output

        data                                           message                                       result                                       
        ----                                           -------                                       ------                                       
        @{api_commands=System.Object[]; api_version...                                               success 


        In this example, the API command "sb" was issued and this was the result.

    .EXAMPLE
        ($ServerConnectionString | New-PowerBeardCommand -ApiCMD sb).data.api_version
        
        Output

        4

        In this example, I have drilled down into the results of the previous example and retrieved the API version.
        
    .EXAMPLE
        ($ServerConnectionString | New-PowerBeardCommand -ApiCMD "sb.getdefaults|sb.getrootdirs|logs&min_level=error").data | FL

        Output

        logs           : @{data=System.Object[]; message=; result=success}
        sb.getdefaults : @{data=; message=; result=success}
        sb.getrootdirs : @{data=System.Object[]; message=; result=success}

        This example shows how API commands can be "chained" together. It is important to remember here that this is a function of 
        the SickBeard API and not powershell. More information on Chaining API commands can be found on the SickBeard API page.

    .EXAMPLE
        New-PowerBeardCommand -ServerConnectionString $ServerConnectionString.ServerConnectionString -ApiCMD sb

data                                           message                                       result                                       
----                                           -------                                       ------                                       
@{api_commands=System.Object[]; api_version...                                               success                                      
    
    In this example, we see how the -ServerConnectionString parameter can be used.
    
    .OUTPUTS
        This funciton outputs a Powershell Object.

    .FUNCTIONALITY
        This command allows advanced API usage.

    .LINK
        http://sickbeard.com/api
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True,ValueFromPipeline=$True)][string[]]$ServerConnectionString, [Parameter(Mandatory=$True)][string]$ApiCMD)
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

Function Get-PowerBeardShowInfo{
    <#
    .SYNOPSIS
        used to return information about a show.

        
    .DESCRIPTION
        Use this function to return information about a show by inputing its TVDBID. A list of TVDBIDs may be used.  

    .PARAMETER  ServerConnectionString
        This parameter accepts pipeline input from New-PowerBeardConnection. A correctly formated URI or variable may
        be used here instead.
    
    .PARAMETER  tvdbid
        Use this parameter to input the TVDBID, a list of TVDBIDs may be used here.
        Also accepts pipeline input from Get-PowerBeardTVDBID

    .EXAMPLE
        New-PowerBeardConnection -Server MySickBeardServer -Port 8081 -ApiKey ab31537af30c8d65765081a9fa148ff | Get-PowerBeardShowInfo -tvdbid 75897
         
        
        air_by_date     : 0
        airs            : Wednesday 10:00 PM
        cache           : @{banner=1; poster=1}
        flatten_folders : 0
        genre           : {Animation, Comedy}
        language        : en
        location        : T:\Media\TV Shows\South Park
        network         : Comedy Central
        next_ep_airdate : 2014-10-08
        paused          : 0
        quality         : HD720p
        quality_details : @{archive=System.Object[]; initial=System.Object[]}
        season_list     : {18, 17, 16, 15...}
        show_name       : South Park
        status          : Continuing
        tvrage_id       : 5266
        tvrage_name     : South Park
        tvdbid          : 75897
        result          : success

        In this example we get the show info for a show with the tvdbid of 75897

    .EXAMPLE
        New-PowerBeardConnection -Server MySickBeardServer -Port 8081 -ApiKey ab3a1537af30c8d65765081a9fa148ff | Get-PowerBeardTvdbID -ShowName "South Park" -PassThru | Get-PowerBeardShowInfo
        
        
        air_by_date     : 0
        airs            : Wednesday 10:00 PM
        cache           : @{banner=1; poster=1}
        flatten_folders : 0
        genre           : {Animation, Comedy}
        language        : en
        location        : T:\Media\TV Shows\South Park
        network         : Comedy Central
        next_ep_airdate : 2014-10-08
        paused          : 0
        quality         : HD720p
        quality_details : @{archive=System.Object[]; initial=System.Object[]}
        season_list     : {18, 17, 16, 15...}
        show_name       : South Park
        status          : Continuing
        tvrage_id       : 5266
        tvrage_name     : South Park
        tvdbid          : 75897
        result          : success

        In this example we get the TVDBID of the show, South Park, and use the Passthru switch to pass the
        ServerConnectionString and the TVDBID through to the Get-PowerBeardShowInfo function.


    .OUTPUTS
        This funciton outputs a Powershell Object.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)][int]$tvdbid,
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)][string[]]$ServerConnectionString
            )
    Begin{
        $sysvars = Get-Variable |
        select -ExpandProperty Name
        $sysvars += 'sysvars'
          }
    Process{
        <#compile the appropriate URL here.
            [string]$url += $ServerConnectionString
            [string]$url += "?cmd=show&tvdbid=$tvdbid"
            
        #send request to server and retrieve output
            [net.httpWebRequest] $request  = [net.webRequest]::create($url)
            [net.httpWebResponse] $response = $request.getResponse()
            $responseStream = $response.getResponseStream()
            $sr = new-object IO.StreamReader($responseStream)
            $result = $sr.ReadToEnd()
            $PreprocessInfo = ConvertFrom-Json $result#>
            [string]$APICMD += "show&tvdbid=$tvdbid"
            $PreprocessInfo = $ServerConnectionString | New-PowerBeardCommand -ApiCMD $APICMD
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
        <#
    .SYNOPSIS
        Returns all shows currently added to your SickBeard server.

        
    .DESCRIPTION
        Running this funciton will return a list of shows that you currently have.

    .PARAMETER  ServerConnectionString
        This parameter accepts pipeline input from New-PowerBeardConnection. A correctly formated URI or variable may
        be used here instead.

    .EXAMPLE
        New-PowerBeardConnection -Server MySickBeardServer -Port 8081 -ApiKey ab3a1537af30c8d65765081a9fa148ff | Get-PowerBeardShows

        show_name       : Stargate Universe
        tvrage_name     : Stargate Universe
        tvdbid          : 83237
        tvrage_id       : 15343
        status          : Ended
        next_ep_airdate : 
        quality         : HD720p
        paused          : 0
        network         : Syfy
        language        : en
        air_by_date     : 0
        cache           : @{banner=1; poster=1}

        show_name       : Warehouse 13
        tvrage_name     : Warehouse 13
        tvdbid          : 84676
        tvrage_id       : 7884
        status          : Ended
        next_ep_airdate : 
        quality         : HD720p
        paused          : 0
        network         : Syfy
        language        : en
        air_by_date     : 0
        cache           : @{banner=1; poster=1}

        In this example I use the function and the list of shows I have is returned.


    .OUTPUTS
        This funciton outputs a Powershell Object.

    .FUNCTIONALITY
        This function is used to return a list of shows that you currently have.

    #>

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
            [string]$url += $ServerConnectionString
            [string]$url += "?cmd=shows"
            
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
        New-PowerBeardConnection -Server MySickBeardServer -Port 8081 -ApiKey ab3a1537af30c8d65765081a9fa148ff | Get-PowerBeardTvdbID -ShowName "South Park"

        first_aired    name         tvdbid
        -----------    ----         ------
        1997-08-01     South Park    75897

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
        [string]$url += $ServerConnectionString
        [string]$url += "?cmd=sb.searchtvdb&name=$ShowName"
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