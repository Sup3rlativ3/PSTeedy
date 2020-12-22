Function New-TeedyFile(){
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        $Files
    )
    If($PSCmdlet.ShouldProcess("$FileID", "Adding a file to Teedy")) {
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
    }s
}
