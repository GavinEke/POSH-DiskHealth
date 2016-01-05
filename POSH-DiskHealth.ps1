[regex]$regex = "4&[0-f]{8}&0&0[0-f]0{4}"

ForEach ($UniqueDriveID in ((Get-Disk).ObjectId | Select-String -Pattern $regex).Matches.Value) {
    $Disk = Get-Disk | Where ObjectId -Like "*$UniqueDriveID*"
    $DiskHealthStats = Get-Disk -Number $Disk.Number | Get-StorageReliabilityCounter
    $FailurePredict = Get-CimInstance -Namespace root\wmi -Class MSStorageDriver_FailurePredictStatus | Where InstanceName -Like "*$UniqueDriveID*"
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
