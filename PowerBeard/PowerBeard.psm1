Function New-Connection {
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

Function New-Command {
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

Function Get-ShowInfo{
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
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)][int[]]$tvdbid,
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
            [string]$APICMD = "show&tvdbid=$tvdbid"
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

Function Get-Shows{
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

    .EXAMPLE
        $ServerConnectionString | Get-PowerBeardShows -Sort Name | ft

show_name     tvrage_name          tvdbid     tvrage_id status        next_ep_airda quality    paused network       language    
                                                                      te                                                                  
---------     -----------          ------     --------- ------        ------------- -------    ------ -------       --------    
A Young Do...                      263828             0 Continuing                  HD720p          0 Sky Arts      en          
Adventure ... Adventure ...        152831         23369 Continuing    2014-10-28    Custom          0 Cartoon Ne... en          
Archer (2009) Archer (2009)        110381         23354 Continuing                  HD720p          0 FX            en          
Arrow         Arrow                257655         30715 Continuing    2014-10-15    Custom          0 The CW        en          
Avatar: Th... Avatar: Th...         74852          2680 Ended                       HD720p          0 Nickelodeon   en          
Blue Mount... Blue Mount...        134511         22667 Ended                       HD720p          0 Spike TV      en          
Breaking Bad  Breaking Bad          81189         18164 Ended                       HD720p          0 AMC           en 

    In this example the server returned the shows in name order.
    .EXAMPLE
       $ServerConnectionString | Get-PowerBeardShows name Paused


show_name       : Lost Girl
tvrage_name     : Lost Girl
tvdbid          : 182061
tvrage_id       : 26401
status          : Continuing
next_ep_airdate : 2014-12-07
quality         : HD720p
paused          : 1
network         : Showcase
language        : en
air_by_date     : 0
cache           : @{banner=1; poster=1}

In this example only the paused shows are returned.

    .OUTPUTS
        This funciton outputs a Powershell Object.

    .FUNCTIONALITY
        This function is used to return a list of shows that you currently have.

    #>
    [CmdletBinding()]
    Param (
            [parameter(Mandatory=$False, Position=1)][ValidateSet("ID", "Name")]$Sort,
            [parameter(Mandatory=$False, Position=2)][ValidateSet("UnPaused","Paused")]$paused,
            [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True, Position=3)][string[]]$ServerConnectionString
            )
    Begin{ 
            $sysvars = Get-Variable |
            select -ExpandProperty Name
            $sysvars += 'sysvars'
          }
    Process{
            [string]$APICMD = "shows"
            if($Sort -eq "ID"){
                [string]$APICMD += "&sort=id"
                }
            elseif($sort -eq "Name"){
                [string]$APICMD += "&sort=name"
                }
            if($paused -eq "Paused" ){
                [string]$APICMD += "&paused=1"
                }
            elseif($paused -eq "UnPaused"){
                [string]$APICMD += "&paused=0"
                }

            #send request to server and retrieve output
            $PreprocessInfo = $ServerConnectionString | New-PowerBeardCommand -ApiCMD $APICMD
            if($PreprocessInfo.result -eq "success"){
                [array]$shows = $PreprocessInfo.data
                $tvdbids = ($shows | Get-Member -MemberType NoteProperty | select -Property Name)
                foreach ($tvdbid in $tvdbids){
                         $output = ($PreprocessInfo.data.$($tvdbid.name)) | select -Property show_name, tvrage_name, tvdbid, tvrage_id, status, next_ep_airdate, quality, paused, network, language, air_by_date, cache
                         Write-Output $output
                        }
                }

            else{
                Write-Output $PreprocessInfo | select -Property message, result, data
                }
            }
    End{
        Get-Variable | 
        where {$sysvars -notcontains $_.Name } |
        foreach {Remove-Variable $_ -ErrorAction SilentlyContinue}
        }
}

