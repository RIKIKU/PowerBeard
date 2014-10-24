Function Get-PowerBeardShowStats{
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

Function Get-PowerBeardShowSeasons{
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

Function Get-PowerBeardShowQuality{
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

Function Get-PowerBeardShowCache{
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
