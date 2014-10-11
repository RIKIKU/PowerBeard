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