Function Get-TvdbID{
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
        [string]$APICMD = "sb.searchtvdb&name=$ShowName"
        $PreprocessInfo = $ServerConnectionString | New-PowerBeardCommand -ApiCMD $APICMD
        
        #send request to server and retrieve output
        if($PreprocessInfo.result -eq "success"){
        
            $FilteredResult=$PreprocessInfo.data.results
            if($PassThru){
                $FilteredResult | Add-Member NoteProperty ServerConnectionString $ServerConnectionString -PassThru
            }
            else{
                Write-Output $FilteredResult
                }
            }
        else{
            Write-Output $PreprocessInfo
            }
    }
    End{
        Get-Variable | 
        where {$sysvars -notcontains $_.Name} |
        foreach {Remove-Variable $_ -ErrorAction SilentlyContinue}
    }

}

Function Get-ShowStats{
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
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)][int[]]$tvdbid,
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)][string[]]$ServerConnectionString
            )
    Begin{
        $sysvars = Get-Variable |
        select -ExpandProperty Name
        $sysvars += 'sysvars'
          }
    Process{
            [string]$APICMD = "show.stats&tvdbid=$tvdbid"
            $PreprocessInfo = $ServerConnectionString | New-PowerBeardCommand -ApiCMD $APICMD
        #filter the output based on result message.
            if($PreprocessInfo.result -eq "success"){
                Write-Output $PreprocessInfo.data
                }
            else{
                Write-Output $PreprocessInfo
                }
            }
    End{
        Get-Variable | 
        where {$sysvars -notcontains $_.Name} |
        foreach {Remove-Variable $_ -ErrorAction SilentlyContinue}
        }
}

Function Get-ShowSeasons{
    <#
    .SYNOPSIS
        used to return a list of all seasons and episodes.

        
    .DESCRIPTION
        Use this function to return a list of each season and each episode in each season. If the season parameter is 
        defined then only the episodes for that season are returned.  

    .PARAMETER  ServerConnectionString
        This parameter accepts pipeline input from New-PowerBeardConnection. A correctly formated URI or variable may
        be used here instead.
    
    .PARAMETER  tvdbid
        Specify the TVDBID of the show that you want to get the seasons for.

    .EXAMPLE
        New-PowerBeardConnection -Server MySickBeardServer -Port 8081 -ApiKey ab31537af30c8d65765081a9fa148ff | Get-PowerBeardShowSeasons -tvdbid 75897 | fl
         
Episode Name                   Quality                Airdate                                Season Status
------- ----                   -------                -------                                ------ ------
1 Cartman Gets An Ana...       N/A                                                                0 Skipped
2 The Spirit Of Chris...       N/A                    1992-12-14                                  0 Skipped
3 The Spirit Of Chris...       N/A                    1995-12-25                                  0 Skipped
4 Jay Leno Comes To S...       N/A                    1997-11-20                                  0 Skipped
5 Chef Aid: Behind Th...       N/A                    1998-10-07                                  0 Skipped
6 South Park: Bigger ...       N/A                    1999-06-30                                  0 Skipped

        

        In this example the TVDBID was supplied and the result was piped into the FormatList cmdlet. I have truncated the list to make it shorter.


    .OUTPUTS
        This funciton outputs a Powershell arra Object.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)][int[]]$tvdbid,
        [Parameter(Mandatory=$false)][int]$Season = 1010101010,
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)][string[]]$ServerConnectionString
            )
    Begin{
        $sysvars = Get-Variable |
        select -ExpandProperty Name
        $sysvars += 'sysvars'
          }
    Process{
            [string]$APICMD = "show.seasons&tvdbid=$tvdbid"
            if($Season -ne "1010101010"){
                [string]$APICMD += "&season=$Season"}
            $PreprocessInfo = $ServerConnectionString | New-PowerBeardCommand -ApiCMD $APICMD
        #filter the output based on result message.
            if($PreprocessInfo.result -eq "success"){
                $RawData = $PreprocessInfo.data
                $OutputArray = @()
                
                if($Season -ne "1010101010"){
                        #Loop through each episode
                        $EpisodeNos = Get-Member -InputObject $PreprocessInfo.data -MemberType NoteProperty
                        foreach($EpisodeNo in $EpisodeNos.Name){
                            $SeasonTable = New-Object psobject -Property @{
                                Season  = [int]$Season
                                Episode = [int]$EpisodeNo
                                Airdate = ($RawData.$($EpisodeNo)).Airdate
                                Name    = ($RawData.$($EpisodeNo)).Name
                                Quality = ($RawData.$($EpisodeNo)).Quality
                                Status  = ($RawData.$($EpisodeNo)).Status
                                }
                            $OutputArray += $SeasonTable
                            }
                        Write-Output $OutputArray | Sort-Object -property @{Expression="Season";Descending=$false}, @{Expression="Episode";Descending=$false}
                    }
                else{
                    #loop through each season here
                    $SeasonNos = Get-Member -InputObject $PreprocessInfo.data -MemberType NoteProperty
                    foreach ($SeasonNo in $SeasonNos.Name){
                        $SeasonMicro = $RawData.$($SeasonNo)
                        
                        #Loop through each episode in each season here
                        $EpisodeNos = Get-Member -InputObject ($PreprocessInfo.data).$($SeasonNo) -MemberType NoteProperty
                        foreach($EpisodeNo in $EpisodeNos.Name){
                            $SeasonTable = New-Object psobject -Property @{
                                Season  = [int]$SeasonNo
                                Episode = [int]$EpisodeNo
                                Airdate = ($SeasonMicro.$($EpisodeNo)).Airdate
                                Name    = ($SeasonMicro.$($EpisodeNo)).Name
                                Quality = ($SeasonMicro.$($EpisodeNo)).Quality
                                Status  = ($SeasonMicro.$($EpisodeNo)).Status
                                }
                            $OutputArray += $SeasonTable
                            }
                    }
                    Write-Output $OutputArray | Sort-Object -property @{Expression="Season";Descending=$false}, @{Expression="Episode";Descending=$false}
                    }
                }
            else{
                Write-Output $PreprocessInfo
                }
            }
    End{
        Get-Variable | 
        where {$sysvars -notcontains $_.Name} |
        foreach {Remove-Variable $_ -ErrorAction SilentlyContinue}
        }
}

