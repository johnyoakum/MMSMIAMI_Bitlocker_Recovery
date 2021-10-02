<#
You will need to add your CM Server information to run the queries on. Lines 13, 17, 59, 117
You may also need to add some pre-staged credentials to the Invoke-SqlCmd for access
This is just the groundwork if you want to create any APIs to get the data

endpoints.ps1 file for Powershell Universal

#>

New-PSUEndpoint -Url "/GetRecoveryKey/:ComputerName" -Endpoint {
    param([string]$ComputerName)
    $sqlRecoveryByComputer = "
    USE [<CMDBName>]
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

    $RecoveryKey = Invoke-Sqlcmd -ServerInstance "<SCCMSERVER>" -Database "<CM_PS1>" -Query $sqlRecoveryByComputer
    If ($RecoveryKey -eq $null) {
        $KeyResponse = 'No object Exists'
    }
    else {
        $KeyResponse = $RecoveryKey.'Recovery Key'
    }
    $KeyResponse
} 
New-PSUEndpoint -Url "/GetRecoveryKeyByID/:RecoveryKeyID" -Endpoint {
    param([string]$RecoveryKeyID)
    $sqlRecoveryByID = "
    USE [<CMDBNAME]
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
    where ck.RecoveryKeyId like ('$RecoveryKeyID' + '%')) as t
    
    where rn=1 
    "
    $RecoveryKey = Invoke-Sqlcmd -ServerInstance "<SCCMSERVER>" -Database "<CM_PS1>" -Query $sqlRecoveryByID
    If ($RecoveryKey -eq $null) {
        $KeyResponse = 'No object Exists'
    }
    else {
        $KeyResponse = $RecoveryKey.'Recovery Key'
    }
    $KeyResponse
} 