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
                $PreprocessInfo.data
                }
            else{
                $PreprocessInfo
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
        [Parameter(Mandatory=$false)][int]$Season,
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)][string[]]$ServerConnectionString
            )
    Begin{
        $sysvars = Get-Variable |
        select -ExpandProperty Name
        $sysvars += 'sysvars'
          }
    Process{
            [string]$APICMD = "show.seasons&tvdbid=$tvdbid"
            if($Season){
                [string]$APICMD += "&season=$Season"}
            $PreprocessInfo = $ServerConnectionString | New-PowerBeardCommand -ApiCMD $APICMD
        #filter the output based on result message.
            if($PreprocessInfo.result -eq "success"){
                $RawData = $PreprocessInfo.data
                $OutputArray = @()
                
                if($Season){
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
                $PreprocessInfo
                }
            }
    End{
        Get-Variable | 
        where {$sysvars -notcontains $_.Name} |
        foreach {Remove-Variable $_ -ErrorAction SilentlyContinue}
        }
}