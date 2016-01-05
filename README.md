# POSH-DiskHealth

http://i.imgur.com/n0xCyjI.png

##Regex Test##

(Get-Disk).Count

((Get-Disk).ObjectId | Select-String -Pattern "4&[0-f]{8}&0&0[0-9]0{4}").Count

((Get-CimInstance -Namespace root\wmi -Class MSStorageDriver_FailurePredictStatus).InstanceName | Select-String -Pattern "4&[0-f]{8}&0&0[0-9]0{4}").Count