Function Get-ShowQuality{
    <#
    .SYNOPSIS
        used to return quality settings for a show.

        
    .DESCRIPTION
        Use this function is used to return the Initial and Archive settings of a show.  

    .PARAMETER  ServerConnectionString
        This parameter accepts pipeline input from New-PowerBeardConnection. A correctly formated URI or variable may
        be used here instead.
    
    .PARAMETER  tvdbid
        Use this parameter to input the TVDBID, a list of TVDBIDs may be used here.
        Also accepts pipeline input from Get-PowerBeardTVDBID

    .EXAMPLE
        New-PowerBeardConnection -Server MySickBeardServer -Port 8081 -ApiKey ab31537af30c8d65765081a9fa148ff |  Get-PowerBeardShowQuality -tvdbid 75897

archive                                                               initial                                                             
-------                                                               -------                                                             
{}                                                                    {hdtv, hdwebdl, hdbluray}
       
In this example, the TVDBID is provided.
    .EXAMPLE
        $ServerConnectionString | Get-PowerBeardTvdbID -ShowName "South Park" -PassThru | Get-PowerBeardShowQuality

archive                                                               initial                                                             
-------                                                               -------                                                             
{}                                                                    {hdtv, hdwebdl, hdbluray}


In this example, Get-PowerBeardTvdbID is piped into Get-PowerBeardShowQuality

    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)][int[]]$tvdbid,
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)][string[]]$ServerConnectionString
            )
    Begin{
        $sysvars = Get-Variable |
        select -ExpandProperty Name
        $sysvars += 'sysvars'
          }
    Process{
            [string]$APICMD = "show.getquality&tvdbid=$tvdbid"
            $PreprocessInfo = $ServerConnectionString | New-PowerBeardCommand -ApiCMD $APICMD
        #filter the output based on result message.
            if($PreprocessInfo.result -eq "success"){
                Write-Output $PreprocessInfo.data
                }
            else{
                Write-Output $PreprocessInfo
                }
            }
    End{
        Get-Variable | 
        where {$sysvars -notcontains $_.Name} |
        foreach {Remove-Variable $_ -ErrorAction SilentlyContinue}
        }
}

