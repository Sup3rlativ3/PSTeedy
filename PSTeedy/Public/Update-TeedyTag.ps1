function Update-TeedyTag(){
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [parameter(Mandatory)][string]$TagName,
        [parameter()][string]$ParentTagName,
        [parameter()][string]$Color
    )
    If($PSCmdlet.ShouldProcess("$FileID", "Adding a file to Teedy")) {
        update-taghash
        if($global:taghash[$TagName]){
            $mytag = $global:taghash[$tagname]
            if($color){
                try{
                    $colorcode = ("{0:X}" -f [drawing.Color]::FromName($color).toargb() ).Substring(2)
                    $mytag.color = "#$colorcode"
                } catch{
                    $error[0]
                    write-host "Color $color not found, not changing"
                }
            }
            if($global:taghash[$ParentTagName]){
                $mytag.parent = $global:taghash[$ParentTagName].id
            }
            $tagid=$mytag.id
            $mytag
            $topost=@{
                name=$mytag.name;
                id=$mytag.id;
                parent=$mytag.parent;
                color=$mytag.Color
            }
            Invoke-RestMethod -uri "$siteurl/api/tag/$tagid" -Headers $headers -Method POST -Body $topost -ContentType 'application/x-www-form-urlencoded'  -WebSession $global:loginsession
        } else {
            write-host "$tagname not found"
        }
    }
}
