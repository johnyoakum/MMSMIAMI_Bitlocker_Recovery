New-PSUDashboard -Name "Bitlocker" -FilePath "Bitlocker.ps1" -BaseUrl "/bitlocker" -Framework "UniversalDashboard:Latest" -Environment "Integrated" -Component @("UniversalDashboard.CodeEditor:1.0.4") -SessionTimeout 0 -AutoDeploy -DisableErrorToast 