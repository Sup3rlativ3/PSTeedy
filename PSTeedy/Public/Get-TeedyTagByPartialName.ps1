function Get-TeedyTagByPartialName(){
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(mandatory)]
        $tagPartialName
        )
    If($PSCmdlet.ShouldProcess("$FileID", "Adding a file to Teedy")) {
        Update-TagHash
        $global:taghash.keys|where-object {$_ -like $tagPartialName}
    }
}