Function Get-ShowCache{

    <#
    .SYNOPSIS
        Returns if the poster/banner SickBeard's image cache is valid.

    .DESCRIPTION
        Use this function to find out if SickBeard's image cache is valid for a particular tvdbid.  

    .PARAMETER  ServerConnectionString
        This parameter accepts pipeline input from New-PowerBeardConnection. A correctly formated URI or variable may
        be used here instead.
    
    .PARAMETER  tvdbid
        Use this parameter to input the TVDBID, a list of TVDBIDs may be used here.
        Also accepts pipeline input from Get-PowerBeardTVDBID

    .EXAMPLE
 $ServerConnectionString | Get-PowerBeardTvdbID -ShowName "South Park" -PassThru | Get-PowerBeardShowCache

Banner     Poster
------     ------
True       True




    .OUTPUTS
        This funciton outputs a Powershell Object.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)][int[]]$tvdbid,
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)][string[]]$ServerConnectionString
            )
    Begin{
        $sysvars = Get-Variable |
        select -ExpandProperty Name
        $sysvars += 'sysvars'
          }
    Process{
            [string]$APICMD = "show.cache&tvdbid=$tvdbid"
            $PreprocessInfo = $ServerConnectionString | New-PowerBeardCommand -ApiCMD $APICMD
        #filter the output based on result message.
            if($PreprocessInfo.result -eq "success"){
                $Output = New-Object psobject -Property @{ 
                    Poster = [System.Convert]::ToBoolean($PreprocessInfo.data.Poster)
                    Banner = [System.Convert]::ToBoolean($PreprocessInfo.data.Banner)
                    }
                    Write-Output $Output
                }
            else{
                Write-Output $PreprocessInfo
                }
            }
    End{
        Get-Variable | 
        where {$sysvars -notcontains $_.Name} |
        foreach {Remove-Variable $_ -ErrorAction SilentlyContinue}
        }
}

