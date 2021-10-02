#requires -version 5
<#
.SYNOPSIS
  This script will retrieve the bitlocker recovery key from the configmgr database using the computer name or recovery key id
.DESCRIPTION
  This script will go through and create the Database and all the table structure needed to get the backend setup for the automated provisioning of devices
.PARAMETER <Parameter_Name>
    -ServerInstance - This parameter will specify which server to create the database on
    -SiteCode - This parameter is to specify the database to use
    -ComputerName - Enter the computer name that you wish to get the recovery key for
    -KeyID - Enter the recovery key that is shown... You can use any number of characters starting with the first one
.INPUTS
  <None>
.OUTPUTS
  Bitlocker Recovery Key Information
.NOTES
  Version:        1.0
  Author:         <John Yoakum>
  Creation Date:  <09092021>
  Purpose/Change: Initial script development
  
.EXAMPLE
  <Get-RecoveryKey.ps1 -ServerInstance 'viamonstra\sql01' -SiteCode 'CM1' -ComputerName 'COMP01' >
  <Get-RecoveryKey.ps1 -ServerInstance 'viamonstra\sql01' -SiteCode 'CM1' -KeyID '32343232' >
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
#$ErrorActionPreference = "SilentlyContinue"
param (
    [parameter (
        Mandatory = $true
    )]
    [string[]]$ServerInstance,      
    [parameter (
        Mandatory = $true
    )]
    [string[]]$SiteCode,
    [parameter (
        Mandatory = $false
    )]
    [string[]]$ComputerName,
    [parameter (
        Mandatory = $false
    )]
    [string[]]$KeyID
)
#----------------------------------------------------------[Declarations]----------------------------------------------------------
$sqlRecoveryByComputer = "
USE [CM_$SiteCode]
GO

SELECT
*
from (
Select
cm.Name as 'Computer Name',
s.User_Name0 as 'User name',
s.Last_Logon_Timestamp0 as 'Last Logon Time',
csys.Manufacturer0 as 'Manufacturer',
csys.Model0 as 'Model',
bl.DriveLetter0 'Drive letter',
bl.IsAutoUnlockEnabled0 'Is AutoUnlocled enabled',
bl.ProtectionStatus0 'Protection Status',
mbam.MBAMPolicyEnforced0 'MBAM Policy Enforced',
mbam.OsDriveEncryption0 'OS Drive Encryption',
CASE EV.ProtectionStatus0
WHEN '0' THEN 'No'
WHEN '1' THEN 'Yes'
WHEN '2' THEN 'Unknown'
END AS 'Bitlocker Enabled',
CASE WHEN (TPM.IsActivated_InitialValue0 = 1) then 'Yes' else 'No' END [TPM Activated],  
CASE WHEN (TPM.IsEnabled_InitialValue0 = 1) then 'Yes' else 'No' END [TPM Enabled],  
CASE WHEN (TPM.IsOwned_InitialValue0 = 1) then 'Yes' else 'No' END [TPM Owned], 
EV.ProtectionStatus0 AS 'Bitlocker Indicator',
RecoveryAndHardwareCore.DecryptString(ck.RecoveryKey, DEFAULT) AS 'Recovery Key',
ck.LastUpdateTime as 'Update time',
row_number() over(partition by cm.name order by ck.LastUpdateTime desc) as rn
from
RecoveryAndHardwareCore_Keys ck
iNNER JOIN RecoveryAndHardwareCore_Volumes cv on ck.VolumeID = cv.ID
LEFT JOIN RecoveryAndHardwareCore_VolumeTypes cvt on cv.VolumeTypeId = cvt.Id
LEFT JOIN RecoveryAndHardwareCore_Machines_Volumes cmv on cv.Id = cmv.VolumeId
LEFT JOIN RecoveryAndHardwareCore_Machines cm on cmv.MachineId = cm.Id
LEFT  JOIN v_R_System s on s.Name0=cm.Name
left join v_GS_ENCRYPTABLE_VOLUME EV on EV.resourceid=s.ResourceID
left join  v_GS_BITLOCKER_DETAILS  bl on bl.Resourceid=s.ResourceID
left join v_GS_MBAM_POLICY mbam on mbam.ResourceID=s.ResourceID
LEFT JOIN v_GS_TPM TPM ON EV.ResourceID = TPM.ResourceID
left join v_GS_COMPUTER_SYSTEM csys on csys.ResourceID = s.ResourceID
left join v_FullCollectionMembership fcm on fcm.ResourceID=csys.ResourceID
where cm.Name = '$ComputerName' ) as t
 
