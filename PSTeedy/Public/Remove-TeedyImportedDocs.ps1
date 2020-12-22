function Remove-TeedyAllImportedDocs(){
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [String]$Name = "IMPORT*"
    )

    If($PSCmdlet.ShouldProcess("$FileID", "Adding a file to Teedy")) {
        get-TagByPartialName -tagPartialName $Name | foreach-object {Remove-DocumentsByTag -Tag $_ -RemoveTagWhenComplete}
    }
}
