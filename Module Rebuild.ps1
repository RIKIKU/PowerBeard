Function Search-PowerBeardTvdb{
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