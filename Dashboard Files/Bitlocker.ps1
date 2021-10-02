$BitlockerPages = @()
$UniversalHost = "http://$([System.Net.Dns]::GetHostByName($env:computerName).HostName):5000"
$BitlockerPages += New-UDPage -Name "Bitlocker Key Recovery" -Title "Bitlocker Key Recovery" -Logo '/images/ua_pagelogo.png' -Content {
    New-UDElement -Tag 'div' -Content { 
        New-UDElement -tag 'p' # This adds a blank line
        New-UDElement -tag 'p' # This adds a blank line
        New-UDElement -tag 'p' # This adds a blank line
        New-UDIcon -Icon 'key' -Size '3x'
        New-UDTypography -Text "Get Recovery Key by Computer Name" -Variant "subtitle1"
        New-UDElement -tag 'p' # This adds a blank line
        New-UDTypography -Text "Use this to retrieve a bitlocker recovery key from the SCCM System by Computer Name. " -Variant "body2"
        New-UDElement -tag 'p' # This adds a blank line
        New-UDTextbox -Label 'Computer Name' -Placeholder 'Computer Name' -ID 'RecoveryComputerName'
        New-UDButton -Text 'Get Key...' -OnClick {
            $RecoveryComputerName = (Get-UDElement -Id 'RecoveryComputerName').Value
            If ( $RecoveryComputerName -eq $null ){
                Show-UDModal -Content {
                    New-UDTypography -Text "You have not entered a Computer Name to pass to the API. Please enter one and try again."
                }
            }
            else {
                Set-UDElement -Id 'button_GetRecoveryKey' -Properties @{
                    disabled = $true 
                    text = "Retrieving..."
                }
                $RecoveryKeyName = Invoke-RestMethod $UniversalHost/GetRecoveryKey/$RecoveryComputerName
                Set-UDElement -Id 'codeEditor_GetRecoveryKeyByID' -Properties @{
                    code = $RecoveryKeyName
                }
                Set-UDElement -Id 'button_GetRecoveryKey' -Properties @{
                    disabled = $false 
                    text = "Get Key..."
                }
            } 
        } -Id 'button_GetRecoveryKey'
        New-UDCodeEditor -Id 'codeEditor_GetRecoveryKey' -Height 50 -Width 1400 -ReadOnly -Theme vs-dark
    }
    New-UDElement -Tag 'div' -Content { 
        New-UDElement -tag 'p' # This adds a blank line
        New-UDElement -tag 'p' # This adds a blank line
        New-UDElement -tag 'p' # This adds a blank line
        New-UDIcon -Icon 'key' -Size '3x'
        New-UDTypography -Text "Get Recovery Key by Recovery Key ID" -Variant "subtitle1"
        New-UDElement -tag 'p' # This adds a blank line
        New-UDTypography -Text "Use this to retrieve a bitlocker recovery key from the SCCM System by the Recovery Key ID. " -Variant "body2"
        New-UDElement -tag 'p' # This adds a blank line
        New-UDTypography -Text "Please enter the Recovery Key ID below. You can enter any number of characters, but I would suggest a minimum of 8." -Variant "body2"
        New-UDElement -tag 'p' # This adds a blank line
        New-UDTextbox -Fullwidth -Type text -Placeholder 'Recovery Key ID'-ID 'RecoveryKeyID'
        New-UDButton -Text 'Get Key...' -OnClick {
            $RecoveryKeyID = (Get-UDElement -Id 'RecoveryKeyID').Value
            If ( $RecoveryKeyID -eq $null ){
                Show-UDModal -Content {
                    New-UDTypography -Text "You have not entered a Recovery Key ID to pass to the API. Please enter one and try again."
                }
            }
            else {
                Set-UDElement -Id 'button_GetRecoveryKeyByID' -Properties @{
                    disabled = $true 
                    text = "Retrieving..."
                }
                $RecoveryKey = Invoke-RestMethod $UniversalHost/GetRecoveryKeyByID/$RecoveryKeyID
                Set-UDElement -Id 'codeEditor_GetRecoveryKeyByID' -Properties @{
                    code = $RecoveryKey
                }
                Set-UDElement -Id 'button_GetRecoveryKeyByID' -Properties @{
                    disabled = $false 
                    text = "Get Key..."
                }
            } 
        } -Id 'button_GetRecoveryKeyByID'
        New-UDCodeEditor -Id 'codeEditor_GetRecoveryKeyByID' -Height 50 -Width 1400 -ReadOnly -Theme vs-dark
    }
}

New-UDDashboard -Title "UA Bitlocker" -Pages $BitlockerPages