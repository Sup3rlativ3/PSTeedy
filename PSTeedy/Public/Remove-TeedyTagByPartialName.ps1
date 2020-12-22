function Remove-TeedyTagByPartialName(){
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(mandatory)]$TagPartialName
    )
    If($PSCmdlet.ShouldProcess("$FileID", "Adding a file to Teedy")) {
        $tagstoremove = @($global:taghash.keys | where-object {$_ -like $tagpartialname})
        if($tagstoremove.count -eq 0){
            write-host "No tags found."
            break
        }
        foreach($tag in $tagstoremove){
            remove-tagbyid -tagid $tag
        }
    }
}
