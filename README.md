# MMSMIAMI_Bitlocker_Recovery

## Our Bitlocker History
### Key Points
* This was the first time that we looked at doing bitlocker
* We are not escrowing keys in AD or Azure directly
* Only storing recovery keys in ConfigMgr Database
* Not prestaging devices in Task Sequence
* We are using Bitlocker Policies to enable Bitlocker
* We did configure the Bitlocker Portals

## What we found
* Would not start encrypting until domain user signed in
* Our techs could not retrieve keys from portals unless certain criteria was met
  * They had to know the username associated with the recovery Key
  * Needed a way to get keys at any time easily

## Solution we Used
* Found a SQL Query that we modified that could retrieve the Key
* Created an API that would retrieve the key easily
* Created a user interface for a graphically way to retrieve the key

## Other solutions we Created
* Created a powershell script that we could pass values through to get the values directly from database
  * This requires SQLServer Powershell Module to be installed (script will install if not already installed)
  * Must have permissions to read ConfigMgr Database
  * Script accepts either computer name or a partial recovery key ID
  
Run the script with either of the following syntax:
> ./Get-RecoveryKey.ps1 -ServerInstance 'viamonstra\sql01' -SiteCode 'CM1' -ComputerName 'COMP01'

> ./Get-RecoveryKey.ps1 -ServerInstance 'viamonstra\sql01' -SiteCode 'CM1' -KeyID '32343232'

