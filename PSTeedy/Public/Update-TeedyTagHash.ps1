function Update-TeedyTagHash(){
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [String]$TagList
    )

    If($PSCmdlet.ShouldProcess("$FileID", "Adding a file to Teedy")) {
        $taglist = Invoke-RestMethod -uri "$siteurl/api/tag/list" -Headers $headers -Method GET  -WebSession $global:loginsession| select-object -ExpandProperty tags
        $global:taghash=@{}
        foreach($tag in $taglist){
            try{
                if($taghash[$tag.name]){
                    write-host
                    write-host @"
"ERROR: Duplicate Tag Detected."
This tag:
ID=$($tag.id)
Name=$($tag.name)
Parent=$($tag.parent)
Color=$($tag.color)

Existing Tag
ID=$($taghash[$tag.name].id)
Name=$($taghash[$tag.name].name)
Parent=$($taghash[$tag.name].parent)
Color=$($taghash[$tag.name].color)
"@
                    continue
                }
                $global:taghash.add($tag.name, @{ID=$tag.id;Name=$tag.name;Parent=$tag.parent;Color=$tag.color})
                $global:taghash.add($tag.id, @{ID=$tag.id;Name=$tag.name;Parent=$tag.parent;Color=$tag.color})
            } catch {
                Write-host $error[0]
            }
        }
    }
}
