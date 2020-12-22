function New-TeedyDocument(){
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        $title,
        $language='eng',
        $tags,
        $file
    )
    If($PSCmdlet.ShouldProcess("$FileID", "Adding a file to Teedy")) {
        update-taghash
        $mytags=@()
        foreach($mytag in @($tags)){
            if($null -eq $mytag -or $mytag -eq ''){continue}
            try{

                if($global:taghash[$mytag]){
                    $mytags += $global:taghash[$mytag].id
                }
            } catch {
                write-host "Tag `'$mytag`' not found"
                write-host $tags
                throw
            }
        }
        #write-host "title"
        #write-host $title
        $title=[System.Web.HttpUtility]::UrlEncode($title)
        if($title.Length -lt 1){
            write-host "Title is blank. Stopping"
            throw
        }
        $basequery = "title=$title&language=$language"
        if ($tags) { $tagsquery = '&tags={0}' -f ($mytags -join '&tags=') }
        write-host $basequery
        write-host $tagsquery
        $newdocid = (Invoke-RestMethod -uri "$siteurl/api/document" -Headers $headers -Method PUT -body "$($basequery)$($tagsquery)" -ContentType 'application/x-www-form-urlencoded' -WebSession $global:loginsession).id
        if($file){
            $fileids= Add-File -Files $file
            attach-file -documentid $newdocid -fileid $fileids
        }
        $newdocid
    }
}
