function Connect-Teedy(){
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [String]$Username,
        [Parameter(Mandatory=$true)]
        [String]$Password,
        [Parameter(Mandatory=$true)]
        [String]$URL
    )
    If($PSCmdlet.ShouldProcess("$URL", "Logging into the Teedy instance")) {
        $global:SiteURL=$URL
        $tologin=@{Username="$Username";Password="$Password";}
        try{
            $loginresponse = Invoke-webrequest -Uri "$SiteURL/api/user/login" -Method POST -Body $tologin -SessionVariable Session
        } catch {
            if(($error[0].ErrorDetails.Message|convertfrom-json|select-object -ExpandProperty Type) -eq 'ValidationCodeRequired'){
                $mfacode = read-host "MFA Code Required for user. Please enter MFA Code:"
                if($mfacode -match '\d{6}'){
                    $tologin.add('code',$mfacode)
                    $loginresponse = Invoke-webrequest -Uri "$SiteURL/api/user/login" -Method POST -Body $tologin -SessionVariable Session
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
}
