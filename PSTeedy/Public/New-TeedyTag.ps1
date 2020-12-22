function New-TeedyTag(){
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        $TagName,
        $ParentTagName="",
        $color="3a87ad"
    )
    If($PSCmdlet.ShouldProcess("$FileID", "Adding a file to Teedy")) {
        if($tagname.length -gt 36){
            $tagname = $tagname.substring(0,36)
        }
        try{
            if($color -eq "3a87ad"){
                $colorcode="$color"
            } else {
                $colorcode = ("{0:X}" -f [drawing.Color]::FromName($color).toargb()).Substring(2)
            }
        }catch{
            $error[0]
            write-host "Unable to determine color code. Using default blue."
            $colorcode = '3a87ad'
        }
        Update-TagHash
        try{
        if($global:taghash[$TagName]){
            return "TAG $tagname already exists."
        }
        if((-not($global:taghash[$ParentTagName])) -and ($ParentTagName -ne '') ){
            $parentTagID = (New-Tag -TagName $ParentTagName -ParentTagName '').id
        } else{
            if($ParentTagName -eq ''){
                $parentTagID=''
            } else {
                $parentTagID=$global:taghash[$ParentTagName].id
            }
        }
        $mytagtocreate = @{
            name=$TagName  -replace ' ','_' -replace ':','_';
            parent=$parentTagID;
            color="#$colorcode";
        }
        #$mytagtocreate
        $newtagid = Invoke-RestMethod -uri "$siteurl/api/tag" -Headers $headers -Method PUT -body $mytagtocreate -ContentType 'application/x-www-form-urlencoded' -WebSession $global:loginsession
        Update-TagHash
        } catch {
            $error[0]
        }
        $newtagid.idz
    }
}
