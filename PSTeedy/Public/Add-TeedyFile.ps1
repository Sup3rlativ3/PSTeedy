function Add-TeedyFile(){
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$false)]
        [String[]]$DocumentID,
        [Parameter(Mandatory=$false)]
        [String[]]$FileID
    )

    #TODO: Need to restructure the IF statements so that the should process makes sense.
    If($PSCmdlet.ShouldProcess("$FileID", "Adding a file to Teedy")) {
        foreach($File in @($FileID)) {
                foreach($Document in @($DocumentID)) {
                        $ToAttach=@{
                        FileID=$File;
                        ID=$Document
                    }

                Invoke-RestMethod -uri "$siteurl/api/File/$File/attach" -Headers $headers -Method POST -Body $ToAttach -ContentType 'application/x-www-form-urlencoded'  -WebSession $global:LoginSession
            }
        }
    }
}