Function Search-Tvdb{
    <#
    .SYNOPSIS
        Allows a user to search for a ShowName or TVDBID in TVDB

        
    .DESCRIPTION
        This Function searches for either a show, or a TVDBID in TVDB. it also allows the user to return results based
        on the language. Results will be returned regardless of if you have the show in Sick Beard or not.

    .PARAMETER  ServerConnectionString
        This parameter accepts pipeline input from New-PowerBeardConnection. A correctly formated URI or variable may
        be used here instead.

    .PARAMETER  ShowName
       Enter the name of the show you are looking for here.
       
    .PARAMETER  Lang
       Use this parameter to specify the language of the show you are looking for. Note that some shows are released
       with more than one language, but SickBeard will only return the show details of the language specified. 
       If no language is specified, SickBeard will default to English.

    .PARAMETER TVDBID
        If the TVDBID is known, you may specify it here. This can be used in conjunction with or instead of -ShowName

    .EXAMPLE
         $ServerConnectionString | Search-PowerBeardTvdb -Lang ja -TVDBID 262392

        langid results                                                             
        ------ -------                                                             
            25 {@{first_aired=1999-11-26; name=Samurai - Hunt For The Sword; tvd...
        
        In this example, the TDVBID and -Lang were used to return the above result.
    .EXAMPLE
         ($ServerConnectionString | Search-PowerBeardTvdb -Lang ja -TVDBID 262392).results
        first_aired      name                               tvdbid
        -----------      ----                               ------
        1999-11-26       Samurai - Hunt For The Sword       262392

        In this example, we have used exactly the same command as before, though this time we have specified that
        we just want the values stored in "results"

    .EXAMPLE
        ($ServerConnectionString | Search-PowerBeardTvdb "Samurai").results

        first_aired     name                                           tvdbid
        -----------     ----                                           ------
        2010-09-03      Samurai Girls                                  186911
        1993-08-28      Power Rangers                                   72553
        1999-11-26      Samurai - Hunt For The Sword                   262392
        2001-07-30      Samurai Girl Real Bout High School              79781
        2012-04-06      Sengoku Collection                             257557
        2014-07-02      Bakumatsu Rock                                 279555
        2000-07-18      Rurouni Kenshin                                 70863
        1962-10-07      The Samurai (1962)                             230841
        1994-09-01      Superhuman Samurai Syber-Squad                  77000
        2011-10-01      Majikoi - Oh! Samurai Girls!                   252343

        In this example, I searched for the a show name that conains "Samurai". SickBeard seems to only return the top 10. 

    .OUTPUTS
        This funciton outputs a Powershell Object.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)][string[]]$ServerConnectionString,
        [Parameter(Mandatory=$False,Position = 0)][string]$ShowName,
        [Parameter(Mandatory=$False)][ValidateSet("en", "zh", "hr", "cs", "da", "nl", "fi", "fr", "de", "el",`
         "he", "hu", "it", "ja", "ko", "no", "pl", "pt", "ru", "sl", "es", "sv", "tr")][String[]]$Lang,
        [Parameter(Mandatory=$False)][int]$TVDBID
        
        )
    Begin{
        $sysvars = Get-Variable |
        select -ExpandProperty Name
        $sysvars += 'sysvars'
        }
    Process{
        #compile the appropriate URL here.
        [string]$APICMD = "sb.searchtvdb"
        
        if($ShowName -or $TVDBID){
            if($ShowName){
                [string]$APICMD += "&name=$ShowName"
                }
            if($Lang){
                [string]$APICMD += "&lang=$Lang"
                }
            if($TVDBID){
                [string]$APICMD += "&tvdbid=$TVDBID"
                }
            $PreprocessInfo = $ServerConnectionString | New-PowerBeardCommand -ApiCMD $APICMD
            if($PreprocessInfo.result -eq "success"){
                $FilteredResult=$PreprocessInfo.data
                Write-Output $FilteredResult
                }
            Else{
                Write-Output $PreprocessInfo
                }
            }
        else{
            Throw "You must provide either the TVDBID or ShowName"
            }
        }
    End{
        Get-Variable | 
        where {$sysvars -notcontains $_.Name} |
        foreach {Remove-Variable $_ -ErrorAction SilentlyContinue}
    }

}

Function Remove-Show{
    <#
    .SYNOPSIS
        Used to delete a show from SickBeard.

        
    .DESCRIPTION
        This funciton deletes shows from SickBeard when you provide the TVDBID.  

    .PARAMETER  ServerConnectionString
        This parameter accepts pipeline input from New-PowerBeardConnection. A correctly formated URI or variable may
        be used here instead.
    
    .PARAMETER  tvdbid
        Supply the DVDBID of the show you wish to delete.
    .PARAMETER Confirm
        If this switch is used then the user will be asked to confirm that they are sure they want to delete the show.

    .EXAMPLE
        New-PowerBeardConnection -Server MySickBeardServer -Port 8081 -ApiKey ab31537af30c8d65765081a9fa148ff | Remove-PowerBeardShow 81189

data                                           message                                       result                                       
----                                           -------                                       ------                                       
                                               Breaking Bad has been deleted                 success

In this example; the show "Breaking Bad" was deleted.

    .EXAMPLE
        $ServerConnectionString = (New-PowerBeardConnection -Server localhost -Port 8081 -ApiKey 8ba833c4eddf362f567c4f64b637402e)
        $ServerConnectionString | Get-PowerBeardShows | export-csv C:\Users\kyles_000\Documents\PBTest.csv


$test = import-csv C:\Users\kyles_000\Documents\PBTest.csv
foreach($tvdbid in $test.tvdbid){ 
$ServerConnectionString | Remove-PowerBeardShow $tvdbid}

message                                       result                                       
-------                                       ------                                       
Archer (2009) has been deleted                success                                      
Game of Thrones has been deleted              success                                      
Spartacus has been deleted                    success                                      
Blue Mountain State has been deleted          success

In this example, a csv file was created that contained all of the shows that I currently have.(ran seperatly)
I then removed the shows that I didnt want to delete, from the CSV file and imported it into a variable, where I created
a loop to delete each show in the list.


    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True,Position=1)][int[]]$tvdbid,
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)][string[]]$ServerConnectionString,
        [Parameter(Mandatory=$False)][switch]$Confirm
            )
    Begin{
        $sysvars = Get-Variable |
        select -ExpandProperty Name
        $sysvars += 'sysvars'
          }
    Process{
        If($Confirm){
            $title = "Confirm Delete"
            $message = "Are you sure that you want to delete $($tvdbid)?"
            $Y = New-Object System.Management.Automation.Host.ChoiceDescription "Yes"
            $N = New-Object System.Management.Automation.Host.ChoiceDescription "No"
            $options = [System.Management.Automation.Host.ChoiceDescription[]]($Y, $N)
            $SiteOrService = $host.ui.PromptForChoice($title, $message, $options, 1) 
            if ($SiteOrService -eq 0){
                [string]$APICMD = "show.delete&tvdbid=$tvdbid"
                $PreprocessInfo = $ServerConnectionString | New-PowerBeardCommand -ApiCMD $APICMD
                #filter the output based on result message.
                Write-Output $PreprocessInfo
                }
            else{
                Write-Output "Operation Canceled"
                }
            }
        Else{
            [string]$APICMD = "show.delete&tvdbid=$tvdbid"
            $PreprocessInfo = $ServerConnectionString | New-PowerBeardCommand -ApiCMD $APICMD
            #filter the output based on result message.
            Write-Output $PreprocessInfo
            }
        }
    End{
        Get-Variable | 
        where {$sysvars -notcontains $_.Name} |
        foreach {Remove-Variable $_ -ErrorAction SilentlyContinue}
        }
}

Function Restart-Service{
    <#
    .SYNOPSIS
        Used to restart SickBeard.

        
    .DESCRIPTION
        This funciton restarts the sickbeard server.  

    .PARAMETER  ServerConnectionString
        This parameter accepts pipeline input from New-PowerBeardConnection. A correctly formated URI or variable may
        be used here instead.

    .EXAMPLE
        New-PowerBeardConnection -Server MySickBeardServer -Port 8081 -ApiKey ab31537af30c8d65765081a9fa148ff | Restart-PowerBeardService

data                                           message                                       result                                       
----                                           -------                                       ------                                       
                                               Breaking Bad has been deleted                 success

In this example; the show "Breaking Bad" was deleted.

    .EXAMPLE
        $ServerConnectionString = (New-PowerBeardConnection -Server localhost -Port 8081 -ApiKey 8ba833c4eddf362f567c4f64b637402e)
        $ServerConnectionString | Get-PowerBeardShows | export-csv C:\Users\kyles_000\Documents\PBTest.csv


$test = import-csv C:\Users\kyles_000\Documents\PBTest.csv
foreach($tvdbid in $test.tvdbid){ 
$ServerConnectionString | Remove-PowerBeardShow $tvdbid}

message                                       result                                       
-------                                       ------                                       
Archer (2009) has been deleted                success                                      
Game of Thrones has been deleted              success                                      
Spartacus has been deleted                    success                                      
Blue Mountain State has been deleted          success

In this example, a csv file was created that contained all of the shows that I currently have.(ran seperatly)
I then removed the shows that I didnt want to delete, from the CSV file and imported it into a variable, where I created
a loop to delete each show in the list.


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
        [string]$APICMD = "sb.restart"
        $PreprocessInfo = $ServerConnectionString | New-PowerBeardCommand -ApiCMD $APICMD
        Write-Output $PreprocessInfo
        }
    End{
        Get-Variable | 
        where {$sysvars -notcontains $_.Name} |
        foreach {Remove-Variable $_ -ErrorAction SilentlyContinue}
        }
}