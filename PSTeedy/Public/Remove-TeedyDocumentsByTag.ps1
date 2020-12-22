function Remove-TeedyDocumentsByTag(){
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        $Tag,
        [switch]$RemoveTagWhenComplete
    )
    If($PSCmdlet.ShouldProcess("$FileID", "Adding a file to Teedy")) {
        update-taghash
        if(-not($global:taghash[$tag])){
            write-host "Tag $tag not found."
            break
        }
        $docstoremove=Invoke-RestMethod -uri "$siteurl/api/document/list" -Headers $headers -Method GET -Body @{search="tag:$Tag";limit=0 }  -WebSession $global:loginsession| select-object -ExpandProperty documents|select-object -ExpandProperty id
        foreach($document in $docstoremove){
            remove-document -DocumentID $document
        }
        if($RemoveTagWhenComplete){
            Remove-TagByName -TagName $tag
        }
    }
}
