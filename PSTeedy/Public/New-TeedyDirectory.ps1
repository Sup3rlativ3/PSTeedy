function New-TeedyDirectory(){
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        $AnchorTag='DirUploadTest',
        $Directory='C:\Users\dan\teedytest',
        [switch]$DontUseExistingTags,
        [switch]$OnlyCreateTags,
        [switch]$AddAllDirsAsTags,
        [switch]$ExractMSGFiles,
        $Tags
    )
    If($PSCmdlet.ShouldProcess("$FileID", "Adding a file to Teedy")) {
        if($ExractMSGFiles){
            $script:ExtractMSG=$true
        }
        if($directory[-1] -eq '\'){
            $directory = $directory.substring(0,$directory.length -1)
        }
        Update-TagHash
        if(-not($global:taghash[$AnchorTag])){
            new-tag -TagName $AnchorTag
        }
        $importbatchtag = "IMPORTBATCH-$(get-date -format yyyyMMddmmss)"
        new-tag -TagName $importbatchtag -ParentTagName $AnchorTag

        $directories = @(get-childitem -Path $directory -Directory -Recurse)
        $directories += Get-item -path $directory
        $directories = $directories|sort-object
        foreach($mydirectory in $directories){
            $specialtags=@()
            if($mydirectory.FullName -eq $directory){
                $specialtags+=$AnchorTag
            }else{
                $myparts = @(($mydirectory.fullname  -replace [regex]::escape((get-item $directory).FullName),'').substring(1) -split '\\')
                #$mydirectory.FullName
                $myparts.count
                for($i=0;$i -lt $myparts.count;$i++){
                    $myparts[$i]=$myparts[$i] -replace ' ','_' -replace ':',''
                    if(-not($global:taghash[$myparts[$i]])){
                        if($myparts[$i] -eq ''){
                            if($i -eq 0){
                                write-host "Creating Tag $($myparts[$i])"
                                new-tag -TagName $myparts[$i] -ParentTagName $AnchorTag
                            } else{
                                write-host "Creating Tag $($myparts[$i])"
                                new-tag -TagName $myparts[$i] -ParentTagName $myparts[$i-1]
                            }
                        }
                    }
                }
            }
            if(-not $OnlyCreateTags){
                if($AddAllDirsAsTags){
                    foreach($part in $myparts){
                        if($part.length -gt 36){
                            $specialtags += $part.substring(0,36) -replace ' ','_' -replace ':','_';
                        } else {
                            $specialtags += $part -replace ' ','_' -replace ':','_';
                        }
                    }
                } else {
                    if(($myparts.count -gt 0) -and ($myparts[-1].length -gt 36)){
                        $specialtags += $myparts[-1].substring(0,36) -replace ' ','_' -replace ':','_';
                    } else {
                        $specialtags += $myparts[-1] -replace ' ','_' -replace ':','_';
                    }
                }
                $files = @(get-childitem -Path $mydirectory.FullName -File | select-object -ExpandProperty FullName | sort-object )
                if($files.count -gt 0){
                    if((split-path $files[0] -parent) -eq (get-item $Directory).fullname){
                        #write-host "1"
                        #$mydirectory.FullName
                        $title = $mydirectory.Name
                        #write-host $title
                        #write-host "MainFolder"
                        $tagstoadd=@($AnchorTag,$tags,$importbatchtag)
                        New-Document -title $title -tags $tagstoadd -file $files
                    } else {
                        #write-host "2"
                        #write-host $title
                        #$mydirectory.FullName
                        $title = ($mydirectory.FullName -replace "$([Regex]::Escape($directory))","").Substring(1)
                        #write-host $title
                        #write-host "Subfolder"
                        $tagstoadd = @($tags,$importbatchtag,$specialtags)
                        New-Document -title $title -tags $tagstoadd -file $files
                    }
                }
            }
        }
    } #End of "Should Process"
}