where rn=1 
"
$sqlRecoveryByID = "
USE [CM_$SiteCode]
GO

SELECT
*
from (
Select
cm.Name as 'Computer Name',
s.User_Name0 as 'User name',
s.Last_Logon_Timestamp0 as 'Last Logon Time',
csys.Manufacturer0 as 'Manufacturer',
csys.Model0 as 'Model',
bl.DriveLetter0 'Drive letter',
bl.IsAutoUnlockEnabled0 'Is AutoUnlocled enabled',
bl.ProtectionStatus0 'Protection Status',
mbam.MBAMPolicyEnforced0 'MBAM Policy Enforced',
mbam.OsDriveEncryption0 'OS Drive Encryption',
CASE EV.ProtectionStatus0
WHEN '0' THEN 'No'
WHEN '1' THEN 'Yes'
WHEN '2' THEN 'Unknown'
END AS 'Bitlocker Enabled',
CASE WHEN (TPM.IsActivated_InitialValue0 = 1) then 'Yes' else 'No' END [TPM Activated],  
CASE WHEN (TPM.IsEnabled_InitialValue0 = 1) then 'Yes' else 'No' END [TPM Enabled],  
CASE WHEN (TPM.IsOwned_InitialValue0 = 1) then 'Yes' else 'No' END [TPM Owned], 
EV.ProtectionStatus0 AS 'Bitlocker Indicator',
ck.RecoveryKeyId,
RecoveryAndHardwareCore.DecryptString(ck.RecoveryKey, DEFAULT) AS 'Recovery Key',
ck.LastUpdateTime as 'Update time',
row_number() over(partition by cm.name order by ck.LastUpdateTime desc) as rn
from
RecoveryAndHardwareCore_Keys ck
iNNER JOIN RecoveryAndHardwareCore_Volumes cv on ck.VolumeID = cv.ID
LEFT JOIN RecoveryAndHardwareCore_VolumeTypes cvt on cv.VolumeTypeId = cvt.Id
LEFT JOIN RecoveryAndHardwareCore_Machines_Volumes cmv on cv.Id = cmv.VolumeId
LEFT JOIN RecoveryAndHardwareCore_Machines cm on cmv.MachineId = cm.Id
LEFT  JOIN v_R_System s on s.Name0=cm.Name
left join v_GS_ENCRYPTABLE_VOLUME EV on EV.resourceid=s.ResourceID
left join  v_GS_BITLOCKER_DETAILS  bl on bl.Resourceid=s.ResourceID
left join v_GS_MBAM_POLICY mbam on mbam.ResourceID=s.ResourceID
LEFT JOIN v_GS_TPM TPM ON EV.ResourceID = TPM.ResourceID
left join v_GS_COMPUTER_SYSTEM csys on csys.ResourceID = s.ResourceID
left join v_FullCollectionMembership fcm on fcm.ResourceID=csys.ResourceID
where ck.RecoveryKeyId like ('$KeyID' + '%')) as t
 
where rn=1 
"
$SqlServerInstalled = Get-Module -Name 'SqlServer'

#-----------------------------------------------------------[Functions]------------------------------------------------------------


#-----------------------------------------------------------[Execution]------------------------------------------------------------

If ($SqlServerInstalled -eq $null) {
    Install-Module -Name "SqlServer" -Force
	Import-Module -name "SqlServer" -Force
}

$RecoveryHelp = ""

If (($ComputerName -ne $null) -and ($KeyID -ne $null)) {
    Write-Host "You need to only enter a ComputerName or a KeyID, not both"
} 
Elseif ($ComputerName -ne $null) {
    $RecoveryHelp = Invoke-SqlCmd -ServerInstance "$ServerInstance" -Query $sqlRecoveryByComputer
}
Elseif ($KeyID -ne $null) {
    $RecoveryHelp = Invoke-SqlCmd -ServerInstance "$ServerInstance" -Query $sqlRecoveryByID
}
$RecoveryHelp.'Recovery Key'
