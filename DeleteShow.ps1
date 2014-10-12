Function Remove-PowerBeardShow{
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
        [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$True)][string[]]$ServerConnectionString
            )
    Begin{
        $sysvars = Get-Variable |
        select -ExpandProperty Name
        $sysvars += 'sysvars'
          }
    Process{
            [string]$APICMD = "show.delete&tvdbid=$tvdbid"
            $PreprocessInfo = $ServerConnectionString | New-PowerBeardCommand -ApiCMD $APICMD
        #filter the output based on result message.
            Write-Output $PreprocessInfo
            }
    End{
        Get-Variable | 
        where {$sysvars -notcontains $_.Name} |
        foreach {Remove-Variable $_ -ErrorAction SilentlyContinue}
        }
}