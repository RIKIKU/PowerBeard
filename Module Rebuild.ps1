Function Search-PowerBeardTvdb{
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
        [Parameter(Mandatory=$False,Position = 0)][string]$ShowName,
        [Parameter(Mandatory=$False)][ValidateSet("en", "zh", "hr", "cs", "da", "nl", "fi", "fr", "de", "el",`
         "he", "hu", "it", "ja", "ko", "no", "pl", "pt", "ru", "sl", "es", "sv", "tr")][String]$Lang,
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
            $FilteredResult=$PreprocessInfo.data
            Write-Output $FilteredResult
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