function get-sitelogin(){
    param(
        $username='demo',
        $Password='password',
        $URL='https://demo.teedy.io'
    )
    $global:siteurl=$URL
    $tologin=@{username="$username";password="$password";}
    try{
        $loginresponse = Invoke-webrequest -Uri "$siteurl/api/user/login" -Method POST -Body $tologin -SessionVariable Session
    } catch {
        if(($error[0].ErrorDetails.Message|convertfrom-json|select-object -ExpandProperty Type) -eq 'ValidationCodeRequired'){
            $mfacode = read-host "MFA Code Required for user. Please enter MFA Code:"
            if($mfacode -match '\d{6}'){
                $tologin.add('code',$mfacode)
                $loginresponse = Invoke-webrequest -Uri "$siteurl/api/user/login" -Method POST -Body $tologin -SessionVariable Session
            }
        }
    }
    if($loginresponse.baseresponse.StatusCode -eq 200){
        write-host "Logged in successfully"
    }
    $global:loginsession = $session
    $headercookie = ($loginresponse|select-object -ExpandProperty Headers)["Set-Cookie"]
    $token,$null = $headercookie -split ";"
    $headers=@{
        Cookie = "$token"
    }
    return $headers
}
function New-Tag(){
    param(
        $TagName,
        $ParentTagName="",
        $color="3a87ad"
    )
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
function Remove-TagByName(){
    param(
        [parameter(mandatory)][string]$TagName
    )
    $tagid = $global:taghash[$tagname].id
    if($tagid){
        $result = Invoke-RestMethod -uri "$siteurl/api/tag/$tagid" -Headers $headers -Method DELETE  -WebSession $global:loginsession
        Update-TagHash
    } else {
        $result = "$tagname not found" 
        #continue
    }   
    $result
}
function Remove-TagById(){
    param(
        [parameter(mandatory)][string]$TagID
    )
    if($global:taghash[$tagid].id){
        $result = Invoke-RestMethod -uri "$siteurl/api/tag/$tagid" -Headers $headers -Method DELETE  -WebSession $global:loginsession
        Update-TagHash
    } else {
        $result = "$tagid not found" 
        #continue
    } 
    $result
}
function update-tag(){
    param(
        [parameter(Mandatory)][string]$TagName,
        [parameter()][string]$ParentTagName,
        [parameter()][string]$Color
    )
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
function Update-TagHash(){
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
function Attach-File(){
    param(
        $documentID,
        $fileID
    )
    foreach($file in @($fileID)){
        foreach($document in @($documentID)){
            $toattach=@{
                fileID=$file;
                id=$document
            }
            Invoke-RestMethod -uri "$siteurl/api/file/$file/attach" -Headers $headers -Method POST -Body $toattach -ContentType 'application/x-www-form-urlencoded'  -WebSession $global:loginsession
        }
    }
}
function New-Document(){
    param(
        $title,
        $language='eng',
        $tags,
        $file
    )
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
Function Add-File(){
    param(
        $Files
    )
    $fileids = @()
    foreach($file in $files){
        if(test-path $file){
            #upload the adamn file
            $toupload =   get-item $file
            $fileids += (Invoke-RestMethod -uri "$siteurl/api/file" -Headers $headers -Method PUT -form @{file=$toupload} -ContentType "multipart/form-data"  -WebSession $global:loginsession).id
            write-host $script:ExtractMSG
            if($script:ExtractMSG -eq $true){
                if($toupload.extension -eq '.msg'){
                    #get data to a text file
                    $msgdatafilepath="$($toupload.FullName).txt"
                    if(-not(test-path "$msgdatafilepath")){
                        try{
                            copy-item $toupload.FullName -Destination "$($env:TEMP)\$($toupload.name)"
                            $Outlook = New-Object -ComObject Outlook.Application
                            $Message = $Outlook.Session.OpenSharedItem("$($env:TEMP)\$($toupload.name)")
                            $message | select-object receivedtime, Senton, cc, To, SUbject, Body | set-content $msgdatafilepath
                            $message.close(1)
                            $Message=$null
                            remove-item "$($env:TEMP)\$($toupload.name)"
                        }catch{
                            write-host "had an issue with the file"
                            write-host $error[0]
                            "$($env:TEMP)\$($toupload.name)"
                        }
                        #start-sleep -seconds .1
                        $msgdatafile = get-item $msgdatafilepath
                        $fileids += (Invoke-RestMethod -uri "$siteurl/api/file" -Headers $headers -Method PUT -form @{file=$msgdatafile} -ContentType "multipart/form-data"  -WebSession $global:loginsession).id    
                    }
                }
            }
        }
    }
    $fileids
}
function Add-Directory(){
    param(
        $AnchorTag='DirUploadTest',
        $Directory='C:\Users\dan\teedytest',
        [switch]$DontUseExistingTags,
        [switch]$OnlyCreateTags,
        [switch]$AddAllDirsAsTags,
        [switch]$ExractMSGFiles,
        $Tags
    )
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
}
function Remove-AllImportedDocs(){
    get-TagByPartialName -tagPartialName "IMPORT*" | foreach-object {Remove-DocumentsByTag -Tag $_ -RemoveTagWhenComplete}
}
function Remove-DocumentsByTag(){
    param(
        $Tag,
        [switch]$RemoveTagWhenComplete
    )
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
function Get-DocumentByTag(){
    param([parameter(mandatory)]$tag)
    update-taghash
    if(-not($global:taghash[$tag])){
        write-host "Tag $tag not found."
        break
    }
    $DocumentList=Invoke-RestMethod -uri "$siteurl/api/document/list" -Headers $headers -Method GET -Body @{search="tag:$Tag";limit=0 }  -WebSession $global:loginsession| select-object -ExpandProperty documents|select-object -ExpandProperty id
    $DocumentList
}
function get-documenttags(){
    param(
        [parameter(mandatory)]$documentid
    )
    Invoke-RestMethod -uri "$siteurl/api/document/$DocumentID" -Headers $headers -body @{id=$documentId} -Method GET  -WebSession $global:loginsession|select-object -ExpandProperty tags
}
function Remove-Document(){
    param([parameter(mandatory)]$DocumentID)
    #write-host "Would Delete $documentid"
    Invoke-RestMethod -uri "$siteurl/api/document/$DocumentID" -Headers $headers -body @{id=$documentId} -Method DELETE  -WebSession $global:loginsession
}
function Remove-TagByPartialName(){
    param(
        [parameter(mandatory)]$TagPartialName
    )
    $tagstoremove = @($global:taghash.keys | where-object {$_ -like $tagpartialname})
    if($tagstoremove.count -eq 0){
        write-host "No tags found."
        break
    }
    foreach($tag in $tagstoremove){
        remove-tagbyid -tagid $tag
    }
}
function get-TagByPartialName(){
    param([parameter(mandatory)]$tagPartialName)
    Update-TagHash
    $global:taghash.keys|where-object {$_ -like $tagPartialName}
}
#$importdir = 'c:\documentstoimport'#read-host "Please specify the path to import into Teedy"
#$anchortag = 'DocumentImport'#read-host "What is the anchor tag to import items under?"
$global:headers = get-sitelogin
$global:taghash=@{}
$script:ExtractMSG=$false
update-taghash

#$additionalTags = "Files,2020"#read-host "Any additional tags (comma separated)?"
#$tagstoadd = $additionalTags -split ","
#Add-Directory -AnchorTag $anchortag -Directory $importdir -tags $tagstoadd -AddAllDirsAsTags -ExractMSGFiles

#$documentlist = Invoke-RestMethod -uri "$siteurl/api/document/list" -Headers $headers -Method GET   -WebSession $global:loginsession| select-object -ExpandProperty documents 
#if($documentlist){write-host "Got docs"}
#$filelist = Invoke-RestMethod -uri "$siteurl/api/file/list" -Headers $headers -Method GET  -WebSession $global:loginsession|Select-Object -ExpandProperty Files
#if($filelist){write-host "Got files"}
<#
$logoutresponse = Invoke-webrequest -Uri "$siteurl/api/user/logout" -Headers $headers -Method POST  -WebSession $global:loginsession
if($logoutresponse.BaseResponse.StatusCode -eq 200){
    write-host "logged out successfully"
}
#>