function Remove-TeedyTagById(){
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(mandatory)][string]$TagID
    )
    If($PSCmdlet.ShouldProcess("$FileID", "Adding a file to Teedy")) {
        if($global:taghash[$tagid].id){
            $result = Invoke-RestMethod -uri "$siteurl/api/tag/$tagid" -Headers $headers -Method DELETE  -WebSession $global:loginsession
            Update-TagHash
        } else {
            $result = "$tagid not found"
            #continue
        }
        $result
    }
}
