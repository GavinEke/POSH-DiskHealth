#Requires -RunAsAdministrator
#Requires -Version 4

<#PSScriptInfo

.VERSION 1.3.0

.GUID ca58874b-60b2-4177-8749-3771db294d1a

.AUTHOR Gavin Eke @GavinEke

.COMPANYNAME 

.COPYRIGHT 

.TAGS POSH-DiskHealth

.LICENSEURI 

.PROJECTURI https://github.com/GavinEke/POSH-DiskHealth

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES

.DESCRIPTION 
 Performs multiple checks of local disks to predict if a disk might need replacing. Windows 8.1/Server 2012+.

#>


[regex]$regex = "4&[0-f]{7,8}&0&0[0-f]0{4}"

ForEach ($UniqueDriveID in ((Get-Disk).ObjectId | Select-String -Pattern $regex).Matches.Value) {
    $Disk = Get-Disk | Where-Object ObjectId -Like "*$UniqueDriveID*"
    $DiskHealthStats = Get-Disk -Number $Disk.Number | Get-StorageReliabilityCounter
    $FailurePredict = Get-CimInstance -Namespace root\wmi -Class MSStorageDriver_FailurePredictStatus | Where-Object InstanceName -Like "*$UniqueDriveID*"
    Write-Output "===================================================="
    Write-Output "Disk No. $($Disk.Number)"
    Write-Output "Disk Name: $($Disk.FriendlyName)"
    Write-Output "Disk S/N: $($Disk.SerialNumber)"
    Write-Output "----------------------------------------------------"
    Write-Output "Disk is $($Disk.HealthStatus)"
    If ($DiskHealthStats.Wear -gt 90) {
        Write-Output "SSD is very close to end of life. You should replace this SSD ASAP"
    } ElseIf ($DiskHealthStats.Wear -gt 80) {
        Write-Output "SSD is close to end of life. You should consider replacing this SSD"
    }
    Write-Output "Read Error Count is $($DiskHealthStats.ReadErrorsTotal)"
    Write-Output "Read Errors Corrected is $($DiskHealthStats.ReadErrorsCorrected)"
    Write-Output "Failure Predicted: $($FailurePredict.PredictFailure)"
    If ($FailurePredict.PredictFailure -eq $True) {
        Write-Output "Failure Predicted Reason: $($FailurePredict.Reason)"
    }
    Write-Output "===================================================="
    Write-Output ""
}
