function Get-TeedyDocumentByTag(){
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(mandatory)]$Tag
        )

    If($PSCmdlet.ShouldProcess("$Tag", "Getting documents")) {
        update-Taghash
        if(-not($global:Taghash[$Tag])){
            write-host "Tag $Tag not found."
            break
        }
        $DocumentList=Invoke-RestMethod -uri "$siteurl/api/document/list" -Headers $headers -Method GET -Body @{search="Tag:$Tag";limit=0 }  -WebSession $global:loginsession| select-object -ExpandProperty documents|select-object -ExpandProperty id
        $DocumentList
    }
}
