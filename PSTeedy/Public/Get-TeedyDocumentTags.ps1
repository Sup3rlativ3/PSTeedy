function Get-TeedyDocumentTags(){
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(mandatory)]$documentid
    )
    If($PSCmdlet.ShouldProcess("$FileID", "Adding a file to Teedy")) {
        Invoke-RestMethod -uri "$siteurl/api/document/$DocumentID" -Headers $headers -body @{id=$documentId} -Method GET  -WebSession $global:loginsession|select-object -ExpandProperty tags
    }
}
