function Remove-TeedyDocument(){
    [CmdletBinding(DefaultParameterSetName='DocumentID',SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true,ParameterSetName='DocumentID', Position=0)]
        [string]$DocumentID,
        [Parameter(Mandatory=$false,ParameterSetName='All', Position=0)]
        [switch]$All
        )
    If($PSCmdlet.ShouldProcess("$FileID", "Adding a file to Teedy")) {
        If($All)
            {
                Get-TeedyTagByPartialName -TagPartialName "IMPORT*" | foreach-object {Remove-DocumentsByTag -Tag $_ -RemoveTagWhenComplete}
            }
        elseif ($DocumentID)
            {
                Invoke-RestMethod -uri "$siteurl/api/document/$DocumentID" -Headers $headers -body @{id=$documentId} -Method DELETE  -WebSession $global:loginsession
            }
    }
}
