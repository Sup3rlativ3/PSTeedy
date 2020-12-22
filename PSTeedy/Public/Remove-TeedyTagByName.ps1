function Remove-TeedyTagByName(){
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(mandatory)][string]$TagName
    )
    If($PSCmdlet.ShouldProcess("$FileID", "Adding a file to Teedy")) {
        $tagid = $global:taghash[$tagname].id
        if($tagid){
            $result = Invoke-RestMethod -uri "$siteurl/api/tag/$tagid" -Headers $headers -Method DELETE  -WebSession $global:loginsession
            Update-TagHash
        } else {
            $result = "$tagname not found"
            #continue
        }
        $result
    }
}
